local miniload_scene_ctr = class("miniload_scene_ctr", framework.mvp.scene_base_ctr)

function miniload_scene_ctr:get_scene_type()
	return const.scene_type.miniload
end

function miniload_scene_ctr:on_init()
	log.d("miniload_scene_ctr on_init")
	self:show_module("lauch")
end

return miniload_scene_ctr