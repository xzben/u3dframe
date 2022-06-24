local action_ease = require("framework.utils.action.action_ease")
local ease_quadratic_action_in_out = class("ease_quadratic_action_in_out", action_ease)

function ease_quadratic_action_in_out:ctor( action )
    action_ease.ctor(self, action)
end


function ease_quadratic_action_in_out:convert_time(time)
 	local resultTime = time;
    time = time*2;
    if time < 1 then
        resultTime = time * time * 0.5
    else
        resultTime = -0.5 * (time * (time - 2) - 1);
    end

    return resultTime;
end

return ease_quadratic_action_in_out