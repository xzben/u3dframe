local view_base = require("framework.mvp.view_base")

local scene_view = class("scene_view", view_base)

local kSceneLayers = {
	[const.layer_name.layer_bg] 			= { name = "layer_bg", 				zorder_begin = 0;  zorder_end = 9999;};
	[const.layer_name.layer_game] 			= { name = "layer_game", 			zorder_begin = 10000;  zorder_end = 25999;};
	[const.layer_name.layer_animation] 		= { name = "layer_animation", 		zorder_begin = 26000;  zorder_end = 26999;};
	[const.layer_name.layer_popup] 			= { name = "layer_popup", 			zorder_begin = 27000;  zorder_end = 27999;};
	[const.layer_name.layer_system] 		= { name = "layer_system", 			zorder_begin = 28000;  zorder_end = 28999;};
	[const.layer_name.layer_confirm_popup] 	= { name = "layer_confirm_popup", 	zorder_begin = 29000;  zorder_end = 32767;};
}

function scene_view:ctor( canvasName )
	view_base.ctor(self)
	self.m_canvas = nil
	self.m_layers = nil

	self.m_showViews = {}

	self:init( canvasName)
end

function scene_view:init( canvasName )
	self.m_canvas = UnityEngine.GameObject.Find(canvasName).transform
	assert(self.m_canvas ~= nil, "handle canvas err can't find the canvas by name:"..canvasName)
	
	self.m_layers = {}
	for name, config in pairs(kSceneLayers) do
		local layer = self.m_canvas:Find(config.name)
		local zorderRoot = layer.gameObject:GetComponent(typeof(ZorderManager.ZOrderNode))
		if zorderRoot == nil then
			zorderRoot = layer.gameObject:AddComponent(typeof(ZorderManager.ZOrderNode))
		end
		zorderRoot:SetRoot(config.zorder_begin, config.zorder_end)

		self.m_layers[name] = layer
	end
end

function scene_view:get_canvas()
	return self.m_canvas
end

function scene_view:get_layer( layer_name )
	return self.m_layers[layer_name]
end

return scene_view