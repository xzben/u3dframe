local view_base = require("framework.mvp.view_base")
local test_action_view = class("test_action_view", view_base)

-- 需要 ctr 提供的回调接口
test_action_view.interfaces = {
    -- "testInterface",
    "close",
}

function test_action_view:on_init(data)
    self:load_view("test/panel", "test_action")

    local url_img = self:get_child_by_name("RawImage")

    self:add_click_callback("btn_close", function() 
		self:close()
	end)

    local top_action = utils.action.move_by.new(1.0, Vector3(0, 300, 0))
    local call_action = utils.action.call_func.new(function()
        log.d("action call") 
    end)
    local bo_action = utils.action.move_by.new(1.0, Vector3(0, -300, 0))
    local action = utils.action.repeat_forever.new(top_action, call_action, bo_action)
    self:run_action(action, url_img)
end

function test_action_view:on_uninit()

end

function test_action_view:on_update( data )

end

-- 看情况需求重写此方法，返回需要添加的layer_name
-- function test_action_view:get_layer_name()
--     return g_const.layer_name.layer_game
-- end

-- 如果需要定制展示动画则重写此方法实现界面的展现动画
-- function test_action_view:do_show_anim()
    
-- end

-- 如果需要定制关闭动画则重写此方法实现界面的关闭动画
-- function test_action_view:do_close_anim( callback )
--     assert(type(callback) == "function", "please pass a function")
--     callback()
-- end

return test_action_view