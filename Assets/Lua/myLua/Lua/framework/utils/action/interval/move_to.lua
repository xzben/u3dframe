local action_interval = require("framework.utils.action.action_interval")
local move_to = class("move_to", action_interval)


--- dt 秒为单位
--- position Vector3
function move_to:ctor( dt, position )
	self.m_endPosition = position
	action_interval.ctor(self, dt)
end

function move_to:start_with_target( target )
	self.m_startPos = target.localPosition
	self.m_detaPos = self.m_endPosition - self.m_startPos
	action_interval.start_with_target(self, target)
end

function move_to:update(dt)
	local x = self.m_startPos.x + self.m_detaPos.x*dt
	local y = self.m_startPos.y + self.m_detaPos.y*dt
	local z = self.m_startPos.z + self.m_detaPos.z*dt

	self.m_target.localPosition = Vector3(x, y, z)
end

return move_to