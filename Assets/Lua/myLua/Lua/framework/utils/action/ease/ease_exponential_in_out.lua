local action_ease = require("framework.utils.action.action_ease")
local ease_exponential_in_out = class("ease_exponential_in_out", action_ease)

function ease_exponential_in_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_exponential_in_out:convert_time(time)
    if(time == 0 or time == 1) then
        return time;
    end
    
    if (time < 0.5) then
        return 0.5 * math.pow(2, 10 * (time * 2 - 1));
    end

    return 0.5 * (-1*math.pow(2, -10 * (time * 2 - 1)) + 2);
end

return ease_exponential_in_out