local event_dispatcher = require("framework.event.event_dispatcher")
local network = class("network", event_dispatcher)

local net_event = require("event.net_event")
local pb_cmd = require("net.pb_cmd")
local ByteBuffer = LuaFramework.ByteBuffer

local STATUS = {
	CONNECTING = 1,
	CONNECT_SUCCESS = 2,
	CONNECT_CLOSE = 3,
}

local filterLogC2SMsg = {
	[pb_cmd.C2S.HEART] = true;
}

local filterLogS2CMsg = {
	[pb_cmd.S2C.HEART] = true;
}

function network:ctor()
    event_dispatcher.ctor(self)

    self.m_sessionRespCall = {}
    self.m_reqRespCall = {}

    self.m_networkMgr = LuaFramework.GameWorld.Inst.NetworkManager;
    self.m_protoRegister = net.proto_register.new()

    self.m_curIp = ""
    self.m_curPort = 0
    self.m_ips = {}
    self.m_stackMessage = {}
    self.m_curIndex = 1

    self.m_sessionCount = 0
    self.m_heartWatchDog = os.time()
	self.m_seqNum = 0
	self.m_status = STATUS.CONNECT_CLOSE
	self.m_updateEnable = false
	self.m_pauseDispatcher = false
end

function network:get_session_id()
	self.m_sessionCount = self.m_sessionCount + 1
	return self.m_sessionCount
end

function network:init()
	self:init_ips()
	self:update_protos()

	self:add_listener(pb_cmd.S2C.HEART, self.handle_heart_response, self)
	self:add_listener(pb_cmd.S2C.LOGIN_OTHER, self.handle_login_other_client, self)
end

function network:eat_watchdog()
	self.m_heartWatchDog = os.time()
end



function network:handle_connected()
	self:clear_connect_cache()
	self.m_status = STATUS.CONNECT_SUCCESS
	self.m_updateEnable = true
	log.d("################## network:handle_connected", self.m_curIp, self.m_curPort)
	self:dispatch(net_event.CONNECT)
end

function network:handle_disconnect()
	self.m_status = STATUS.CONNECT_CLOSE
	self:dispatch(net_event.DISCONNECT)
end

function network:handel_connect_failed()
	self.m_status = STATUS.CONNECT_CLOSE

	self:dispatch(net_event.CONNECT_FAILED)
end

function network:handle_login_other_client()
	self.m_status = STATUS.CONNECT_CLOSE
	self:close()
end

function network:init_ips()
	self.m_ips = config.net_config.get_cur_server_list()
	log.d("############ initIps", self.m_ips)
	self.m_curIndex = 1
end

function network:insert_ips( ips )
	if not config.is_release()  then return end
	
	for _, item in ipairs( ips ) do
		if item.ip and item.port then
			table.insert(self.m_ips, { ip = item.ip; port = item.port; })
		end
	end
end

function network:update_protos()
	self.m_protoRegister:register_all()
end

function network:handle_heart_response(data)
	local curTime = os.time()
	self.m_pingDt = curTime
	if self.m_seqNum == data.seq_num then
		self.m_ping = curTime*1000 - data.sys_time		
	else
		self.m_ping = 5000
	end
end

function network:get_cur_ip()
	local config = self.m_ips[self.m_curIndex]
	if config ~= nil then
		return config.ip, config.port
	end
end

function network:try_network_next_ip()
	self.m_curIndex = self.m_curIndex + 1
	self:startNetwork()
end

function network:clear_connect_cache()
	if self.m_connectCo ~= nil then
		coroutine.stop(self.m_connectCo)
	end
	self.m_connectCo = nil
end

function network:is_connecting()
	return self.m_status == STATUS.CONNECTING
end

function network:is_connected()
	return self.m_status == STATUS.CONNECT_SUCCESS
end

function network:start_network()
	if self:is_connecting() then
		log.d("is connecting")
		return
	end

	if self:is_connected() then
		log.d("is connected not need to connect", self.m_status)
		return
	end

	local curIp, curPort = self:get_cur_ip()
	if curIp == nil or curPort == nil then
		log.d("########## startNetwork ###########")
		self.m_curIndex = 1
	else
		self.m_updateEnable = false
		self.m_curIp = curIp
		self.m_curPort = curPort
		self.m_status = STATUS.CONNECTING
		self.m_networkMgr:SendConnect(curIp, curPort);

		self:clear_connect_cache()
		log.d("############# start connect", curIp, curPort)
		self.m_connectCo = coroutine.start(function() 
			coroutine.wait(config.net_config.HEART_TIMEOUT)
			self.m_status = STATUS.CONNECT_CLOSE
			self.m_networkMgr:Close()
			self:handel_connect_failed()
		end)
	end
end

function network:close()
	self.m_networkMgr:Close()
	self.m_status = STATUS.CONNECT_CLOSE
end

