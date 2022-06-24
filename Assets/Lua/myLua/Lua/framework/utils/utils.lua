local utils = {}

createAutoRequire(utils, require, {
	table_view 		= "framework.component.table_view";
	grid_view 		= "framework.component.grid_view";
	table_view_cell = "framework.component.table_view_cell";
	url_image_view  = "framework.component.url_image_view";
	page_table_view = "framework.component.page_table_view";
	dynamic_table_view = "framework.component.dynamic_table_view";

	union_table 	= "framework.data.union_table";
	ui 				= "framework.utils.ui.ui";
	http_manager 	= "framework.utils.http.htpp_manager";
	dict 			= "framework.utils.store.dict"
})


utils.action = {}

createAutoRequire(utils.action, require, {
	action_manager = "framework.utils.action.action_manager";
	
	-- ease 缓动容器
	ease_back_in 					= "framework.utils.action.ease.ease_back_in";
	ease_back_in_out 				= "framework.utils.action.ease.ease_back_in_out";
	ease_back_out 					= "framework.utils.action.ease.ease_back_out";
	ease_bounce_in 					= "framework.utils.action.ease.ease_bounce_in";
	ease_bounce_in_out 				= "framework.utils.action.ease.ease_bounce_in_out";
	ease_bounce_out 				= "framework.utils.action.ease.ease_bounce_out";
	ease_circle_action_in 			= "framework.utils.action.ease.ease_circle_action_in";
	ease_circle_action_in_out 		= "framework.utils.action.ease.ease_circle_action_in_out";
	ease_circle_action_out 			= "framework.utils.action.ease.ease_circle_action_out";
	ease_cubic_action_in 			= "framework.utils.action.ease.ease_cubic_action_in";
	ease_cubic_action_in_out 		= "framework.utils.action.ease.ease_cubic_action_in_out";
	ease_cubic_action_out 			= "framework.utils.action.ease.ease_cubic_action_out";
	ease_exponential_in 			= "framework.utils.action.ease.ease_exponential_in";
	ease_exponential_in_out 		= "framework.utils.action.ease.ease_exponential_in_out";
	ease_exponential_out 			= "framework.utils.action.ease.ease_exponential_out";
	ease_in 						= "framework.utils.action.ease.ease_in";
	ease_in_out 					= "framework.utils.action.ease.ease_in_out";
	ease_out 						= "framework.utils.action.ease.ease_out";
	ease_quadratic_action_in 		= "framework.utils.action.ease.ease_quadratic_action_in";
	ease_quadratic_action_in_out 	= "framework.utils.action.ease.ease_quadratic_action_in_out";
	ease_quadratic_action_out 		= "framework.utils.action.ease.ease_quadratic_action_out";
	ease_quartic_action_in 			= "framework.utils.action.ease.ease_quartic_action_in";
	ease_quartic_action_in_out 		= "framework.utils.action.ease.ease_quartic_action_in_out";
	ease_quartic_action_out 		= "framework.utils.action.ease.ease_quartic_action_out";
	ease_quintic_action_in 			= "framework.utils.action.ease.ease_quintic_action_in";
	ease_quintic_action_in_out 		= "framework.utils.action.ease.ease_quintic_action_in_out";
	ease_quintic_action_out 		= "framework.utils.action.ease.ease_quintic_action_out";
	ease_sine_in					= "framework.utils.action.ease.ease_sine_in";
	ease_sine_in_out				= "framework.utils.action.ease.ease_sine_in_out";
	ease_sine_out 					= "framework.utils.action.ease.ease_sine_out";
	ease_elastic_in					= "framework.utils.action.ease.ease_elastic_in";
	ease_elastic_in_out				= "framework.utils.action.ease.ease_elastic_in_out";
	ease_elastic_out				= "framework.utils.action.ease.ease_elastic_out";
	ease_bezier_action				= "framework.utils.action.ease.ease_bezier_action";


	--基础类
	action_base 					= "framework.utils.action.action_base";
	action_helper 					= "framework.utils.action.action_helper";
	action_instant 					= "framework.utils.action.action_instant";
	action_interval 				= "framework.utils.action.action_interval";

	-- 延时动作
	delay_time 						= "framework.utils.action.interval.delay_time";
	fade_in 						= "framework.utils.action.interval.fade_in";
	fade_out 						= "framework.utils.action.interval.fade_out";
	move_by 						= "framework.utils.action.interval.move_by";
	move_to 						= "framework.utils.action.interval.move_to";
	rotation_by 					= "framework.utils.action.interval.rotation_by";
	scale_by  						= "framework.utils.action.interval.scale_by";
	scale_to 		 				= "framework.utils.action.interval.scale_to";
	
	-- 实时动作
	call_func 						= "framework.utils.action.instant.call_func";

	-- 动作容器
	repeat_forever 					= "framework.utils.action.containor.repeat_forever";
	repeated 						= "framework.utils.action.containor.repeated";	
	sequence 						= "framework.utils.action.containor.sequence";
	spawn 							= "framework.utils.action.containor.spawn"
})


local s_server_offset_time = 0;

function utils.set_server_offset_time( offset )
	s_server_offset_time = offset
end

function utils.server_time()
	local curtime = os.time()

	return curtime + s_server_offset_time
end

function utils.spliterString( str, pattern )
	local fIdx = 1  
	local result = {} 
	local strPattern = pattern

	while true do  
	   local sIdx, eIdx = string.find(str, strPattern, fIdx, true)  
	   if sIdx == nil then  
	    table.insert(result, string.sub(str, fIdx))  
	    break
	   end 

	   table.insert(result, string.sub(str, fIdx, sIdx - 1))
	   fIdx = eIdx + 1  
	end
	return result
end

--//返回 0 代表版本相等  > 0 代表 versionA > versionB  否则代表 versionA < versionB
function utils.compareVersion( version1, version2)
	local v1 = utils.spliterString(version1, ".")
	local v2 = utils.spliterString(version2, ".")

	local len_v1 = #v1
	local len_v2 = #v2
	for i = 1, #len_v1, 1 do
		local a = tonumber(v1[i])
		local b = 0

		if i <= len_v2 then
			b = tonumber(v2[i])
		end

		if a ~= b then
			return a - b;
		end
	end

	if len_v2 > len_v1 then
		return -1
	end

	return 0
end

return utils