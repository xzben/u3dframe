local action_helper = class("action_helper")
local Vector3 = UnityEngine.Vector3

function action_helper:rotationX( transform, speed, dt)
	return self:rotation(transform, Vector3(speed, 0, 0), dt)
end

function action_helper:rotationY(transform, speed, dt)
	return self:rotation(transform, Vector3(0, speed, 0), dt)
end

function action_helper:rotationZ(transform, speed, dt)
	return self:rotation(transform, Vector3(0, 0, speed), dt)
end

function action_helper:rotation(transform, speed, dt)
	local dt = dt or Time.deltaTime
	local x = speed.x * dt
	local y = speed.y * dt
	local z = speed.z * dt 
	-- log.d("################## rotation", x, y, z, speed.z, dt)
	transform:Rotate(x, y, z )
end


function action_helper:moveX( transform, speed, dt)
	return self:move(transform, Vector3(speed, 0, 0), dt)
end

function action_helper:moveY( transform, speed, dt)
	return self:move(transform, Vector3(0, speed, 0), dt)
end

function action_helper:moveZ( transform, speed, dt)
	return self:move(transform, Vector3(0, 0, speed), dt)
end

function action_helper:move( transform, speed, dt)
	local oldPos = transform.position
	transform.position = Vector3(oldPos.x + speed.x*dt, oldPos.y + speed.y*dt, oldPos.z + speed.z*dt)
end

return action_helper