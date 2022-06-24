local action_instant = require("framework.utils.action.action_instant")
local call_func = class("call_func", action_instant)

function call_func:ctor( func )
	self.m_func = func
	action_instant.ctor(self)
end

function call_func:execute()
	if type(self.m_func) == "function" then
		self.m_func(self:get_target())
	end
end

return call_func