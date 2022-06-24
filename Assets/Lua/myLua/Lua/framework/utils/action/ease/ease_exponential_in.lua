local action_ease = require("framework.utils.action.action_ease")
local ease_exponential_in = class("ease_exponential_in", action_ease)

function ease_exponential_in:ctor( action )
    action_ease.ctor(self, action)
end


function ease_exponential_in:convert_time(time)
    return time == 0 and 0 or (math.pow(2, 10 * (time/1 - 1)) - 1 * 0.001);
end

return ease_exponential_in