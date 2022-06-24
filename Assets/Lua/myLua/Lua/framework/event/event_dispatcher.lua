---
---
---
local listener_item = class("listener_item")

--@field #any  event
listener_item.event = nil
--@field #Object  owner
listener_item.owner = nil
--@field #function callback
listener_item.callback  = nil
--@field #boolean isPause
listener_item.isPause = nil
--@field #boolean isValid 
listener_item.isValid = nil
--@field #number 监听有效次数  -1 代表无数次
listener_item.count = -1
--@field #number 事件派发优先级
listener_item.order = 0

function listener_item:ctor(event, callback, owner, count, order)
	self.event = event
	self.callback = callback
	self.owner = owner
	self.isValid = true
	self.isPause = false
	self.waitToAdd = false
	self.count = count or -1
	self.order = order or 0
end

function listener_item:onHandle( ... )
	if not self.isValid or self.isPause or self.waitToAdd then return end
	local params = {...}

	if self.count > 0 then
		self.count = self.count - 1
	end

	if self.count == 0 then
		self.isValid = false
	end 

	if self.owner ~= nil then
		xpcall_func(function() 
			self.callback(self.owner, unpack(params))
		end)
	else
		xpcall_func(function() 
			self.callback(unpack(params))
		end)
	end
end

local event_dispatcher = class("event_dispatcher")

local kNoOwnerKey = "__NoOwnerKey__"
local kAllEvent   = "__AllEventKey__"

--@field  map_table#map_table  m_listeners { [event] = { [owner] = {listener_item, listener_item...} } }
event_dispatcher.m_listeners = nil
--@field #boolean m_isDispatching 
event_dispatcher.m_isDispatching = nil

function event_dispatcher:ctor()
	self.m_listeners = {}
	self.m_curDisEvents = {}
	self.m_isDispatching = false
end

local function _sortEventList( list )
	table.sort(list, function(a, b)
		return a.order > b.order
	end)
end

local function _removeInValidAndDoAddNewListeners(self)
	for event, listeners in pairs(self.m_listeners) do
		for owner, itemLists in pairs(listeners) do
			local len = #itemLists
			for i = len, 1, -1 do
				local item = itemLists[i]
				if not item.isValid then
					table.remove(itemLists, i)
				end

				item.waitToAdd = false
			end
		end
	end
end

local function retainEventDispatcher( self, event)
	if self.m_curDisEvents[event] == nil then
		self.m_curDisEvents[event] = 0
	end
	self.m_curDisEvents[event] = self.m_curDisEvents[event] + 1
end

local function releaseEventDispatcher(self, event)
	if self.m_curDisEvents[event] == nil then
		self.m_curDisEvents[event] = 0
	end
	self.m_curDisEvents[event] = self.m_curDisEvents[event] - 1
	if self.m_curDisEvents[event] < 0 then
		self.m_curDisEvents[event] = 0
	end
end

local function getEventDispatcherCount(self, event)
	if nil == self.m_curDisEvents[event] then
		return 0
	end

	return self.m_curDisEvents[event]
end


function event_dispatcher:dispatch( event, ...)
	assert(event ~= nil, "the event can't been nil")
	self.m_isDispatching = true
	retainEventDispatcher(self, event)

	local listeners = self.m_listeners[kAllEvent] or {}
	for owner, itemList in pairs(listeners) do
		for _, item in ipairs(itemList) do
			item:onHandle(event, ...)
		end
	end

	local listeners = self.m_listeners[event] or {}
	local needDoList = {}
	for owner, itemList in pairs(listeners) do
		for _, item in ipairs(itemList) do
			table.insert(needDoList, item)
		end
	end
	_sortEventList(needDoList)

	for i, doItem in ipairs(needDoList) do
		doItem:onHandle(...)
	end

	self.m_isDispatching = false
	releaseEventDispatcher(self, event)
	_removeInValidAndDoAddNewListeners(self)
end

