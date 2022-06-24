local action_ease = require("framework.utils.action.action_ease")
local ease_back_in_out = class("ease_back_in_out", action_ease)

local overshoot = 2.5949095 --1.70158 * 1.525;


function ease_back_in_out:ctor( action )
	action_ease.ctor(self, action)
end

function ease_back_in_out:convert_time(dt)
	dt = dt*2

	if dt < 1 then
		return (dt*dt*((overshoot + 1)*dt - overshoot))/2;
	else
		dt = dt - 2
		return (dt*dt *((overshoot+1)*dt + overshoot))/2 + 1;
	end
end

return ease_back_in_out