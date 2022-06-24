local action_interval = require("framework.utils.action.action_interval")
local fade_out = class("fade_out", action_interval)

function fade_out:ctor( dt )
	action_interval.ctor(self, dt)
end

function fade_out:start_with_target( target )
	self.m_imageComp = target:GetComponent("Image")
	assert(self.m_imageComp, "fade_out must have Image Component")
	action_interval.start_with_target(self, target)
end

function fade_out:update(dt)
	local curColor = self.m_imageComp.color
	self.m_imageComp.color = UnityEngine.Color(curColor.r, curColor.g, curColor.b, (1-dt))
end

return fade_out