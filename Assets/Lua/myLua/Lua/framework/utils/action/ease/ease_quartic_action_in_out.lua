local action_ease = require("framework.utils.action.action_ease")
local ease_quartic_action_in_out = class("ease_quartic_action_in_out", action_ease)

function ease_quartic_action_in_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_quartic_action_in_out:convert_time(time)
    local time = time*2;
    if (time < 1) then
        return 0.5 * time * time * time * time;
    end
    time = time - 2;
    return -0.5 * (time * time * time * time - 2);
end

return ease_quartic_action_in_out