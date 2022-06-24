local log_file = class("framework.log.log_file")


function log_file:ctor()
	self.m_file = nil
end

function log_file:get_file_name()
	local file_name = LuaFramework.GameWorld.Inst.GameManager:getWriteablePath() .. "/log.txt"
	
    return file_name
end

function log_file:check_init()
	if nil == self.m_file then
        local filename = self:get_file_name()
        self.m_file = assert(io.open(filename, "w+"))
        self.m_file:seek("set", 0)
    end
end

function log_file:handle_log(level, msg)
	self:check_init()
	
    self.m_file:write(os.date("%Y-%m-%d %H:%M:%S") .. msg)
    self.m_file:write('\r\n')
    self.m_file:flush()
end


return log_file