function event_dispatcher:insert( event, owner, callback, count, order)
	self:add_listener(event, callback, owner, count, order)
end

function event_dispatcher:remove(event, owner, callback)
	self:remove_listener(event, callback, owner)
end

function event_dispatcher:add_listener_once(event, callback, owner)
	self:add_listener(event, callback, owner, 1)
end

function event_dispatcher:add_listener( event, callback, owner, count, order)
	assert(event ~= nil, "the event can't been nil")
	assert(type(callback) == "function", "the callback must been function")

	local item = listener_item.new(event, callback, owner, count or -1, order or 0)
	item.waitToAdd = self.m_isDispatching and getEventDispatcherCount(self, event) > 0

	if self.m_listeners[event] == nil then
		self.m_listeners[event] = {}
	end

	local keyOwner = owner or kNoOwnerKey
	local itemLists = self.m_listeners[event][keyOwner]

	if itemLists == nil then
		itemLists = {}
		self.m_listeners[event][keyOwner] = itemLists
	end

	table.insert(itemLists, item)
end

function event_dispatcher:remove_listener( event, callback, owner )
	if self.m_listeners[event] == nil then return end
	local keyOwner = owner or kNoOwnerKey

	if self.m_listeners[event][keyOwner] == nil then return end

	local itemLists = self.m_listeners[event][keyOwner]
	local len = #itemLists
	for idx = len, 1, -1 do
		local item = itemLists[idx]
		if item.callback == callback then
			item.isValid = false
			if not self.m_isDispatching then
				table.remove(itemLists, idx)
			end
		end
	end
end

function event_dispatcher:remove_listener_by_event(event)
	assert(event ~= nil, "the event must not been nil")

	if  self.m_listeners[event] == nil then
		return
	end

	if self.m_isDispatching then
		for kOwner, itemLists in pairs(self.m_listeners[event] or {}) do
			for _, item in ipairs(itemLists or {}) do
				item.isValid = false
			end
		end
	else
		self.m_listeners[event] = nil
	end
end

function event_dispatcher:removeListener_by_owner( owner, event)
	assert(owner ~= nil, "the owner must not been nil")

	if event ~= nil and self.m_listeners[event] ~= nil then
		if self.m_isDispatching then
			for _, item in ipairs(self.m_listeners[event][owner] or {}) do
				item.isValid = false
			end
		else
			self.m_listeners[event][owner] = nil
		end
	elseif event == nil then
		if self.m_isDispatching then
			for k, listeners in pairs(self.m_listeners or {}) do
				for _, item in ipairs(listeners[owner] or {}) do
					item.isValid = false
				end
			end
		else
			for k, listeners in pairs(self.m_listeners) do
				listeners[owner] = nil
			end
		end
	end
end

local function _setListenerItemsStatus( self, itemLists, isPause)
	assert(type(isPause) == "boolean", "the param isPause must be boolean")
	for _, item in ipairs(itemLists or {}) do
		item.isPause = isPause
	end
end

function event_dispatcher:set_listener_status_by_owner( owner, isPause)
	if owner == nil then return end

	for kEvent, listeners in pairs(self.m_listeners) do
		for kOwner, itemLists in pairs(listeners) do
			if kOwner == owner then
				_setListenerItemsStatus(self, itemLists, isPause)
			end
		end
	end
end

function event_dispatcher:set_event_listener_status_by_onwer( event, owner, isPause)
	if event == nil or owner == nil or  self.m_listeners[event] == nil then return end

	for kOwner, itemLists in pairs(listeners) do
		if kOwner == owner then
			_setListenerItemsStatus(self, itemLists, isPause)
		end
	end
end

function event_dispatcher:add_all_event_listener( func, owner)
	self:addListener(kAllEvent, func, owner)
end

function event_dispatcher:remove_all_event_listener( func, owner)
	self:removeListener(kAllEvent, func, owner)
end

function event_dispatcher:dtor()

end

return event_dispatcher