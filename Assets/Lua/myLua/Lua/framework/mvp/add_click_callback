local ui_base = require("framework.mvp.ui_base")
local view_base = class("view_base", ui_base)

-- ui_base.interfaces = {
--     -- "testInterface",
-- }

function view_base:ctor( gameObject )
	ui_base.ctor(self, gameObject)
end

function view_base:dtor()
    self:do_close_anim(function() 
        ui_base.dtor(self)
    end)
end

function view_base:set_show_top()
    utils.ui.set_max_local_zorder(self.m_uiroot.gameObject)
end

function view_base:get_layer_name()
    return const.layer_name.layer_game
end

function view_base:load_scene_view( path )
    local scene = game.scene_manager:get_cur_scene()
    local canvas = scene:get_canvas()
    self.m_uiroot = canvas:Find(path).transform

    return self.m_uiroot
end


function view_base:eat_bottom_click()
    if self.m_uiroot == nil then return end
    
    local img = self.m_uiroot.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
    if img == nil then
        img = self.m_uiroot.gameObject:AddComponent(typeof(UnityEngine.UI.Image))
    end

    img.color = g_tools.new_color_hex(192, 192, 192, 10);
    img.raycastTarget = true
end


local function _get_view_parent( self )
    local ctr = self:get_ctr()
    local parent_ctr = nil
    local parent_is_scene_layer = false

    if ctr then
        parent_ctr = ctr:get_parent_ctr()
    end
    
    local parent = nil

    if parent_ctr then
        local view = parent_ctr:get_view()
        if view then
            parent = view:get_root_node()
            if parent == nil then
                log.e(string.format("the view[%s] is empty view must have root node", view.__cname))
            end
        end
    end

    if parent == nil then
        local scene = game.scene_manager:get_cur_scene()
        parent = scene:get_layer(self:get_layer_name())
        parent_is_scene_layer = true
    end

    return parent, parent_is_scene_layer
end

function view_base:load_view(ab_name, prefab, parent )
    local parent_is_scene_layer = false

    if parent == nil then
        parent, parent_is_scene_layer = _get_view_parent(self)
    end
    local load_prefab = self:get_asset(ab_name, prefab)
    if load_prefab == nil then
        log.e(string.format("can't get the prefab ab_name[%s] prefab[%s]", ab_name, prefab))
        return
    end
    self.m_is_added_lua_event = false
    self.m_uiroot = UnityEngine.Object.Instantiate(load_prefab, parent).transform
    if parent_is_scene_layer then
        self:set_show_top()
    end
    self:check_add_lua_event()
    return self.m_uiroot
end

function view_base:do_show_anim()
    local layer_name = self:get_layer_name()
    --弹窗层的界面默认做一个弹窗效果
    if layer_name == const.layer_name.layer_popup or layer_name == const.layer_name.layer_confirm_popup then
        self.m_uiroot.localScale = Vector3(0, 0, 0)
        local action = utils.action.scale_to.new(0.5, Vector3(1, 1, 1))
        self:run_action( action )
    end
end

function view_base:do_close_anim( callback )
    assert(type(callback) == "function", "please pass a function")
    callback()
end

return view_base