local http_manager = class("http_manager")
local WWW = UnityEngine.WWW;

function http_manager:ctor()

end

local function _htppRet( co )
	local ret =  {}
	
	function ret:cancel() 
		coroutine.stop(co)
	end

	return ret
end

function http_manager:get(url, doneCallback, ...)
	local params = { ... }

	local co = coroutine.start(function() 
		local www = WWW(url)
		coroutine.www(www);
		if www.error == nil then
			doneCallback(www.text, url, nil, unpack(params))
		else
			doneCallback(nil, url, www.error, unpack(params))
		end
	end)

	return _htppRet(co)
end

function http_manager:get_time_out( timeout, url, doneCallback, ...)
	local params = { ... }
	local co = coroutine.start(function() 
		local www = WWW(url);
		coroutine.wwwTimeOut(www, timeout)
		if www.isDone then
			if www.error == nil then
				doneCallback(www.text, url, nil, unpack(params))
			else
				doneCallback(nil, url, www.error, unpack(params))
			end
		else
			doneCallback(nil, url, "request timeout", unpack(params))
		end
	end)

	return _htppRet(co)
end


-- 数据转换，将请求数据由 table 型转换成 string，参数：table  
local function _dataParse(data)  
    if "table" ~= type(data) then  
        log.w("data is not a table")  
        return nil  
    end  
  
    local tmp = {}  
    for key, value in pairs(data) do  
        table.insert(tmp,key.."="..value)  
    end  
  
    local newData = ""  
    for i=1,#tmp do  
        newData = newData..tostring(tmp[i])  
        if i<#tmp then  
            newData = newData.."&&"  
        end  
    end   
    return newData
end  

function http_manager:post( url, data, doneCallback, ...)
	local params = {...}
	local co = coroutine.start(function() 
		local postData = _dataParse(data)
		local www = WWW(url, postData)
		coroutine.www(www);
		if www.error == nil then
			doneCallback(www.text, url, nil, unpack(params))
		else
			doneCallback(nil, url, www.error, unpack(params))
		end
	end)
	return _htppRet(co)
end

return http_manager.new()