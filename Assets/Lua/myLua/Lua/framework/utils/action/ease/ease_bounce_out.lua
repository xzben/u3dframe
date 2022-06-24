local action_ease = require("framework.utils.action.action_ease")
local ease_bounce_out = class("ease_bounce_out", action_ease)

function ease_bounce_out:ctor( action )
    action_ease.ctor(self, action)
end

local c_1_div_2_27 = 1/2.75
local c_1_5_div_2_27 = 1.5/2.75
local c_2_div_2_27 = 2/2.75
local c_2_5_div_2_27 = 2.5/2.75
local c_2_25_div_2_27 = 2.25 / 2.75
local c_2_625_div_2_27 =  2.625 / 2.75

local function bounceTime(time)
    if time < c_1_div_2_27 then
        return 7.5625 * time * time;
    elseif (time < c_2_div_2_27) then
        time = time - c_1_5_div_2_27;
        return 7.5625 * time * time + 0.75;
    elseif(time < c_2_5_div_2_27) then
        time =  time - c_2_25_div_2_27;
        return 7.5625 * time * time + 0.9375;
    end
    time = time - c_2_625_div_2_27;
    return 7.5625 * time * time + 0.984375;
end

function ease_bounce_out:convert_time(dt)
	return bounceTime(dt);
end

return ease_bounce_out