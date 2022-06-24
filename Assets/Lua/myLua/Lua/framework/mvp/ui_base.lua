local common_base = require("framework.mvp.common_base")
local res_loader = require("framework.utils.loader.res_loader")
local ui_base = class("ui_base", common_base)

-- ui_base.interfaces = {
--     -- "testInterface",
-- }

function ui_base:ctor( gameObject )
	common_base.ctor(self)
	self.m_loader = res_loader.new()
	if gameObject then
		self.m_uiroot = gameObject.transform
	end
	
    xpcall_func(function()
        self:on_init(self:get_show_data())
        self:check_add_lua_event()
    end)
end

function ui_base:get_resloader()
    return self.m_loader
end

function ui_base:check_add_lua_event()
    if self.m_uiroot == nil or self.m_is_added_lua_event then return end
    self.m_is_added_lua_event = true

    self.m_lua_event_obj = self.m_uiroot.gameObject:GetComponent(typeof(LuaEvent))
    if self.m_lua_event_obj == nil then
        self.m_lua_event_obj = self.m_uiroot.gameObject:AddComponent(typeof(LuaEvent))
    end

    self.m_lua_event_obj:AddOnDestroy(function() 
        -- log.d("######################################## m_lua_event_obj", tostring(self.__cname))
        self.m_uiroot = nil
        self:dtor()
    end)
end

function ui_base:get_root_node()
    return self.m_uiroot
end

function ui_base:check_ajust_parent( parent_view )
    local uiroot = self:get_root_node()
    local parent_uiroot = parent_view:get_root_node()

    if uiroot.parent ~= parent_uiroot then
        uiroot:SetParent(parent_uiroot)
        self:update_zorder()
    end
end

function ui_base:on_init()
    
end

function ui_base:on_uninit()

end

function ui_base:on_update( data )

end

function ui_base:get_show_data()
    if self.m_ctr ~= nil then
        return self.m_ctr:get_show_data()
    end
end


function ui_base:set_ctr( ctr )
    self.m_ctr = ctr
end

function ui_base:get_ctr()
    return self.m_ctr
end


function ui_base:set_visible( visible )
    if self.m_uiroot ~= nil and not tolua.isnull(self.m_uiroot) then
        utils.ui.set_visible(self.m_uiroot, visible)
    end
end

function ui_base:get_componet(comptype)
	if self.m_uiroot == nil then return end
    return self.m_uiroot:GetComponent(comptype)
end

-----------------------------------------------------------------------------
function ui_base:get_parent_zorder()
    local parent = self.m_uiroot.transform.parent
    local parent_canvas = parent.gameObject:GetComponent('Canvas')

    while parent_canvas == nil do
        parent = parent.transform.parent
        parent_canvas = parent.gameObject:GetComponent('Canvas')
    end

    if parent_canvas == nil then
        return 10000
    end

    return parent_canvas.sortingOrder
end

function ui_base:set_local_zorder(order)
    log.d("view_base:set_zorder", order, self.__cname)
    utils.ui.set_local_zorder(self.m_uiroot.gameObject, order)
end

function ui_base:update_zorder()
    if self.m_uiroot == nil then return end
    utils.ui.update_zorder(self.m_uiroot.gameObject)
end

function ui_base:set_global_zorder(order)
    utils.ui.set_global_zorder(self.m_uiroot.gameObject, order)
end

-----------------------------------------------------------------------------
--- 方式一   get_child_by_name("childname/childname")  获取 uiroot 下指定节点
--- 方式一   get_child_by_name("childname/childname", "Text")  获取节点的指定类型组件
--- 方式三   get_child_by_name( parent_node, "childname/childname")  获取指定父节点下的指定子节点
--- 方式四   get_child_by_name( parent_node, "childname/childname", "Text") 获取指定父节点下的指定子节点的指定类型组件
function ui_base:get_child_by_name( path, comptype, other)
    local parent = nil
    if type(path) ~= "string" then
        parent = path
        path = comptype
        comptype = other
    else
        parent = self.m_uiroot
    end

    return utils.ui.get_child_by_name(parent, path, comptype)
end

-------------------------------------asset-------------------------------------
function ui_base:get_sprite_atlas(ab_name, atlas_name)
    return self.m_loader:get_sprite_atlas(ab_name, atlas_name)
end

function ui_base:get_asset(ab_name, assetname)
    return self.m_loader:load_asset(ab_name, assetname)
end
-------------------------------------action-------------------------------------
function ui_base:get_action_manager()
	if self.m_action_manager == nil then
		self.m_action_manager = utils.action.action_manager.new()
		self.m_action_timer = Timer.New(function( delta )
			self.m_action_manager:update(delta)
		end, 0, -1)
		self.m_action_timer:Start()
	end

	return self.m_action_manager
