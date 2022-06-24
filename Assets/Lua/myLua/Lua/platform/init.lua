

local platform_imp = nil

local env = LuaFramework.GameWorld.Inst.PlatformManager:getPlatfromType()

if env == const.platform_type.ANDROID then
	platform_imp = require("platform.platform_android")
elseif env == const.platform_type.IOS then
	platform_imp = require("platform.platform_ios")
else
	platform_imp = require("platform.platform_base")
end

platform = platform_imp.new()





