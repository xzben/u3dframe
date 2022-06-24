local ui_base = require("framework.mvp.ui_base")
local table_view = class("table_view", ui_base)


--[[
local  obj =  编辑器上拖拽好的 ScrollView 组件并绑定了 TableView 脚本的 gameObject
local temp = import("framework.utils.table_view")
local tbObj = temp.table_view.new(obj)

cell更新方法：
	方法一、设置 单元的class实现，必须是继承 table_view_cell 的子类
	tbObj:set_cell_class(temp.table_view_cell)  

	方法二、设置 更新函数
	tbObj:set_cell_update_func(function(gameObject, index, data)
	    gameObject.transform:Find("Text"):GetComponent("Text").text = string.format("nor update func item index: %d", data.index)
	end)
	
	tbObj:set_cell_awak_func( function(gameObject, table_view_cell) 
		utils.ui.add_click_callback(gameObject, function() 
			local index = table_view_cell:getCurIndex();
			local data = table_view_cell:getData()
		end)
	end)
tbObj:set_data({ { index = 1;}, { index = 2;}, { index = 3;}, { index = 4;},{ index = 5;}, { index = 6;}, { index = 7;}, { index = 8;},{ index = 9;}, { index = 10;}, { index = 11;}, { index = 12;}})
tbObj:reload_data()

--]]

function table_view:ctor( gameObject )
	ui_base.ctor(self, gameObject)
	self:init_core( gameObject )
end

function table_view:init_core( gameObject )
	self.m_core = gameObject.transform:GetComponent(typeof(TableView))
end

function table_view:set_data( data )
	self.m_data = data
	self.m_core:setData(data)
end

function table_view:get_data_size()
	return #(self.m_data or {})
end

-- 这里和 set_cell_class 只需要设置一种就行，默认取 set_cell_class 的效果
-- 除非是简单的 cell 否则还是建议使用 set_cell_class 用专门的cell class 管理cell逻辑比较合适
function table_view:set_cell_update_func( func )
	self.m_core:setUpdateCellFunc( func )
end

-- 这里和 set_cell_update_func 只需要设置一种就行，默认取 set_cell_class 的效果
function table_view:set_cell_class( cellclasss, cellArgs )
	self.m_core:setCellClass(cellclasss, cellArgs)
end

-- 这里设置 cell 的init callback，用于在cell构造时调用，用于做 item callback之类的操作
function table_view:set_cell_awak_func( func )
	self.m_core:setCellAwakFunc( func )
end

function table_view:reload_data( keepOffset, forceUpdate)
	if keepOffset == nil then keepOffset = false end
	if forceUpdate == nil then forceUpdate = false end

	if self.m_data == nil then
		g_log.d("please set data first")
		return;
	end
	self.m_core:reloadData(keepOffset, forceUpdate)
end

function table_view:get_view_size()
	local uiroot = self:get_root_node()
	local rt = uiroot.gameObject:GetComponent("RectTransform")
	return Vector2.New(rt.sizeDelta.x, rt.sizeDelta.y)
end

function table_view:set_view_size(width, height)
	local uiroot = self:get_root_node()
	local rt = uiroot.gameObject:GetComponent("RectTransform")
	rt.sizeDelta = Vector2.New(width, height)	
end

--当table view size 变化时需要驱动这个来更新界面的显示
function table_view:update_view_size()
	self.m_core:InitComponent()
	self:reload_data(true)
end

return table_view