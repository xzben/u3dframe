local action_ease = require("framework.utils.action.action_ease")
local ease_elastic_out = class("ease_elastic_out", action_ease)

local M_PI_X_2 = 6.28318530716 --3.14159265358 * 2.0

function ease_elastic_out:ctor( action, period )
	self.m_period = period == nil and 0.3 or period
    action_ease.ctor(self, action)
end


function ease_elastic_out:convert_time(time)
	local newT = 0;
    if (time == 0 or time == 1) then
        newT = time;
    else
        local s = self.m_period / 4;
        newT = math.pow(2, -10 * time) * math.sin((time - s) * M_PI_X_2 / self.m_period) + 1;
    end

    return newT;
end

return ease_elastic_out