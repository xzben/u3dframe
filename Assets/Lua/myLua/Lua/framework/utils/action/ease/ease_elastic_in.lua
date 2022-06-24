local action_ease = require("framework.utils.action.action_ease")
local ease_elastic_in = class("ease_elastic_in", action_ease)

local M_PI_X_2 = 6.28318530716 --3.14159265358 * 2.0

function ease_elastic_in:ctor( action, period )
	self.m_period = period == nil and 0.3 or period
    action_ease.ctor(self, action)
end


function ease_elastic_in:convert_time(time)
 	local newT = 0;
    if (time == 0 or time == 1) then
        newT = time;
    else
        local s = self.m_period / 4;
        time = time - 1;
        newT = -1*math.pow(2, 10 * time) * math.sin((time - s) * M_PI_X_2 / self.m_period);
    end

    return newT;
end

return ease_elastic_in