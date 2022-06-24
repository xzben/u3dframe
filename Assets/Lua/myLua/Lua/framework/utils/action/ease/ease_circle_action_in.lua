local action_ease = require("framework.utils.action.action_ease")
local ease_circle_action_in = class("ease_circle_action_in", action_ease)

function ease_circle_action_in:ctor( action )
    action_ease.ctor(self, action)
end

function ease_circle_action_in:convert_time(dt)
	return -1 * ( math.sqrt(1-dt*dt) - 1 )
end

return ease_circle_action_in