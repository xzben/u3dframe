local action_ease_rate = require("framework.utils.action.action_ease_rate")
local ease_in = class("ease_in", action_ease_rate)

function ease_in:ctor( action, rate)
    action_ease_rate.ctor(self, action, rate)
end

function ease_in:convert_time(dt)
	return math.pow(dt, self.m_rate)
end

return ease_in