local event_dispatcher = require("framework.event.event_dispatcher")
local res_loader = require("framework.utils.loader.res_loader")
local scene_manager = class("scene_manager")


function scene_manager:ctor()
	event_dispatcher.ctor(self)

	self.m_curscene = nil
	self.m_curSceneName = nil
	self.m_lasting_module = nil
	self.m_resloader = res_loader.new()
end

function scene_manager:load_scene(name)
	self.m_resloader:async_load_ab(string.format("%s/scene/%s", name, name), function() 
		UnityEngine.SceneManagement.SceneManager.LoadScene(name)
	end)
end

function scene_manager:get_cur_scene()
	return self.m_curscene
end

function scene_manager:run_scene( name )
	if self.m_curscene then
		self.m_curscene:dtor()
		self.m_curscene = nil
	end
	log.d("scene_manager:run_scene", name)
	local scene = require(string.format("scene.%s.%s_scene_ctr", name, name))
	scene.preset_new(function( instance ) 
		self.m_curscene = instance
	end)
	self.m_curSceneName = name
end

return scene_manager