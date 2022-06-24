local ctr_wrap = class("msg_box_wrap_ctr", framework.mvp.ctr_base)
local msg_box_ctr = require("modules.common.msg_box.msg_box_ctr")

function ctr_wrap:show(tips, confirm, cancel, autoClose)
    local ctr = msg_box_ctr.new()
    ctr:show(tips, confirm, cancel, autoClose)
end

function ctr_wrap:show_with_title(title, tips, confirm, cancel, autoClose)
    local ctr = msg_box_ctr.new()
    ctr:show_with_title(tips, confirm, cancel, autoClose)
end

return {
    ctr = ctr_wrap;
}