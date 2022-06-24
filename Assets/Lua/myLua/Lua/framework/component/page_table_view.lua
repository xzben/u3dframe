local table_view = require("framework.component.table_view")
local page_table_view = class("page_table_view", table_view)

function page_table_view:ctor( ...)
	self.m_addSize = 0
	table_view.ctor(self, ...)
end

function page_table_view:init_core( gameObject )
	self.m_core = gameObject.transform:GetComponent(typeof(PageTableView))
end

-- 设置回调函数在触发 滑动到列表边缘触发了获取事件时
-- func = function( isDown )  
-- isDown bool 代表是向下触发,还是向上
function page_table_view:set_load_callback( func )
	self.m_core:setDoLoadCallback(func)
end

-- 设置回调函数用于update 更新我们 loading node
-- func = function( loadingNode, isInit, deltaTime )  
-- loadingNode  loading 状态节点对象
-- isInit 代表是否第一次触发更新 loading 用于初始化节点用
-- deltaTime 代表 控制运动的 delta 事件
function page_table_view:set_update_node_callback( func )
	self.m_core:setUpdateNodeFunc(func)
end

return page_table_view