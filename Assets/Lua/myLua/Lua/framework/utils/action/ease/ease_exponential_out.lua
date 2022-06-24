local action_ease = require("framework.utils.action.action_ease")
local ease_exponential_out = class("ease_exponential_out", action_ease)

function ease_exponential_out:ctor( action )
    action_ease.ctor(self, action)
end


function ease_exponential_out:convert_time(time)
    return time == 1 and 1 or (-1*math.pow(2, -10 * time / 1) + 1);
end

return ease_exponential_out