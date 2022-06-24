local action_ease = require("framework.utils.action.action_ease")
local ease_circle_action_out = class("ease_circle_action_out", action_ease)

function ease_circle_action_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_circle_action_out:convert_time(time)
    local time = time - 1;
    return math.sqrt(1 - time * time);
end

return ease_circle_action_out