
local test_table_cell = class("test_table_cell", utils.table_view_cell)

function test_table_cell:ctor( gameObject, tableview)
	self.m_list = tableview
	utils.table_view_cell.ctor(self, gameObject)
end

--- 此接口为统一用来初始化界面使用，不重写则可以自己选择构造函数一个合适时机初始化界面使用
function test_table_cell:on_init()
	self.titleTxt = self:get_child_by_name("title", "Text")
	local gridNode = self:get_child_by_name("scroll_view")
	self.m_grid_list = utils.grid_view.new(gridNode)
	self.m_grid_list:set_cell_update_func(function(gameObject, index, data)
		local text = self:get_child_by_name(gameObject.transform, "title", "Text")
		text.text = data.title
	end)
	self.m_grid_list:set_cell_awak_func(function(gameObject, cell)
		self:add_click_callback(gameObject.transform, "btn", function() 
			local data = cell:getData()
			if data and data.func and type(data.func) == "function" then
				data.func(data)
			end
		end)
	end)

	self:add_click_callback("btn", function() 
		local cellData = self.m_data
		cellData.isClose = not cellData.isClose
		self.m_list:reload_data(true, true)
	end)
end

-- 必须具体实现 的类重写用于更新 cell 界面样式
function test_table_cell:update_data(index, data)
	self.m_data = data
	self.titleTxt.text = data.title

	if not self.m_data.isClose then
		local size = self.m_grid_list:get_view_size()
		self.m_grid_list:set_view_size(size.x, math.ceil(#self.m_data.list/3)*135)
		self.m_grid_list:set_data(self.m_data.list)
    	self.m_grid_list:reload_data(true)

		local uiroot = self.m_grid_list:get_root_node()
		local sr = uiroot.gameObject:GetComponent("ScrollRect")
		sr.enabled = false
	else
		self.m_grid_list:set_view_size(0, 0)
		self.m_grid_list:set_data({})
    	self.m_grid_list:reload_data(true)
	end
	
end

return test_table_cell