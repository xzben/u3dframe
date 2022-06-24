local table_view = require("framework.component.table_view")
local dynamic_table_view = class("dynamic_table_view", table_view)

function dynamic_table_view:ctor( ...)
	table_view.ctor(self, ...)
end

function dynamic_table_view:init_core( gameObject )
	self.m_core = gameObject.transform:GetComponent(typeof(DynamicTableView))
end

-- 设置 获取cell size 的function   func = function(index, data) return size;
-- size 如果是垂直滚动代表 cell 的高度， 如果水平滚动代表 cell 的宽度
function dynamic_table_view:set_cell_size_func( func )
	self.m_core:SetCellSizeFunc(func)
end

-- 设置 cell 类型的获取函数  func =  function(index, data) return typeIndex
-- index 为 cell 的index 从 1开始
-- typeIndex  0 代表 m_cell 、 1~n 代表 m_other_cell_items 从1开始索引的预制体
function dynamic_table_view:set_cell_type_index_func( func )
	self.m_core:SetCellTypeIndex(func)
end

return dynamic_table_view