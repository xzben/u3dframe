local action_interval = require("framework.utils.action.action_interval")
local rotation_by = class("rotation_by", action_interval)

--- dt 秒为单位
--- dtRotation Vector3
function rotation_by:ctor( dt, detaRotation )
	self.m_detaRotation = detaRotation
	self.m_last_rotation_dt = 0
	action_interval.ctor(self, dt)
end

function rotation_by:reset()
	self.m_last_rotation_dt = 0
	action_interval.reset(self)
end

function rotation_by:start_with_target( target )
	action_interval.start_with_target(self, target)
end

function rotation_by:update(dt)
	local offset = dt - self.m_last_rotation_dt
	self.m_last_rotation_dt = dt
	local dx = self.m_detaRotation.x*offset
	local dy = self.m_detaRotation.y*offset
	local dz = self.m_detaRotation.z*offset

	self.m_target:Rotate(dx, dy, dz)
end

return rotation_by