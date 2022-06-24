local ctr_base = require("framework.mvp.ctr_base")
local scene_view = require("framework.mvp.scene_view")
local scene_base_ctr = class("scene_base_ctr", ctr_base)


function scene_base_ctr:ctor( scene_name )
	

	self.m_scene_name = scene_name
	self.m_canvas = nil
	self.m_module_index = 0
	self.m_all_module = {}
	self.m_scene_view = nil
	self.m_module_stacks = {}
	self:init_zorder_manager()

	ctr_base.ctor(self)
end

function scene_base_ctr:init_zorder_manager()
	self:get_scene_view()
end

function scene_base_ctr:get_scene_view()
	if self.m_scene_view == nil then
		self.m_scene_view = scene_view.new("Canvas")
	end
	return self.m_scene_view
end


function scene_base_ctr:get_canvas()
    return self:get_scene_view():get_canvas()
end

function scene_base_ctr:get_layer( layer_name )
    return self:get_scene_view():get_layer(layer_name)
end

function scene_base_ctr:get_scene_type()
    g_log.e("please overwrite to return scene type")
    return 0
end

function scene_base_ctr:get_module_index()
    self.m_module_index = self.m_module_index + 1
    return self.m_module_index
end

function scene_base_ctr:load_module( pkgname, ...)
	local pkg_path = string.format("modules.%s", pkgname)
	local pkg = require(pkg_path)

	local load_item = nil
	if pkg then
		local module = pkg.ctr.preset_new(function( instance) 
			instance:set_pkg_name( pkgname )
			load_item = { module = instance; pkg = pkgname; pkg_path = pkg_path; isshow = false; index = self:get_module_index(); }
			self.m_all_module[pkgname] = load_item 
		end, ...)
	else
		log.e("当前场景：", self.m_scene_name, " 找不到这个模块：", pkg_path)
	end

	return load_item
end

function scene_base_ctr:get_module( pkg, auto_create, ...)
	local auto_create = auto_create == nil and false or auto_create

	local iscreate = false
	local load_item = self.m_all_module[pkg]

	if load_item == nil and auto_create then
		load_item = self:load_module(pkg, ...)
		iscreate = true
	end

	return load_item, iscreate
end

function scene_base_ctr:_clear_module( pkg )
	self.m_all_module[pkg] = nil
end

function scene_base_ctr:remove_module( pkg )
	local load_item = self:get_module(pkg, false)

	if load_item then
		load_item.module:dtor()
	else
		log.w(string.format("can'f find the module[%s] object from cache", pkg))
	end

	self.m_all_module[pkg] = nil
end

function scene_base_ctr:close_module( pkg )
	local load_item = self:get_module(pkg, false)
    if load_item then
        load_item.module:release_view()
        load_item.isshow = false
    else
        log.w(string.format("can't find the module[%s] object from cache", pkg))
    end
end

function scene_base_ctr:show_module( pkg, ...)
    local load_item = self:get_module(pkg, true, ...)
    local view = load_item.module:alloc_view(...)
    load_item.isshow = true

    return view, load_item.module
end

function scene_base_ctr:remove_all_module()
    for pkg, item in pairs(self.m_all_module) do
        item.module:dtor()
    end
    self.m_all_module = {}
    self.m_module_index = 0
end

local function _release_module_view( self, modules, delete)
	local cur_modules = {}
	for pkgname, item in pairs(modules) do
		if delete then
			item.module:dtor()
		else
			if item.isshow then
				item.module:release_view()
			end

			item.module:do_pause()
		end

		table.insert(cur_modules, item)
	end

	return cur_modules
end

local function _resume_module_view( self, modules)
	local max_index = -1
	local cur_modules = {}

	table.sort(modules, function(a, b) 
		return a.index < b.index
	end)

	for i, item in ipairs(modules) do
		local pkgname = item.pkg
		if item.isshow then
			local last_show_data = item.module:get_show_data()
			item.module:alloc_view(last_show_data)
		end

		item.module:do_resume()

		if item.index > max_index then
			max_index = item.index
		end
		cur_modules[pkgname] = item
	end

	return cur_modules, max_index
end

function scene_base_ctr:push_module_view( pkg, data)
	local cur_modules = _resume_module_view(self, self.m_all_module, false)

	self.m_module_index = 0
	self.m_all_module = {}
	table.insert(self.m_module_stacks, cur_modules)

	local view, show_module = self:show_module(pkg, data)

	show_module:set_module_push_status(true)

	return view, show_module
end

function scene_base_ctr:get_stack_size()
	return #self.m_module_stacks
end


function scene_base_ctr:find_module_in_stack( pkg )
    local size = #self.m_module_stacks
    for i = size, 1, -1 do
        local cur_modules = self.m_module_stacks[i]
        for pkg_name, item in ipairs(self.m_module_stacks) do
            if pkg == pkg_name then
                return true, i
            end
        end 
    end
    return false
end

function scene_base_ctr:pop_to_level_module( index )
    if self:get_stack_size() <= index then return end

    local size = #self.m_module_stacks
    for i = size, index, -1 do
        local cur_modules = self.m_module_stacks[i]
        if i == index then
            self.m_all_module, self.m_module_index = _resume_module_view(self, cur_modules)
        else
            _release_module_view(self, cur_modules, true)
        end
    end
end

function scene_base_ctr:pop_to_root_module()
    self:pop_to_level_module(1)
end

function scene_base_ctr:pop_to_module_view( pkg, data)
    local find, idx = self:find_module_in_stack(pkg)
    if not find then --找不到则直接切换
        self:switch_module_view( pkg,  data)
    else
        self:pop_to_level_module(idx)
    end
end

function scene_base_ctr:pop_module_view()
    log.d("################## pop_module_view", self.m_module_stacks, self:get_stack_size())
    if self:get_stack_size() >= 1 then
        _release_module_view(self, self.m_all_module, true)
        local need_opens = table.remove(self.m_module_stacks)
        self.m_all_module, self.m_module_index = _resume_module_view(self, need_opens)
    else
        log.e("cur is the root can't to pop")
    end
end

function scene_base_ctr:switch_module_view( pkg, ...)
    self:close_all_show_module()
    return self:show_module(pkg, ...)
end


function scene_base_ctr:get_all_modules()
    local arr = {}

    for pkg_name, item in pairs(self.m_all_module) do
        table.insert(arr, item)
    end

    table.sort(arr, function(a, b) 
        return a.index < b.index
    end)

    return arr
end

function scene_base_ctr:dtor()
	self:remove_all_module()
	ctr_base.dtor(self)
end

return scene_base_ctr