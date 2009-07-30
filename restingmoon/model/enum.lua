module(..., package.seeall)

local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) ~= "string" or f.enum[v] == nil then
		return false
	else
		return true, v
	end
end

function raw_html_option(enum, current, filter)
	local selected = {}

	local function nop() end
	local function yes()
		coroutine.yield({})
	end

	if filter == nil then
		filter = function() return true end
	end

	if type(current) == "nil" then
		-- NOP
	elseif type(current) == "table" then
		for _, v in pairs(current) do
			selected[v] = true
		end
	else
		selected[current] = true
	end

	return function()
		for k, v in pairs(enum) do
			if filter(k) then
				local data = { id=k, name=v }

				data.current = selected[k] and yes or nop
				data.selected = data.current

				coroutine.yield(data)
			end
		end
	end
end

function html_option(f, current, filter)
	if type(current) == "table" then
		-- it's the object
		current = current[f.name]
	end

	return raw_html_option(f.enum, current, filter)
end

function new(mt, name, enum, default)
	local f = common.new(mt, name, validate)

	f.default = default
	f.enum = enum
	f.html_option = html_option

	return f
end
