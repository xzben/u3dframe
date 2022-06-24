local action_interval = require("framework.utils.action.action_interval")
local scale_to = class("scale_to", action_interval)


--- dt 秒为单位
--- scale Vector3
function scale_to:ctor( dt, scale )
	self.m_endScale = scale
	action_interval.ctor(self, dt)
end

function scale_to:start_with_target( target )
	local curScale = target.localScale
	self.m_startScale = curScale
	self.m_detaScale = self.m_endScale - self.m_startScale
	action_interval.start_with_target(self, target)
end

function scale_to:update(dt)
	local x = self.m_startScale.x + self.m_detaScale.x*dt
	local y = self.m_startScale.y + self.m_detaScale.y*dt
	local z = self.m_startScale.z + self.m_detaScale.z*dt
	
	self.m_target.localScale = Vector3(x, y, z)
end

return scale_to