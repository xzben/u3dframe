local res_loader = class("res_loader")

function res_loader:ctor()
	self.m_loader = LuaFramework.GameWorld.Inst.ResourceManager
	self.m_loadedBundle = {}
end

function res_loader:load_asset( abname, assetname )
	self:load_ab(abname)
	return self.m_loader:GetAsset(abname, assetname)
end

function res_loader:load_ab( abname )
	if self.m_loadedBundle[abname] == nil then
		self.m_loader:LoadBundle(abname)
		self.m_loadedBundle[abname] = true
	end
end

function res_loader:async_load_ab( abname, donecall)
	if self.m_loadedBundle[abname] == nil then
		self.m_loader:LoadBundleAsync(abname, function() 
			self.m_loadedBundle[abname] = true
			donecall()
		end)
	else
		donecall()
	end
end

local atlas_metatable = {
	__index = function( obj , key)
		local atlas = obj.__atlas

		if atlas == nil then
			return nil
		end
		
		return atlas:GetSprite(key)
	end,
	__newindex = function(t, key, value)
		g_log.e("不可以对 sprite_atlas 赋值")
	end
}

function res_loader:get_sprite_atlas( abname, assetname)
	local atlas = self:load_asset(abname, assetname)

	local atlas_table = { __atlas = atlas }
	setmetatable(atlas_table, atlas_metatable)

	return atlas_table
end

function res_loader:unload_asset( abname )
	self.m_loadedBundle[abname] = nil
	self.m_loader:UnloadBundle(abname)
end

function res_loader:dtor()
	for abname, _ in pairs(self.m_loadedBundle) do
		self.m_loader:UnloadBundle(abname)
	end
	self.m_loadedBundle = {}
end

return res_loader