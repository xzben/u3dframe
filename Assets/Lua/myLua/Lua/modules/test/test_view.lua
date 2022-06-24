local view_base = require("framework.mvp.view_base")
local test_table_cell = require("modules.test.test_table_cell")
local menu_config = require("modules.test.menu_config")
local test_view = class("test_view", view_base)

-- 需要 ctr 提供的回调接口
test_view.interfaces = {
    "close",
}

function test_view:on_init(data)
	self:load_view("test/panel", "test_view")
	self.m_list = utils.dynamic_table_view.new(self:get_child_by_name("scroll_view"))
	self.m_list:set_cell_class(test_table_cell, self.m_list)
	self.m_list:set_cell_size_func(function(index, data)
		if not data.isClose then
			return 130 + math.ceil(#data.list/3) * 135
		end
		return 130
	end)
	self.m_list:set_cell_type_index_func(function(index, data)
		return 0
	end)

	self.m_list:set_data(menu_config)
    self.m_list:reload_data()

	-- self:add_click_callback("btn_close", function() 
	-- 	self.close()
	-- end)
end

function test_view:on_uninit()

end

function test_view:on_update( data )

end

-- 看情况需求重写此方法，返回需要添加的layer_name
-- function test_view:get_layer_name()
--     return g_const.layer_name.layer_game
-- end

-- 如果需要定制展示动画则重写此方法实现界面的展现动画
-- function test_view:do_show_anim()
    
-- end

-- 如果需要定制关闭动画则重写此方法实现界面的关闭动画
-- function test_view:do_close_anim( callback )
--     assert(type(callback) == "function", "please pass a function")
--     callback()
-- end

return test_view