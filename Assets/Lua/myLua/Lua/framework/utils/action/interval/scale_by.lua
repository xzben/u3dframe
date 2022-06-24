local action_interval = require("framework.utils.action.action_interval")
local scale_by = class("scale_by", action_interval)

--- dt 秒为单位
--- detaScale Vector3
function scale_by:ctor( dt, detaScale )
	self.m_detaScale = detaScale
	action_interval.ctor(self, dt)
end

function scale_by:start_with_target( target )
	self.m_startScale = target.localScale 
	action_interval.start_with_target(self, target)
end

function scale_by:update(dt)
	local x = self.m_startScale.x + self.m_detaScale.x*dt
	local y = self.m_startScale.y + self.m_detaScale.y*dt
	local z = self.m_startScale.z + self.m_detaScale.z*dt
	
	self.m_target.localScale = Vector3(x, y, z)
end

return scale_by