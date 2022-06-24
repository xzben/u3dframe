
local test_grid_cell = require("modules.test.test_grid.test_grid_cell")
local view_base = require("framework.mvp.view_base")
local test_grid_view = class("test_grid_view", view_base)

-- 需要 ctr 提供的回调接口
test_grid_view.interfaces = {
    -- "testInterface",
    "close",
}

function test_grid_view:on_init(data)
    self:load_view("test/panel", "test_grid")
	self.m_list = utils.grid_view.new(self:get_child_by_name("scroll_view"))
	self.m_list:set_cell_class(test_grid_cell, self.m_list)

	local datas = {}
	for i = 1, 50 do
		datas[#datas + 1] = i
	end
	self.m_list:set_data(datas)
    self.m_list:reload_data()

	self:add_click_callback("btn_close", function() 
		self:close()
	end)
end

function test_grid_view:on_uninit()

end

function test_grid_view:on_update( data )

end

-- 看情况需求重写此方法，返回需要添加的layer_name
-- function test_grid_view:get_layer_name()
--     return g_const.layer_name.layer_game
-- end

-- 如果需要定制展示动画则重写此方法实现界面的展现动画
-- function test_grid_view:do_show_anim()
    
-- end

-- 如果需要定制关闭动画则重写此方法实现界面的关闭动画
-- function test_grid_view:do_close_anim( callback )
--     assert(type(callback) == "function", "please pass a function")
--     callback()
-- end

return test_grid_view