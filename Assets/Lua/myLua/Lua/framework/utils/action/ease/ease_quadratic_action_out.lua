local action_ease = require("framework.utils.action.action_ease")
local ease_quadratic_action_out = class("ease_quadratic_action_out", action_ease)

function ease_quadratic_action_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_quadratic_action_out:convert_time(time)
    return -1*time*(time-2);
end

return ease_quadratic_action_out