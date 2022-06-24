local log_level = require("framework.log.log_level")
local log_console = require("framework.log.log_console")
local log_file = require("framework.log.log_file")
local log_http = require("framework.log.log_http")
local log_helper = require("framework.log.log_helper")

local log_controller = class("log_controller")

function log_controller:ctor()
	self.m_delegates = {}
	self.m_log_level = log_level.ALL

	self.m_logConsole = log_console.new()
	self:add_delegate(log_file.new())
	self:add_delegate(log_http.new())
	self:init_core_handle()
end

function log_controller:dtor()
	self:uninit_core_handle()
end

function log_controller:init_core_handle()
	self.m_log_message_received_func = function(...)
        self:handle_cshare_log(...)
    end
    UnityEngine.Application.logMessageReceived = UnityEngine.Application.logMessageReceived + self.m_log_message_received_func
end

function log_controller:uninit_core_handle()
	if self.m_log_message_received_func == nil then return end
	UnityEngine.Application.logMessageReceived = UnityEngine.Application.logMessageReceived - self.m_log_message_received_func
	self.m_log_message_received_func = nil
end

local coreLogTypeConvert = {
	[UnityEngine.LogType.Error] = log_level.ERROR;
	[UnityEngine.LogType.Assert] = log_level.ERROR;
	[UnityEngine.LogType.Warning] = log_level.WARN;
	[UnityEngine.LogType.Log] = log_level.DEBUG;
	[UnityEngine.LogType.Exception] = log_level.DEBUG;
}

function log_controller:handle_cshare_log( logstring, stackTrace, logType )
	local level = coreLogTypeConvert[logType] or  log_level.DEBUG
	if self.m_log_level > level then return end

	local msg = nil
	if level >= log_level.WARN then
		msg = log_helper.print(logstring, stackTrace )
	else
		msg = logstring
	end

	for _, delegate in ipairs(self.m_delegates) do
		delegate:handle_log(level, msg)
	end
end

function log_controller:get_log_file()
	return self.m_logFile
end

function log_controller:add_delegate( delegate )
	table.insert(self.m_delegates, delegate)
end

function log_controller:handle_log( level, ...)
	if self.m_log_level > level then return end
	local msg = log_helper.print(...)
	self.m_logConsole:handle_log(level, msg)
end

return log_controller