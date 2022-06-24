local action_interval = require("framework.utils.action.action_interval")
local fade_in = class("fade_in", action_interval)

function fade_in:ctor( dt )
	action_interval.ctor(self, dt)
end

function fade_in:start_with_target( target )
	self.m_imageComp = target:GetComponent("Image")
	assert(self.m_imageComp, "fade_in must have Image Component")
	action_interval.start_with_target(self, target)
end

function fade_in:update(dt)
	local curColor = self.m_imageComp.color
	self.m_imageComp.color = UnityEngine.Color(curColor.r, curColor.g, curColor.b, dt)
end

return fade_in