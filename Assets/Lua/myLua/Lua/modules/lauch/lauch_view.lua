local view_base = import("framework.mvp.view_base")
local lauch_view = class("lauch_view", view_base)

-- 需要 ctr 提供的回调接口
lauch_view.interfaces = {
    -- "testInterface",
}

function lauch_view:on_init(data)
	self:load_scene_view("layer_bg/main_load")

	self.m_process = self:get_child_by_name("process_bg/process", "Image")
	self.m_tips = self:get_child_by_name("process_bg/tips", "Text")
	self.m_copyright = self:get_child_by_name("copyright", "Text")
end


function lauch_view:update_process( tips, process )
	self.m_tips.text = string.format("%s %s/100", tips, process*100)
	self.m_process.fillAmount = process
end

function lauch_view:set_copyright( text )
	self.m_copyright.text = text
end

function lauch_view:on_uninit()

end

function lauch_view:on_update( data )

end

-- 看情况需求重写此方法，返回需要添加的layer_name
-- function lauch_view:get_layer_name()
--     return g_const.layer_name.layer_game
-- end

-- 如果需要定制展示动画则重写此方法实现界面的展现动画
function lauch_view:do_show_anim()
    
end

-- 如果需要定制关闭动画则重写此方法实现界面的关闭动画
-- function lauch_view:do_close_anim( callback )
--     assert(type(callback) == "function", "please pass a function")
--     callback()
-- end

return lauch_view