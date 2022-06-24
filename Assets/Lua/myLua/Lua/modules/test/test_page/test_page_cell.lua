
local test_page_cell = class("test_page_cell", utils.table_view_cell)

function test_page_cell:ctor( gameObject)
	utils.table_view_cell.ctor(self, gameObject)
end

--- 此接口为统一用来初始化界面使用，不重写则可以自己选择构造函数一个合适时机初始化界面使用
function test_page_cell:on_init()
	self.titleTxt = self:get_child_by_name("title", "Text")
end

-- 必须具体实现 的类重写用于更新 cell 界面样式
function test_page_cell:update_data(index, data)
	self.titleTxt.text = "测试index:"..index
end

return test_page_cell