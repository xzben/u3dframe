local action_ease = require("framework.utils.action.action_ease")
local ease_quartic_action_in = class("ease_quartic_action_in", action_ease)

function ease_quartic_action_in:ctor( action )
    action_ease.ctor(self, action)
end

function ease_quartic_action_in:convert_time(time)
    return time * time * time * time;
end

return ease_quartic_action_in