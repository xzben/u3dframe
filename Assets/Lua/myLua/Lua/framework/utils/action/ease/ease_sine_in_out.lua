local action_ease = require("framework.utils.action.action_ease")
local ease_sine_in_out = class("ease_sine_in_out", action_ease)

local M_PI  =  3.14159265358

function ease_sine_in_out:ctor( action )
    action_ease.ctor(self, action)
end

function ease_sine_in_out:convert_time(time)
    return -0.5 * (math.cos(M_PI * time) - 1);
end

return ease_sine_in_out