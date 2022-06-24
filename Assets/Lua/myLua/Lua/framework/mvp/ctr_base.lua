local common_base = require("framework.mvp.common_base")
local ctr_base = class("ctr_base", common_base)

-- ctr_base.service_event_func_map = {
--     ["service_name"] = {
--         [g_event["event_name"]] = "handle_func"
--         [g_event["event_name"]] = { func = "handle_func", order = 0 };
--     }
-- }

-- -- 需要 view 提供的回调接口
-- ctr_base.interfaces = {
--     -- "testInterface",
-- }

local _register_event = nil
local _clear_event = nil

local _input_view_interface = nil

local _remove_ctr_interface = nil
local _add_ctr_interface = nil

function ctr_base:ctor()
	common_base.ctor(self)
	self.m_view = nil

    self.m_component = {}
    self.m_component_name = nil
    self.m_component_index = 0

    self.m_is_push_module = false

	xpcall_func(function() 
		_register_event(self)
		self:on_init()
		self:on_resume()
	end)
end

function ctr_base:set_module_push_status( push_module )
    self.m_is_push_module = push_module
end

function ctr_base:is_push_module()
    return self.m_is_push_module
end

function ctr_base:get_global_event_dispatcher()
    return game.event_dispatcher
end


function ctr_base:get_component_index()
    self.m_component_index = self.m_component_index + 1

    return self.m_component_index
end

function ctr_base:set_pkg_name( name )
    self.m_pkg_name = name
end

function ctr_base:get_component_name()
    if self.m_component_name == nil then
        self.m_component_name = string.format("%s_%s",self.__cname, tostring(self))
    end

    return self.m_component_name
end

function ctr_base:set_parent_ctr( ctr )
    self.m_parent_ctr = ctr
end

function ctr_base:get_parent_ctr()
    return self.m_parent_ctr
end

function ctr_base:get_pkg_name()
    return self.m_pkg_name
end

function ctr_base:get_view_class()
    g_log.e(string.format("please overwrite this get_view_class func! pkg_name[%s]", self.m_pkg_name))
    return {} --- view 的class
end

function ctr_base:on_init()

end

function ctr_base:on_uninit()

end

-- 在 ctr 暂停运行的时候调用
function ctr_base:on_pause()

end

-- 在 ctr 恢复运行的时候调用
function ctr_base:on_resume()

end

-- 在view删除前回调
function ctr_base:on_view_exit()

end

-- 在view 创建后回调
function ctr_base:on_view_enter()

end

function ctr_base:get_view()
    return self.m_view
end

function ctr_base:get_show_data()
    if self.m_show_view_data ~= nil then
        return unpack(self.m_show_view_data)
    end
end

function ctr_base:do_resume()
    xpcall_func(function() 
        self:on_resume()
        self:do_component_resume()
        _register_event(self)
    end)
end

function ctr_base:do_pause()
    xpcall_func(function() 
        _clear_event(self)
        self:do_component_pause()
        self:on_pause()
    end)
end

function ctr_base:alloc_view( ... )
    local params = { ... }
    if #params == 0 then
        self.m_show_view_data = nil
    else
        self.m_show_view_data = params
    end

    if self.m_view == nil then
        local view_class = self:get_view_class()
        if view_class ~= nil then
            self.m_view = view_class.preset_new(function(instance) 
                instance:set_ctr(self)
                _input_view_interface(self, instance)
                _add_ctr_interface(self, instance)
            end)
            xpcall_func(function() 
                self:on_view_enter()
                self:do_component_view_enter()
                if self.m_show_view_data ~= nil then
                    self.m_view:on_update(self:get_show_data())
                end
                self.m_view:do_show_anim()
            end)
        else
            local name = self.m_pkg_name
            if name == nil then name = self:get_component_name() end

            log.e("can't find the view class for pkg[", tostring(name), "]")
        end
    else
        log.w("the view had show view not release!", self.__cname)
    end

    return self.m_view
