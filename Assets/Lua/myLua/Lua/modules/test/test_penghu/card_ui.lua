
local view_base = require("framework.mvp.view_base")
local card_ui = class("card_ui", view_base)


function card_ui:create( parent_node, ...)
    return card_ui.extend(function( instance ) 
		local imageObj = UnityEngine.GameObject.New("Image")
		local transform = imageObj:AddComponent(typeof(UnityEngine.RectTransform))
		local imageComp = imageObj:AddComponent(typeof(UnityEngine.UI.Image))
		transform:SetParent(parent_node)
		transform.sizeDelta = Vector2(100,100)
		transform.anchorMin = Vector2(0.5,0.5)
		transform.anchorMax = Vector2(0.5,0.5)	
		transform.localScale = Vector3(1, 1, 1)
		transform.pivot = Vector2(0.5,0.5)
		transform.localEulerAngles = Vector3.forward * 0
		transform.anchoredPosition3D = Vector3(0,0,0)
		return imageObj
    end, ...)
end


function card_ui:ctor(gameObject)
	view_base.ctor(self, gameObject)
end


function card_ui:on_init(data)
	self.m_icon = self.m_uiroot:GetComponent("Image")
	self.m_icon.sprite = self:get_atlas_res("b_card1")
end

function card_ui:get_atlas_res(res_name)
    if self.m_atlas == nil then
        self.m_atlas = self:get_sprite_atlas("test/img", "card_atlas")
    end
    return self.m_atlas[res_name]	
end

function card_ui:on_uninit()

end

function card_ui:on_update( data )

end


return card_ui