end

function ui_base:clear_action_manager()
    if self.m_action_timer then
        self.m_action_timer:Stop()
        self.m_action_timer = nil
    end

    if self.m_action_manager then
        self.m_action_manager:remove_all_action_from_owner(self)
        self.m_action_manager = nil
    end
end

function ui_base:run_action( action, target)
    if target == nil then
        target = self.m_uiroot
    end
    self:get_action_manager():add_action(action, target, true, self)
end

function ui_base:stop_action( action )
    self:get_action_manager():remove_action(action)
end


function ui_base:async_load_ab( ab_name, func)
    return self.m_loader:async_load_ab(ab_name, func)
end

function ui_base:load_ab(ab_name)
    return self.m_loader:load_ab(ab_name)
end

--------------------------------------------------------------------------
local function _convert_to_parmas(self, path, func, other )
    local parent = nil
    if type(path) ~= "string" then
        parent = path
        path = func
        func = other
    else
        parent = self.m_uiroot
    end

    return parent, path, func
end


-- 方式一、   add_click_callback("childname/childname", func ) 给uiroot 下指定节点增加事件
-- 方式二、   add_click_callback(parentnode, "childname/childname", func) 给 parent 下指定节点增加事件 
function ui_base:add_click_callback( path, func, other)
    local parent, path, func = _convert_to_parmas(self, path, func, other)

    if type(func) == "string" and type(self[func]) == "function" then
        func = self[func]
    end
    
    local node = utils.ui.get_child_by_name(parent, path)
    if node == nil then
        g_log.e("can't find the child by name [", path, "]")
        return
    end
    utils.ui.add_click_callback(node.transform, func)

    return node
end

-- 方式一、   add_input_end_edit("childname/childname", func ) 给uiroot 下指定节点增加事件
-- 方式二、   add_input_end_edit(parentnode, "childname/childname", func) 给 parent 下指定节点增加事件 
function ui_base:add_input_end_edit( path, func, other )
    local parent, path, func = _convert_to_parmas(self, path, func, other)

    local node = utils.ui.get_child_by_name(parent, path)
    if node == nil then
        g_log.e("can't find the child by name [", path, "]")
        return
    end
    utils.ui.add_input_end_edit(node.transform, func)

    return node
end

-- 方式一、   add_slider_value_change("childname/childname", func ) 给uiroot 下指定节点增加事件
-- 方式二、   add_slider_value_change(parentnode, "childname/childname", func) 给 parent 下指定节点增加事件 
function ui_base:add_slider_value_change( path, func, other )
    local parent, path, func = _convert_to_parmas(self, path, func, other)

    local node = utils.ui.get_child_by_name(parent, path)
    if node == nil then
        g_log.e("can't find the child by name [", path, "]")
        return
    end
    utils.ui.add_slider_value_change(node.transform, func)

    return node
end

-- 方式一、   add_toggle_value_change("childname/childname", func ) 给uiroot 下指定节点增加事件
-- 方式二、   add_toggle_value_change(parentnode, "childname/childname", func) 给 parent 下指定节点增加事件 
function ui_base:add_toggle_value_change( path, func, other )
    local parent, path, func = _convert_to_parmas(self, path, func, other)

    local node = utils.ui.get_child_by_name(parent, path)
    if node == nil then
        g_log.e("can't find the child by name [", path, "]")
        return
    end
    utils.ui.add_toggle_value_change(node.transform, func)

    return node
end

-- 方式一、   add_scroll_rect_value_change("childname/childname", func ) 给uiroot 下指定节点增加事件
-- 方式二、   add_scroll_rect_value_change(parentnode, "childname/childname", func) 给 parent 下指定节点增加事件 
function ui_base:add_scroll_rect_value_change( path, func, other )
    local parent, path, func = _convert_to_parmas(self, path, func, other)

    local node = utils.ui.get_child_by_name(parent, path)
    if node == nil then
        g_log.e("can't find the child by name [", path, "]")
        return
    end
    utils.ui.add_scroll_rect_value_change(node.transform, func)

    return node
end

function ui_base:adapter_content( content_path )
    local content = self:get_child_by_name(content_path)
    if UnityEngine.Screen.height / UnityEngine.Screen.width >= 2 then
        content:GetComponent("RectTransform").offsetMax = Vector2(0,-120)
    end
end

--------------------------------------------------------------------------
function ui_base:dtor()
	common_base.dtor(self)
	if self.m_inited then
		self:on_uninit()
	end
	self:clear_action_manager()
	if self.m_uiroot ~= nil and not tolua.isnull(self.m_uiroot) then
		utils.ui.destroy(self.m_uiroot)
		self.m_uiroot = nil
	end
	self.m_loader:dtor()
    log.d("ui_base:dtor", self.__cname)
end

return ui_base