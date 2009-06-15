module(..., package.seeall)

local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) ~= "string" or f.enum[v] == nil then
		return false
	else
		return true, v
	end
end

function html_option(f, current)
	local function nop() end
	local function yes()
		coroutine.yield({})
	end

	if type(current) == "table" then
		-- it's the object
		current = current[f.name]
	end

	return function()
		for k, v in pairs(f.enum) do
			coroutine.yield{
				id=k,
				name=v,
				current= (k == current) and yes or nop,
			}
		end
	end
end

function new(mt, name, enum, default)
	local f = common.new(mt, name, validate)

	f.default = default
	f.enum = enum
	f.html_option = html_option

	return f
end
