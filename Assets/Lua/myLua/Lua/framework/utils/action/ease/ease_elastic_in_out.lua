local action_ease = require("framework.utils.action.action_ease")
local ease_elastic_in_out = class("ease_elastic_in_out", action_ease)

local M_PI_X_2 = 6.28318530716 --3.14159265358 * 2.0

function ease_elastic_in_out:ctor( action, period )
	self.m_period = period == nil and 0.3 or period
    action_ease.ctor(self, action)
end


function ease_elastic_in_out:convert_time(time)
	local period = self.m_period

	local newT = 0;
    if time == 0 or time == 1 then
        newT = time;
    else
        time = time * 2;
        if period == 0 then
            period = 0.45 --0.3 * 1.5;
        end

        local s = period / 4;

        time = time - 1;
        if (time < 0) then
            newT = -0.5 * math.pow(2, 10 * time) * math.sin((time -s) * M_PI_X_2 / period);
        else
            newT = math.pow(2, -10 * time) * math.sin((time - s) * M_PI_X_2 / period) * 0.5 + 1;
    	end
    end

    return newT;
end

return ease_elastic_in_out