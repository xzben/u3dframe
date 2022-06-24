local action_ease = require("framework.utils.action.action_ease")
local ease_cubic_action_in = class("ease_cubic_action_in", action_ease)

function ease_cubic_action_in:ctor( action )
    action_ease.ctor(self, action)
end

function ease_cubic_action_in:convert_time(time)
	return time*time*time
end

return ease_cubic_action_in