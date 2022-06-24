local action_ease = require("framework.utils.action.action_ease")
local ease_quartic_action_out = class("ease_quartic_action_out", action_ease)

function ease_quartic_action_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_quartic_action_out:convert_time(time)
    local time = time - 1;
    return -1 * (time * time * time * time - 1);
end

return ease_quartic_action_out