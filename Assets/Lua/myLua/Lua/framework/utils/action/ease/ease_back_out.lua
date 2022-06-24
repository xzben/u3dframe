local action_ease = require("framework.utils.action.action_ease")
local ease_back_out = class("ease_back_out", action_ease)

local overshoot = 1.70158

function ease_back_out:ctor( action )
	action_ease.ctor(self, action)
end

function ease_back_out:convert_time(dt)
	dt = dt - 1

	return dt*dt*((overshoot+1)*dt + overshoot) + 1;
end

return ease_back_out