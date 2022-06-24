local main_scene_ctr = class("main_scene_ctr", framework.mvp.scene_base_ctr)

function main_scene_ctr:get_scene_type()
	return const.scene_type.main
end

function main_scene_ctr:on_init()
	log.d("main_scene_ctr on_init")

end

return main_scene_ctr