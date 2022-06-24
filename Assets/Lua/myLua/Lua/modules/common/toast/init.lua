local ctr_wrap = class("toast_wrap_ctr", framework.mvp.ctr_base)
local toast_ctr = require("modules.common.toast.toast_ctr")

function ctr_wrap:show(tips)
    local ctr = toast_ctr.new()
    ctr:show_view(tips)
end

return {
    ctr = ctr_wrap;
}