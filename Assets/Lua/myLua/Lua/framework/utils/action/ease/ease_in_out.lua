local action_ease_rate = require("framework.utils.action.action_ease_rate")
local ease_in_out = class("ease_in_out", action_ease_rate)

function ease_in_out:ctor( action, rate)
    action_ease_rate.ctor(self, action, rate)
end

function ease_in_out:convert_time(dt)
	local time = dt*2

	if time < 1 then
		return 0.5 * math.pow(time, self.m_rate)
	else
		return (1 - 0.5*math.pow(2-time, self.m_rate))
	end
end

return ease_in_out