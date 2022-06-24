local service_base = require("framework.mvp.service_base")
local player_service = class("player_service", service_base)

player_service.event_func_map = {
	[event.net_event.CONNECT] = "handle_connect";
}

function player_service:ctor()
	service_base.ctor(self)

end

function player_service:start()
	service_base.start(self)
	log.d()
end

function player_service:stop()
	service_base.stop(self)
end

function player_service:handle_connect()
	log.d("player_service:handle_connect()")
	self:send_msg(net.C2S.LOGIN, {
		sdk = 1;
		openId = "xzben";
		areaId = 1;
		platform = 1;
		clientFullVersion = "1.0.0.1";
		clientResVersion = "2.0.0.1";
		channel = "wx";
		nickname = "xzben";
		icon = "";
	})
end

return player_service