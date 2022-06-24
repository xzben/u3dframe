local action_ease = require("framework.utils.action.action_ease")
local ease_circle_action_in_out = class("ease_circle_action_in_out", action_ease)

function ease_circle_action_in_out:ctor( action )
    action_ease.ctor(self, action)
end


function ease_circle_action_in_out:convert_time(time)
    local time = time * 2;
    if (time < 1) then
        return -0.5 * (math.sqrt(1 - time * time) - 1);
    end
    time =  time - 2;
    return 0.5 * (math.sqrt(1 - time * time) + 1);
end

return ease_circle_action_in_out