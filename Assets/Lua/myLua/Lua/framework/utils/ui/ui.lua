local ui = {}

function ui.get_gameobject( gameObject )
	-- 如果不是 gameObject 则可能是组件，自动转换获取对应的 gameObject
	if tolua.typeof(gameObject) ~= type(UnityEngine.GameObject) and gameObject.gameObject then
		gameObject = gameObject.gameObject
	end

	return gameObject
end

function ui.get_transform( transform )
	if tolua.typeof(transform) ~= type(UnityEngine.Transform) and transform.transform then
		transform = transform.transform
	end

	return transform
end

function ui.destroy( gameObject )
	local gameObject = ui.get_gameobject(gameObject)
	gameObject.transform:SetParent(nil)
	UnityEngine.GameObject.Destroy(gameObject)
end

function ui.get_componet(gameObject, comptype)
	local gameObject = ui.get_gameobject(gameObject)
	return gameObject:GetComponent(comptype)
end

function ui.clear_gameobject_child( gameObject )
	local gameObject = ui.get_gameobject(gameObject)
	local count = gameObject.transform.childCount

	for i = 1, count, 1 do
		local child = gameObject.transform:GetChild(0)
		ui.destroy(child.gameObject)
	end
end

function ui.count_children_height( gameObject )
	local height = 0
	local gameObject = ui.get_gameobject(gameObject)
	local count = gameObject.transform.childCount

	for i = 1, count, 1 do
		local child = gameObject.transform:GetChild(i-1)
		height = height + child.transform.sizeDelta.y
	end
	return height
end

function ui.count_children_width( gameObject )
	local width = 0
	local gameObject = ui.get_gameobject(gameObject)
	local count = gameObject.transform.childCount

	for i = 1, count, 1 do
		local child = gameObject.transform:GetChild(i-1)
		width = width + child.transform.sizeDelta.x
	end
	return width
end

function ui.set_visible( gameObject, visible )
	local gameObject = ui.get_gameobject(gameObject)
	gameObject:SetActive(visible)
end

-- transform 要添加点击事件的节点的 transform
-- func  要添加的点击回调函数
-- effect 点击的音效，不传则默认取值 const.sound_type.CLICK_EFFECT ，如果不需要音效则传 const.sound_type.NO_SOUND_EFFECT
function ui.add_click_callback( transform, func, effect)
	local effect = effect == nil and const.sound_type.CLICK_EFFECT or effect

	local btnComp = transform:GetComponent("Button")
	if btnComp == nil then
		g_log.e("can't get Button Component")
		return
	end

	local event = btnComp.onClick
	if event == nil then
	 	event = UnityEngine.UI.Button.ButtonClickedEvent.New()
	 	btnComp.onClick = event
	end

	local function play_click_effect()
		if effect == const.sound_type.NO_SOUND_EFFECT then return end
		game.sound_manager:playSoundByType(effect)
	end

	event:AddListener(function()
		xpcall_func(function() 
			play_click_effect()
		end)

		xpcall_func(function() 
			func()
		end)
	end)
end

function ui.remove_all_click_event( transform )
	local btnComp = transform:GetComponent("Button")
	if btnComp == nil then
		g_log.e("can't get Button Component")
		return
	end

	local event = btnComp.onClick
	if event ~= nil then
	 	event:RemoveAllListeners()
	end
end

function ui.input_field_show_password( inputComp, showPasswd )
	local contentType = UnityEngine.UI.InputField.ContentType.Password
	if showPasswd then
		contentType = UnityEngine.UI.InputField.ContentType.Standard
	end
	inputComp.contentType = contentType
	inputComp:ForceLabelUpdate()
end

function ui.add_input_end_edit( transform, func )
	local inputComp = transform:GetComponent("InputField")
	if inputComp == nil then
		g_log.e("can't get InputField Component")
		return
	end

	local event = inputComp.onEndEdit
	if event == nil then
		event = UnityEngine.UI.InputField.SubmitEvent.new()
		inputComp.onEndEdit = event
	end

	event:AddListener(function() 
		xpcall(function() 
			func( inputComp )
		end, __G__TRACKBACK__)
	end)
end


