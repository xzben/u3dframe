local action_ease = require("framework.utils.action.action_ease")
local ease_quadratic_action_in = class("ease_quadratic_action_in", action_ease)

function ease_quadratic_action_in:ctor( action )
    action_ease.ctor(self, action)
end

function ease_quadratic_action_in:convert_time(time)
    return  math.pow(time,2);
end

return ease_quadratic_action_in