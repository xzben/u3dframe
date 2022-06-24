local table_view = require("framework.component.table_view")
local grid_view = class("grid_view", table_view)

function grid_view:ctor( gameObject)
	table_view.ctor(self, gameObject)
end

function grid_view:init_core( gameObject )
	self.m_core = gameObject.transform:GetComponent(typeof(GridView))
end

return grid_view