function network:is_closed()
	return self.m_status == STATUS.CONNECT_CLOSE
end

function network:wait_session_resp(sessionId, sendDoneCallback )
	self.m_sessionRespCall[sessionId] = sendDoneCallback
end

function network:wait_request_resp( sessionId, respCallback )
	self.m_reqRespCall[sessionId] = respCallback
end

function network:send_game_msg( gameId, roomId, bytes, sendDoneCallback, respCallback)

end

function network:send_msg( cmd, data, sendDoneCallback, respCallback)
	if not self:is_connected() then
		log.d("network:send_msg not is_connected")
		if not self:is_connecting() then
			self:start_network()
			log.d("send msg failed because connect close, now start connect")
		end

		return false
	end

	local sessionId = self:get_session_id()
	local buffer = self.m_protoRegister:encode(cmd, data, sessionId)
	if buffer == nil then
		log.w("send msg failed encode buffer == nil")
		return false
	end

	if sendDoneCallback then
		self:wait_session_resp(sessionId, sendDoneCallback)
	end

	if respCallback then
		self:wait_request_resp(sessionId, respCallback)
	end

	if not filterLogC2SMsg[cmd] then
		log.d("send msg:", cmd, data, sessionId)
	end

	local pack = ByteBuffer.New()
	pack:WriteNetBytes(buffer)
	self.m_networkMgr:SendMessage(pack)
	return true
end

function network:update( dt )
	if not self.m_updateEnable then return end

	self:check_heart()
end

function network:handle_ping_slow()
	log.d("handle_ping_slow")
end

function network:check_heart( forceSend )
	local curTime = os.time()

	if curTime - self.m_heartWatchDog > config.net_config.HEART_TIMEOUT then
		self:handle_ping_slow()
	end

	if not self:is_connected() then
		return
	end

	if not forceSend and self.m_lastHeartTime ~= nil and curTime - self.m_lastHeartTime < config.net_config.HEART_GAP then
		return
	end
	self.m_lastHeartTime = curTime

	self:send_msg(pb_cmd.C2S.HEART, {
		clientTime = curTime
	}, function( success, data) 
		if data then
			local severtime = data.serverTime;
			local clientTime = data.clientTime
			utils.set_server_offset_time(Math.ceil(serverTime - clientTime))
			self:eat_watchdog()
		end
	end)
end

function network:pause_dispatcher_message()
	self.m_pauseDispatcher = true;
end

function network:resume_dispatcher_message()
	self.m_pauseDispatcher = false

	for index, item in ipairs(self.m_stackMessage) do
		self:do_dispatch_message( item.cmd, item.session, item.data)
	end

	self.m_stackMessage = {}
end

function network:handle_request_resp( session, success, cmd, data)
	if cmd ~= pb_cmd.S2C.HEART then

	end

	local callback = self.m_reqRespCall[session]
	self.m_reqRespCall[session] = nil

	if type(callback) == "function" then
		callback(success, data)
	end
end

function network:handle_session_resp(session, success)
	local callback = self.m_sessionRespCall[session]
	self.m_sessionRespCall[session] = nil

	if type(callback) == "function" then
		callback(success)
	end
end


function network:do_dispatch_message( cmd, session, data)
	if session >= 0 then
		self:handle_request_resp( session, true, cmd, data)
		self:handle_session_resp( session, true)
	end

	if cmd == pb_cmd.S2C.SESSION then
		return
	end

	self:dispatch(cmd, data, session)
end

function network:handle_message(event, msg)
	local buffer = msg:ReadBuffer()
	local cmd, session, data = self.m_protoRegister:decode(buffer)
	self:eat_watchdog()

	if data then
		if not filterLogS2CMsg[cmd] then
			log.d("handle_message", cmd, session, data)
		end

		if self.m_pauseDispatcher then
			table.insert(self.m_stackMessage, { cmd = cmd, session = session; data = data; })
		else
			self:do_dispatch_message(cmd, session, data)
		end
	else
		log.e('handle message decode failed', buffer)
	end
end

function network:handle_exception()
	self:handle_disconnect()
end

local CSEVENT = {
	CONNECT =  1,
	EXCEPTION = 2,
	DISCONNECT = 3,
	CONNECT_FAILED = 4,
	MESSAGE = 5,
}

local cs_event_handle = {
	[CSEVENT.CONNECT] = network.handle_connected;
	[CSEVENT.EXCEPTION] = network.handle_exception;
	[CSEVENT.DISCONNECT] = network.handle_disconnect;
	[CSEVENT.CONNECT_FAILED] = network.handel_connect_failed;
	[CSEVENT.MESSAGE] = network.handle_message;
}

function network:handleCSEvent( event, msg)
	local handle = cs_event_handle[event]

	if type(handle) ~= "function" then
		log.e("can't find event:", event, msg)
		return 
	end

	handle(self, event, msg)
end

return network