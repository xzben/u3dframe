local cjson = require "cjson"

function Main()
	require "framework.init"
	require("config.config")
	require("const.const")
	require("event.event")
	require("debug.LuaBreak")
	require("net.net")
	require("game.game")
	require("platform")

	utils.wait = require("modules.common.wait").ctr.new()
	utils.toast = require("modules.common.toast").ctr.new()
	utils.msg_box = require("modules.common.msg_box").ctr.new()

	game.service_manager:init(game.services)
	net.network:init()
	
	log.d("json test", cjson.encode({ a = 1; b = 2;}))
	log.d("------------------- Main Start -----------------------")
end

function OnLevelWasLoaded(level, name)
	collectgarbage("collect")
	UnityEngine.Application.targetFrameRate = 30
	game.scene_manager:run_scene(name)
	log.d("------------------- OnLevelWasLoaded -----------------------", level, name)
end

function OnSocketEvent( event, buffer )
	net.network:handleCSEvent(event, buffer)
end

function OnApplicationQuit()
	log.d("退出了游戏")
	collectgarbage("collect")
end

function onPlatformEvent( jsData )
	-- log.d("======onPlatformEvent=====", jsData)
	local data = cjson.decode(jsData)
	if platform and data ~= nil and data.funcName ~= nil then
		platform:dispatch(data.funcName, data)
	end
end