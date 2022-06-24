
local log = require("framework.log.log")
local log_level = require("framework.log.log_level")


--运行断点调试
function execBreak()
    local env = LuaFramework.GameWorld.Inst.PlatformManager:getPlatfromType()
    local isIOS = (env == const.platform_type.IOS)
    local isAndroid = (env == const.platform_type.ANDROID)
    local isOpenBreak = config.get_cur_env() == config.env.DEBUG
    print('===execBreak===isOpen:', isOpenBreak, isIOS, isAndroid)
    if isOpenBreak and not isAndroid and not isIOS then
        -- 添加调试代码
        local breakFun = require("debug.LuaDebugjit")("localhost", 7003);
        --添加断点监听函数
        Timer.New(breakFun, 0.5, -1, 1);	
    end
end

execBreak()