end


function ctr_base:release_view()
    xpcall_func(function() 
        self:release_component_view()
        local view = self.m_view
        if view then
            self:on_view_exit()
        end
        self.m_view = nil
        if view then
            view:dtor()
        end
        _remove_ctr_interface(self)
    end)
end


function ctr_base:get_all_component()
    local arr = {}
    for _, item in pairs(self.m_component) do
        table.insert(arr, item)
    end

    table.sort(arr, function(a, b) 
        return a.index < b.index
    end)

    return arr
end


function ctr_base:do_component_resume()
    local all_component = self:get_all_component()
    for _, item in ipairs(all_component) do
        item.component:do_resume()
    end
end

function ctr_base:do_component_pause()
    local all_component = self:get_all_component()
    for _, item in ipairs(all_component) do
        item.component:do_pause()
    end
end

function ctr_base:do_component_view_enter()
    local all_component = self:get_all_component()
    for _, item in ipairs(all_component) do
        if item.isshow then
            local comp_view = item.component:get_view()
            if comp_view == nil then
                local last_show_data = item.component:get_show_data()
                item.component:alloc_view(last_show_data)
            else
                -- 强制检测组件的父节点是否正确，因为可能子节点先show导致parent错误
                comp_view:check_ajust_parent(self:get_view())
            end
        end
    end
end

function ctr_base:release_component_view()
    local all_component = self:get_all_component()
    for _, item in ipairs(all_component) do
        if item.isshow then
            item.component:release_view()
        end
    end
end

function ctr_base:get_component( component_name )
    local item = self.m_component[component_name]

    if item == nil then
        log.e("找不到对应的组件："..component_name)
    end

    return item.component, item
end

function ctr_base:load_component( component_class, ...)
    local time = os.clock()
    local load_item = nil

    local component = nil
    local item = nil
    if component_class then
        component = component_class.preset_new(function( instance ) 
            instance:set_parent_ctr(self)
            local component_name = instance:get_component_name()
            if self.m_component[component_name] then
                log.w(string.format("load a exist component[%s]", component_name))
            end
            item = { component = instance; component_name = component_name; isshow = false; index = self:get_component_index(); }
            self.m_component[component_name] = item
        end, ...)
    else
        log.e("非法的组件："..tostring(component_class))
    end

    local cost_time = os.clock() - time
    if cost_time > 0.1 then
        log.i("检测组件加载时长," .. component:get_component_name() .. "模块加载完成,且时长较长: ", cost_time)
    end

    return component, item
end

function ctr_base:show_view( data )
    if self.m_parent_ctr then
        return self.m_parent_ctr:close_component_view(self:get_component_name())
    else
        local pkg_name = self:get_pkg_name()
        if pkg_name then
            return game.scene_manager:get_cur_scene():show_module(pkg_name)
        else
            return self:alloc_view(data), self
        end
    end
end

function ctr_base:close()
    local parent_ctr = self:get_parent_ctr()

    if parent_ctr == nil then
        if self:is_push_module() then
            self:pop_module_view()
        else
            local pkg_name = self:get_pkg_name()

            if pkg_name then
                game.scene_manager:get_cur_scene():remove_module(pkg_name)
            else
                self:dtor()
            end
        end
    else
        parent_ctr:close_component(self:get_component_name())
    end
end

function ctr_base:close_view()
    if self.m_parent_ctr then
        self.m_parent_ctr:close_component_view( self:get_component_name() )
    else
        local pkg_name = self:get_pkg_name()
        if pkg_name then
            game.scene_manager:get_cur_scene():close_module(pkg_name)
        else
            self:release_view()
        end
    end
end

function ctr_base:remove_componet( component_name )
    self.m_component[component_name] = nil
end

function ctr_base:clear_component()
    for component_name, item in pairs(self.m_component) do
        item.component:dtor()
    end
    self.m_component = {}
