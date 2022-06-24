local action_ease = require("framework.utils.action.action_ease")
local ease_sine_out = class("ease_sine_out", action_ease)

local M_PI_2 = 1.57079632679

function ease_sine_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_sine_out:convert_time(time)
    return math.sin(time * M_PI_2);
end

return ease_sine_out