local ui_base = require("framework.mvp.ui_base")
local table_view_cell = class("table_view_cell", ui_base)

function table_view_cell:ctor( gameObject)
	ui_base.ctor(self, gameObject)
	self:init(gameObject)
end

function table_view_cell:init( gameObject )
	local cellCmp = gameObject.transform:GetComponent(typeof(TableViewCell))
	cellCmp:reset(function(gameObject, index, data) 
		self:update_data(index, data)
	end)
end

function table_view_cell:on_init()
	
end

--- 此接口为统一用来初始化界面使用，不重写则可以自己选择构造函数一个合适时机初始化界面使用
function table_view_cell:on_init()
	
end

-- 必须具体实现 的类重写用于更新 cell 界面样式
function table_view_cell:update_data(index, data)
	-- self:get_child_by_name("Text", "Text").text = string.format("cell item index: %d", data.index)
end

return table_view_cell