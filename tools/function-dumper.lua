--[[
	author: treythehot
	github: https://github.com/TreysCheats
--]]

assert(getsenv, 'exploit not supported')

local places_to_look = {
	game:GetService('ReplicatedStorage').Modules.Client.Systems
}

function iterate_table(t, l)
	local s = string.rep('  ', l)
	for i,v in pairs(t) do
		if type(v) == 'table' then
			if #v == 0 then print(('%s = {}'):format(i))
			else
				print(('%s%s = {'):format(s, i))
				iterate_table(v, l + 1)
				print(('%s}'):format(s))
			end
		elseif type(v) == 'string' then
			print(('%s  [string] %s = "%s"'):format(s, i, v))
		elseif type(v) == 'boolean' then
			print(('%s  [bool] %s = %s'):format(s, i, tostring(v)))
		elseif type(v) == 'number' then
			print(('%s  [number] %s = %s'):format(s, i, tostring(v)))
		elseif type(v) == 'function' then
			print(('%s  [function] %s (%s)'):format(s, i, tostring(v)))
			print(s .. '    [number]', debug.getinfo(v).numparams .. ' parameter(s)')
			print(s .. '    [number]', #debug.getconstants(v) .. ' constants')
			print(s .. '    [number]', #debug.getupvalues(v) .. ' upvalues')
		else
			print(('%s  [unknown] %s = %s'):format(s, i, tostring(v)))
		end
	end
end
function scan_script(s)
	local v = s.ClassName == 'LocalScript' and getsenv(s) or require(s)

	print(string.rep('-', 50))
	print(('[%s] %s (%s)\n'):format(s:IsA('LocalScript') and 'LocalScript' or 'ModuleScript', s.Name, s:GetFullName()))
	iterate_table(v, 0)
	print(string.rep('-', 50))
end

for i,v in pairs(places_to_look) do
	for _i, _v in pairs(v:GetDescendants()) do
		if _v.ClassName == 'LocalScript' or _v.ClassName == 'ModuleScript' then
			success = pcall(function() scan_script(_v) end)
			--success = scan_script(_v)
			if not success then 
				print(('[Error] Error loading %s (%s)\n'):format(_v.Name, _v:GetFullName()))
			end
		end
	end
end
