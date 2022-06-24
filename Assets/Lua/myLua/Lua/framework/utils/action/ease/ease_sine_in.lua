local action_ease = require("framework.utils.action.action_ease")
local ease_sine_in = class("ease_sine_in", action_ease)

local M_PI_2 = 1.57079632679

function ease_sine_in:ctor( action )
    action_ease.ctor(self, action)
end

function ease_sine_in:convert_time(time)
    return -1 * math.cos(time * M_PI_2) + 1;
end

return ease_sine_in