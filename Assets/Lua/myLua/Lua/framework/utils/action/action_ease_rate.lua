local action_ease = require("framework.utils.action.action_ease")
local action_ease_rate = class("action_ease_rate", action_ease)

function action_ease_rate:ctor( action, rate )
	self:set_rate(rate)
	action_ease.ctor(self, action)
end

function action_ease_rate:set_rate( rate )
	self.m_rate = rate
end

function action_ease_rate:get_rate()
	return self.m_rate
end

function action_ease_rate:convert_time( dt )
	return dt
end

return action_ease_rate