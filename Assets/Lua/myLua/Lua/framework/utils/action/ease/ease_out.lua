local action_ease_rate = require("framework.utils.action.action_ease_rate")
local ease_out = class("ease_out", action_ease_rate)

function ease_out:ctor( action, rate)
    action_ease_rate.ctor(self, action, rate)
end

function ease_out:set_rate( rate )
	self.m_rate = 1/rate
end

function ease_out:convert_time(dt)
	return math.pow(dt, self.m_rate)
end

return ease_out