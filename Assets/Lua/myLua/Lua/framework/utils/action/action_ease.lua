local action_interval = require("framework.utils.action.action_interval")
local action_ease = class("action_ease", action_interval)

function action_ease:ctor(action)
	assert(action ~= nil and action:is_interval_action(), "please pass a interval action")
	self.m_action = action
	action_interval.ctor(self, action:get_duration())
end

function action_ease:start_with_target(target)
	self.m_action:start_with_target(target)
	action_interval.start_with_target(self, target)
end

function action_ease:get_action()
	return self.m_action
end

function action_ease:convert_time( dt )
	return dt
end

function action_ease:update( dt )
	self.m_action:update( self:convert_time( dt ) )
end

return action_ease