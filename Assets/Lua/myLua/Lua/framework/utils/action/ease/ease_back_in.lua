local action_ease = require("framework.utils.action.action_ease")
local ease_back_in = class("ease_back_in", action_ease)

local overshoot = 1.70158

function ease_back_in:ctor( action )
	action_ease.ctor(self, action)
end

function ease_back_in:convert_time(dt)
	return dt*dt*((overshoot+1)*dt - overshoot);
end

return ease_back_in