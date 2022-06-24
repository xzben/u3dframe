local proto_register = class("proto_register")
local net_config = require("net.net_config")
local UpdateManager = LuaFramework.GameWorld.Inst.UpdateManager;

local s_protoFiles = {
	"net/pb/battle.pb";
	"net/pb/common.pb";
	"net/pb/email.pb";
	"net/pb/game.pb";
	"net/pb/hero.pb";
	"net/pb/login_activity.pb";
	"net/pb/normal.pb";
}

function proto_register:register_all()
	require "3rd/pbc/protobuf"
	for _, file in ipairs(s_protoFiles) do
		self:register( file )
	end
end

function proto_register:register( filename )
	local path = UpdateManager:getLuaRoot().."/Lua/"..filename
	log.d("proto_register register", path)
	local file = io.open(path, "rb")
	local buffer = file:read("*a")
	file:close()
    protobuf.register(buffer)
end

function proto_register:encode( cmd, data, session)
	local session = session or 0
	local c2s = net_config.C2S

	local config = c2s[cmd]
	if config == nil then
		log.d("can't find the c2s config by cmd", cmd)
		return nil
	end

	local inbuf = self:encode_message(config.message, data)

	local buffer = self:encode_message("common.CommonHead", {
		cmd = cmd,
		session = session or 0;
		byte = inbuf
	})

	return buffer
end

function proto_register:decode( buffer )
	local head = self:decode_message("common.CommonHead", buffer)

	if not head then
		log.e("decode buffer failed", buffer)
		return
	end

	local cmd = head.cmd
	local session = head.session
	local byte = head.byte

	local s2c = net_config.S2C
	local config = s2c[cmd]

	if config == nil then
		log.e("can't find s2c config by cmd:", cmd)
		return
	end

	local data = self:decode_message(config.message, byte)
	return cmd, session, data 
end

function proto_register:encode_message(message, data)	
	return protobuf.encode(message, data)
end

function proto_register:decode_message( message, buffer)
	local decode, err = protobuf.decode(message, buffer, #buffer)

	if decode then
		return decode
	end

	log.w("can't decode message by message", message)

	return {}
end

return proto_register