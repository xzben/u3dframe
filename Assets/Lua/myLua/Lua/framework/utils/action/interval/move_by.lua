local action_interval = require("framework.utils.action.action_interval")
local move_by = class("move_by", action_interval)

--- dt 秒为单位
--- detaPos Vector3
function move_by:ctor( dt, detaPos )
	self.m_detaPos = detaPos
	action_interval.ctor(self, dt)
end

function move_by:start_with_target( target )
	self.m_startPos = target.localPosition
	action_interval.start_with_target(self, target)
end

function move_by:update(dt)
	local x = self.m_startPos.x + self.m_detaPos.x*dt
	local y = self.m_startPos.y + self.m_detaPos.y*dt
	local z = self.m_startPos.z + self.m_detaPos.z*dt

	self.m_target.localPosition = Vector3(x, y, z)
end

return move_by