--[[
	联合 table  可以快速的当成 数组和 map 使用
	使用条件  item 必须有个一个 main_key 元素用来区分元素的差异

	example :
		local tbl = union_table.new("name")

		tbl:insert({ name = "jerry"; })
		tbl:insert({ name = "tom"; })
		tbl:insert({ name = "cat"; })

		tbl:isExitsByKey("jerry")   return true
		tbl:getItemByKey("jerry")   return { name = "jerry"}
--]]

local union_table = class("union_table")

function union_table:ctor(mainKey)
	self.m_mainKey = mainKey
	self.m_array = {}
	self.m_map = {}
end

local function _removeMapItem( self, item )
	if item == nil then return end
	self.m_map[item[self.m_mainKey]] = nil
end

local function _addMapItem( self, item)
	if item == nil then return end
	self.m_map[item[self.m_mainKey]] = item
end

function union_table:isExits( item )
	return self:isExitsByKey( item[self.m_mainKey] )
end

function union_table:isExitsByKey( mainKey )
	return nil ~= self.m_map[mainKey]
end

function union_table:insert( pos, item )
	if item == nil then
		item = pos
		pos = nil
	end

	if self:isExits(item) then 
		return 
	end
	_addMapItem(self, item)
	if pos ~= nil then
		table.insert(self.m_array, pos, item)
	else
		table.insert(self.m_array, item)
	end
end

function union_table:remove(pos)
	local removeItem = nil
	if pos ~= nil then
		removeItem = table.remove(self.m_array)
	else
		removeItem = table.remove(self.m_array, pos)
	end
	_removeMapItem(self, removeItem)
end

function union_table:removeByKey( mainKey )
	local removeItem = self.m_map[mainKey]
	if removeItem == nil then return end

	for i = #self.m_array, 1, -1 do
		local item = self.m_array[i]

		if item[self.m_mainKey] == mainKey then
			table.remove(self.m_array, i)
			return;
		end
	end 
end

function union_table:sort( func )
	table.sort(self.m_array, func)
end

function union_table:getArray()
	return self.m_array
end

function union_table:foreach( func )
	for k, v in ipairs(self.m_array) do
		func(v)
	end
end

function union_table:getMap()
	return self.m_map
end

function union_table:getItemByKey( mainKey )
	return self.m_map[mainKey]
end

function union_table:getSize()
	return #self.m_array
end

return union_table