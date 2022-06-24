local k_dict_root_path = LuaFramework.GameWorld.Inst.GameManager:getWriteablePath() .. "/dict/"
local dict = class("dict")

local s_cur_need_save_list = {}
local s_check_save_timer = nil

local function _check_do_save()
	if s_check_save_timer == nil then
		s_check_save_timer = Timer.New(function()
			for dict, _ in pairs(s_cur_need_save_list) do
				dict:do_save()
			end
			s_cur_need_save_list = {}
		end, 0, 1, nil, function()
			s_check_save_timer = nil
		end)
		s_check_save_timer:Start()
	end
end

local function _add_save_dict( dict )
	s_cur_need_save_list[dict] = true
	_check_do_save()
end

function dict:ctor(file_name, auto_save)
	self.m_file_name = file_name
	self.m_values = {} --本地数据值

	self.m_file_full_path_lua = k_dict_root_path .. file_name .. ".lua"
	-- if not FileTools.CreateFilePath(k_dict_root_path) then -- 创建dict目录
	FileTools.CreateFilePath(self.m_file_full_path_lua)
	-- end
	self.m_is_auto_save = auto_save == nil and false or auto_save --是否有修改就自动存储
	self:load()
end

function dict:read_file(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function dict:write_file(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function dict:set_auto_save(auto_save)
	self.m_is_auto_save = auto_save
end

function dict:is_empty()
	for pk,v in pairs(self.m_values) do
		return false
	end
	return true
end

function dict:is_property(key)
	for pk,v in pairs(self.m_values) do
		if pk == key then
			return true
		end
	end
	return false
end

function dict:set(key, value)
	self.m_values[key] = value
	if self.m_is_auto_save then
		self:save()
	end
end

function dict:get(key, default)
	if self:is_property(key) then
		return self.m_values[key]
	end
	return default 
end

function dict:get_number(key, default)
	return tonumber(self:get(key, default))
end

function dict:set_number(key, value)
	assert(type(value) == "number")
	self:set(key, value)
end

function dict:get_bool(key, default)
	local defaultValue = 1
	if default == nil or default == false then
		defaultValue = 0
	end
	return self:get_number(key,  defaultValue) == 1
end

function dict:set_bool(key, value)
	assert(type(value) == "boolean")
	self:set(key, value and 1 or 0)
end

function dict:get_int(key, default)
	return math.floor(self:get_number(key, default))
end

function dict:set_int(key, value)
	assert(type(value) == "number")
	self:set(key, value)
end

function dict:get_string(key, default)
	return tostring(self:get(key, default))
end

function dict:delete_property(key)
	self.m_values[key] = nil
	if self.m_is_auto_save then
		self:save()
	end
end

function dict:clear()
	self.m_values = {}
end

local function table_tostring(t)
	local mark={}
	local assign={}
	
	local function ser_table(tbl,parent)
		mark[tbl]=parent
		local tmp={}
		for k,v in pairs(tbl) do
			local key= type(k)=="number" and "["..k.."]" or "[".. string.format("%q", k) .."]"
			if type(v)=="table" then
	 			local dotkey= parent.. key
	 			if mark[v] then
	  				table.insert(assign,dotkey.."='"..mark[v] .."'")
		 		else
		  				table.insert(tmp, key.."="..ser_table(v,dotkey))
		 		end
			elseif type(v) == "string" then
		 		table.insert(tmp, key.."=".. string.format('%q', v))
			elseif type(v) == "number" or type(v) == "boolean" then
		 		table.insert(tmp, key.."=".. tostring(v))
			end
		end

		return "{"..table.concat(tmp,",").."}"
	end

	return "do local ret="..ser_table(t,"ret")..table.concat(assign," ").." return ret end"
end

local function string_totable( strData )
	local f = loadstring(strData)
	if f then
   		return f()
   	end
end

function dict:load_lua()
	if FileTools.FileExists(self.m_file_full_path_lua) then
		local data = self:read_file(self.m_file_full_path_lua)
		local status, result = xpcall(function() 
			if data == "" then
				return {}
			else
				return string_totable(data) or {}
			end
		end, __G__TRACKBACK__)

		if not status then
			result = {}
		end
		self.m_values = result
		return true
	end

	return false
end

function dict:load()
	if self.m_loaded then return end

	local beginTime = os.time()
	self:load_lua()

	self.m_loaded = true
	local costTime = os.time() - beginTime
	if costTime >= 2 then
		log.w(string.format("the dict file:%s load costtime: %d", self.m_file_name, costTime))
	end
end

function dict:save_lua()
	local info = table_tostring(self.m_values)
	self:write_file(self.m_file_full_path_lua, info)
end

function dict:save()
	_add_save_dict(self)  --延迟一帧执行save操作，防止业务层，频繁对一个dict做set 操作触发瞬间多次save操作。
end

function dict:do_save()
	self:save_lua()
end

function dict:delete()
	if FileTools.FileExists(self.m_file_full_path_lua) then
		FileTools.FileDelete(self.m_file_full_path_lua)
	end
	self.m_values = {}
end

function dict:get_values()
	return self.m_values
end

function dict:replace(values)
	if type(values) == "table" then
		self.m_values = values
	else
		self.m_values = {}
	end
	self:save()
end

function dict:is_lua_table_file_exist()
	return FileTools.FileExists(self.m_file_full_path_lua)
end

return dict