end

function ctr_base:create_show_component( component_class, ...)
    local component, item = self:load_component(component_class, ...)
    item.isshow = true
    local view = component:alloc_view(...)

    return view, component
end

function ctr_base:show_component( component_name, ...)
    local component, item = self:get_component( component_name )
    if component then
        local view = component:alloc_view(...)
        item.isshow = true

        return  view, component
    else
        log.e("can't find the component_name by name:", component_name)
    end
end

function ctr_base:close_component_view( component_name )
    local component, item = self:get_component( component_name )
    if component then
        item.isshow = false
        component:release_view()
    else
        log.e("can't find the component_name by name:", component_name)
    end

end

function ctr_base:close_component( component_name )
    local component = self:get_component( component_name )
    if component then
        component:dtor()
    else
        log.e("can't find the component_name by name:", component_name)
    end
end

function ctr_base:dtor()
	common_base.dtor(self)

    if self.m_pkg_name ~= nil then
        game.scene_manager:get_cur_scene():_clear_module(self.m_pkg_name, self)
    end

    if self.m_parent_ctr then
        self.m_parent_ctr:remove_componet(self:get_component_name())
    end

    xpcall_func(function() 
        _clear_event(self)
        self:release_view()
        self:clear_component()
        self:on_pause() 
        self:on_uninit()
    end)
    log.i("dtor:", self.__cname)
end

local function _remove_listener(self, event_map, listener )
    if type(event_map) ~= "table" then return end
    if listener == nil then return end
    listener:removeListener_by_owner(self)
end

local function _add_listener(self, event_map, listener)
    if type(event_map) ~= "table" then return end

    for key, value in pairs(event_map) do
        local order = 0
        local count = -1
        local func_name = value

        if type(value) == "table" and type(value.func) == "string" then
            func_name = value.func
            order = value.order or 0
            count = value.count or -1   
        end

        local func = self[func_name]
        if type(func) == "function" then
            listener:insert(key, self, func, count, order)
        else
            log.e(tostring(self) .. "没有实现接口:" .. value)
        end
    end
end

_register_event = function ( self )
    if type(self.service_event_func_map) == "table" then
        for service_name, event_map in pairs(self.service_event_func_map) do
            local service = self:get_service(service_name)
            if service then
                _add_listener(self, event_map, service)
            else
                log.e("can't find the service by name:[", tostring(service_name), "]", self.__cname)
            end
        end
    end
end

_clear_event = function (self)
    if type(self.service_event_func_map) == "table" then
        for service_name, event_map in pairs(self.service_event_func_map) do
            local service = self:get_service(service_name)
            if service then
                _remove_listener(self, event_map, service)
            else
                log.e("can't find the service by name:[", tostring(service_name), "]", self.__cname)
            end
        end
    end
end
---注册interface
_input_view_interface = function (self, view)
    if view.interfaces and type(view.interfaces) == "table" then
        for key, interface in pairs(view.interfaces) do
            if view[interface] ~= nil then
                log.e("the interface is defined please check!")
            else
                view[interface] = function(...)
                    if self[interface] then
                        return self[interface](self, ...)
                    else
                        log.e(tostring(self) .. "没有实现接口:" .. interface)
                    end
                end
            end
        end
    end
end

_remove_ctr_interface = function( self )
    if type(self.interfaces) == "table" then
        for key, interface in pairs(self.interfaces) do
            self[interface] = nil
        end
    end 
end

_add_ctr_interface = function( self, view )
    if type(self.interfaces) == "table" then
        for key, interface in pairs(self.interfaces) do
            if nil ~= self[interface] then
                log.e("the interface is defined please check")
            else
                self[interface] = function(...)
                    if view[interface] then
                        return view[interface](view, ...)
                    else
                        log.e(tostring(view).. "没有实现接口"..interface)
                    end
                end
            end
        end
    end 
end

return ctr_base