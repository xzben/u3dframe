local ctr_base = import("framework.mvp.ctr_base")
local lauch_ctr = class("lauch_ctr", ctr_base)

lauch_ctr.service_event_func_map = {
    -- ["service_name"] = {
    --     ["event_name"] = "handle_func"
    -- }
}

lauch_ctr.interfaces = {
    "update_process",
    "set_copyright",
}

function lauch_ctr:on_init()

end

function lauch_ctr:get_view_class()
	return require("modules.lauch.lauch_view")
end

function lauch_ctr:on_uninit()

end

-- 在 ctr 暂停运行的时候调用
function lauch_ctr:on_pause()

end

-- 在 ctr 恢复运行的时候调用
function lauch_ctr:on_resume()

end

-- 在view删除前回调
function lauch_ctr:on_view_exit()

end

-- 在view 创建后回调
function lauch_ctr:on_view_enter()
	log.d("lauch_ctr:on_view_enter")

	self.set_copyright("测试版权设置")
	self.update_process("更新进度", 0)
	local count = 0
	
	self:schedule( function() 
		count = count + 1
		self.update_process("更新进度", count/100)
	end,  1)

	game.scene_manager:get_cur_scene():show_module("test")
end

return lauch_ctr