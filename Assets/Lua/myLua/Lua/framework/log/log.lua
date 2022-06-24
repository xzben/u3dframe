local log_level = require("framework.log.log_level")
local log = {}

log.log_controller = require("framework.log.log_controller").new()

function log.get_log_file_name()
	return log.log_controller:get_log_file():get_file_name()
end

function log.d(...)
	log.log_controller:handle_log(log_level.DEBUG, "debug--", ...)
end

function log.v(...)
	log.log_controller:handle_log(log_level.VERBORSE, "VERBORSE--", ...)    
end

function log.i(...)
   	log.log_controller:handle_log(log_level.INFO, "INFO--", ...)
end

function log.e(...)
	local params = {...}
	table.insert(params, debug.traceback())

	log.log_controller:handle_log(log_level.ERROR, "ERROR--", unpack(params))   	
end

function log.w(...)
	local params = {...}
	table.insert(params, debug.traceback())

   	log.log_controller:handle_log(log_level.WARN, "WARN--", unpack(params))
end

function log.todo_e(...)
	local params = { ... }
	table.insert(params, 1, "<color=#FF0000> ")
	table.insert(params, 2, "todo 待办事项 --")
	table.insert(params, " </color>")

    log.log_controller:handle_log(log_level.ERROR, unpack(params))
end

function log.todo_w(...)
	local params = { ... }
	table.insert(params, 1, "<color=#FF0000> ")
	table.insert(params, 2, "todo 待办事项 --")
	table.insert(params, " </color>")
    log.log_controller:handle_log(log_level.WARN, unpack(params))
end

function log.r(...)
	local params = { ... }
	table.insert(params, 1, "<color=#cb4313> ")
	table.insert(params, 2, "todo 待办事项 --")
	table.insert(params, " </color>")
    log.log_controller:handle_log(log_level.DEBUG, unpack(params))
end

return log