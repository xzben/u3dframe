local action_manager = class("action_manager")

function action_manager:ctor()
	self.m_actions = {}
end


function action_manager:add_action( action, target, running, owner )
	assert(owner)
	assert(target)
	assert(running ~= nil)
	local curOwnerActions = self.m_actions[owner]
	if curOwnerActions == nil then
		curOwnerActions = { running = running; ownerActions = {} }
		self.m_actions[owner] = curOwnerActions
	end

	local curActions = curOwnerActions.ownerActions[target]
	if nil ==  curActions then
		curActions = { running = running; targetActions = {} }
		curOwnerActions.ownerActions[target] = curActions
	end

	curActions.targetActions[action] = true
	action:set_running(running)
	action:start_with_target(target)
	action:set_owner(owner)
	
	return action
end

function action_manager:remove_all_action_from_owner( owner )
	self.m_actions[owner] = nil
end

function action_manager:remove_action( action )
	local owner = action:get_owner()
	if owner == nil then return end
	local curOwnerActions = self.m_actions[owner]
	if curOwnerActions == nil then return end
	local curActions = curOwnerActions.ownerActions[action:get_target()]
	if nil ==  curActions then return end
	curActions.targetActions[action] = nil
end

function action_manager:pause_owner( owner )
	local curOwnerActions = self.m_actions[owner]
	if curOwnerActions == nil then return end

	curOwnerActions.running = false
end

function action_manager:resume_owner( owner )
	local curOwnerActions = self.m_actions[owner]
	if curOwnerActions == nil then return end

	curOwnerActions.running = true
end

function action_manager:pause_target( owner, target )
	local curOwnerActions = self.m_actions[owner]
	if curOwnerActions == nil then return end
	local curActions = curOwnerActions.ownerActions[target]
	if nil ==  curActions then return end
	curActions.running = false
end

function action_manager:resume_target(owner, target )
	local curOwnerActions = self.m_actions[owner]
	if curOwnerActions == nil then return end
	local curActions = curOwnerActions.ownerActions[target]
	if nil ==  curActions then return end
	curActions.running = true
end

function action_manager:update( dt )
	local needRemoveOwner = {}
	for owner, item in pairs(self.m_actions) do
		if item.running then
			local needRemoveTargets = {}
			local targetCount = 0

			for target, targetItem in pairs(item.ownerActions) do
				targetCount = targetCount + 1
				if targetItem.running then
					local removes = {}
					local count = 0
					for action, _ in pairs(targetItem.targetActions) do
						count = count + 1
						if action:is_running() then
							action:step(dt)
						end

						if action:is_done() then
							table.insert(removes, action)
						end
					end

					for _, action in ipairs(removes) do
						targetItem.targetActions[action] = nil
					end

					if #removes == count then
						table.insert(needRemoveTargets, target)
					end
				end
			end

			if #needRemoveTargets >= targetCount then
				table.insert(needRemoveOwner, owner)
			else
				for _, target in ipairs(needRemoveTargets) do
					item.ownerActions[target] = nil
				end
			end
		end
	end

	for _, owner in ipairs(needRemoveOwner) do
		self.m_actions[owner] = nil
	end
end

return action_manager