function ui.add_slider_value_change( transform, func )
	local sliderComp = transform:GetComponent("Slider")
	if sliderComp == nil then
		g_log.e("can't get Slider Component")
		return
	end

	local event = sliderComp.onValueChanged
	if event == nil then
		event = UnityEngine.UI.Slider.SliderEvent.new()
		sliderComp.onValueChanged = event
	end

	event:AddListener(function() 
		xpcall(function()
			func(sliderComp)
		end, __G__TRACKBACK__)
	end)
end

function ui.add_toggle_value_change( transform, func )
	local toggleComp = transform:GetComponent("Toggle")
	if toggleComp == nil then
		g_log.e("can't get Toggle Component")
		return
	end

	local event = toggleComp.onValueChanged
	if event == nil then
		event = UnityEngine.UI.Toggle.ToggleEvent.new()
		toggleComp.onValueChanged = event
	end

	event:AddListener(function() 
		xpcall(function()
			func(toggleComp)
		end, __G__TRACKBACK__)
	end)
end

function ui.get_child_by_name(parent, path, comptype )
	local parent = ui.get_transform(parent)
	local object = nil
	if path == "." then
		object = parent
	else
		object = parent:Find(path)
	end

    if object ~= nil and comptype ~= nil then
        object = object.transform:GetComponent(comptype)
    end

    if object == nil then
    	g_log.e(string.format("can't find the child[%s] comptype[%s]", tostring(path), tostring(comptype)))
    end
    return object
end

function ui.set_btn_text_font_style( btn, fontType )
	local text = ui.get_child_by_name(btn, "Text", "Text")
	if text then
		text.fontStyle = fontType
	end
end

function ui.set_btn_text_color( btn, color )
	local text = ui.get_child_by_name(btn, "Text", "Text")
	if text then
		text.color = color
	end
end


function ui.add_scroll_rect_value_change( transform, func )
	local scollrectComp = transform:GetComponent("ScrollRect")
	if scollrectComp == nil then
		g_log.e("can't get ScrollRect Component")
		return
	end

	local event = scollrectComp.onValueChanged
	if event == nil then
		event = UnityEngine.UI.ScrollRect.ScrollRectEvent.new()
		scollrectComp.onValueChanged = event
	end

	event:AddListener(function() 
		xpcall(function()
			func(scollrectComp)
		end, __G__TRACKBACK__)
	end)
end

function ui.adapter(content)
    if UnityEngine.Screen.height / UnityEngine.Screen.width >= 2 then
        content:GetComponent("RectTransform").offsetMax = Vector2(0,-60)
    end
end

function ui.set_local_zorder( gameObject, zorder )
	local gameObject = ui.get_gameobject(gameObject)
	local zorderNode = gameObject:GetComponent("ZOrderNode")
	if zorderNode == nil then
		zorderNode = gameObject:AddComponent(typeof(ZorderManager.ZOrderNode))
	end
	zorderNode:SetLocalZOrder(zorder)
end

function ui.update_zorder(gameObject)
	local gameObject = ui.get_gameobject(gameObject)
	local zorderNode = gameObject:GetComponent("ZOrderNode")
	if zorderNode == nil then
		zorderNode = gameObject:AddComponent(typeof(ZorderManager.ZOrderNode))
	end
	zorderNode:ResetRoot()
	zorderNode:SetLocalZOrder(zorderNode.localZorder)
end

function ui.set_max_local_zorder( gameObject )
	local gameObject = ui.get_gameobject(gameObject)
	local zorderNode = gameObject:GetComponent("ZOrderNode")
	if zorderNode == nil then
		zorderNode = gameObject:AddComponent(typeof(ZorderManager.ZOrderNode))
	end
	zorderNode:SetToCurMaxLocalZorder()
end

function ui.set_global_zorder( gameObject, zorder )
	local gameObject = ui.get_gameobject(gameObject)
	local zorderNode = gameObject:GetComponent("ZOrderNode")
	if ZOrderNodeode == nil then
		zorderNode = gameObject:AddComponent(typeof(ZorderManager.ZOrderNode))
	end
	zorderNode:SetGlobalZOrder(zorder)
end

return ui