local log_level = require("framework.log.log_level")
local log_console = class("log_console")

local logFuncMap = {
    [log_level.VERBORSE]  = UnityEngine.Debug.Log;
    [log_level.INFO]  = UnityEngine.Debug.Log;
    [log_level.DEBUG]  = UnityEngine.Debug.Log;
    [log_level.WARN]  = UnityEngine.Debug.LogWarning;
    [log_level.ERROR]  = UnityEngine.Debug.LogError;
}

function log_console:ctor()
end

function log_console:handle_log(level, msg)
	local func = logFuncMap[level]
    func(msg)
end


return log_console