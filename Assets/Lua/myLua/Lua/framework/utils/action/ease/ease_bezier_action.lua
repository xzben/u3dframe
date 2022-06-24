local action_ease = require("framework.utils.action.action_ease")
local ease_bezier_action = class("ease_bezier_action", action_ease)

function ease_bezier_action:ctor( action, p0, p1, p2, p3)
    self.m_p0 = p0
    self.m_p1 = p1
    self.m_p2 = p2
    self.m_p3 = p3

    action_ease.ctor(self, action)
end

function ease_bezier_action:convert_time(dt)
	local a, b, c, d, t = self.m_p0, self.m_p1, self.m_p2, self.m_p3, dt

    return (math.pow(1-t,3) * a + 3*t*(math.pow(1-t,2))*b + 3*math.pow(t,2)*(1-t)*c + math.pow(t,3)*d)
end

return ease_bezier_action