local view_base = require("framework.mvp.view_base")
local test_url_img_view = class("test_url_img_view", view_base)

-- 需要 ctr 提供的回调接口
test_url_img_view.interfaces = {
    -- "testInterface",
    "close",
}

function test_url_img_view:on_init(data)
    self:load_view("test/panel", "test_url_img")

    local url_img = self:get_child_by_name("RawImage")
    self.m_icon = utils.url_image_view.extend(url_img)

    self:add_click_callback("btn_close", function() 
		self:close()
	end)

    local url = self:get_child_by_name("Text", "Text").text
    self.m_icon:set_url(url)
end

function test_url_img_view:on_uninit()

end

function test_url_img_view:on_update( data )

end

-- 看情况需求重写此方法，返回需要添加的layer_name
-- function test_url_img_view:get_layer_name()
--     return g_const.layer_name.layer_game
-- end

-- 如果需要定制展示动画则重写此方法实现界面的展现动画
-- function test_url_img_view:do_show_anim()
    
-- end

-- 如果需要定制关闭动画则重写此方法实现界面的关闭动画
-- function test_url_img_view:do_close_anim( callback )
--     assert(type(callback) == "function", "please pass a function")
--     callback()
-- end

return test_url_img_view