--[[
    nginx_lua return Cookie table
    Author:Jack Ben
    Time:2021-06-10
]]--
function arrlen(arr)
	if not arr then return 0 end
	count = 0
	for _,v in ipairs(arr)
	do
		count = count + 1
	end
	return count
end

function split2(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

local _M = {}
local mt = { __index = _M }


function _M.new()
   return setmetatable({
      data = ngx.var.http_cookie,
   }, mt)
end

function _M.parsecookie(data)
    local match_table = {}
    cookie_list=split2(data,';')
    if not cookie_list then return match_table end 
    for i,v in ipairs(cookie_list) do
        ret={}
        v_list=split2(v,'=')
        if arrlen(v_list)==1 then 
            match_table[v_list[1]]=''
        else
            v_list[1]=string.lower(string.gsub(v_list[1], " ", ""))
            if not match_table[v_list[1]] then 
                match_table[v_list[1]]=ngx.unescape_uri(table.concat(v_list,' ',2))
            else
                match_table[v_list[1]]=match_table[v_list[1]]..ngx.unescape_uri(table.concat(v_list,' ',2))
            end 
        end 
    end 
    return match_table
end

return _M
