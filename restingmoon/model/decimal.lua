module(..., package.seeall)

local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) == "string" then
		v = tonumber(v)
	end

	if type(v) ~= "number" then
		-- NOP
	elseif f.min and v < f.min then
		-- NOP
	elseif f.max and v > f.max then
		-- NOP
	else
		-- valid number
		return v
	end

	return f.default
end

function new(mt, name, default, min, max)
	local f = common.new(mt, name, validate)

	f.default = default
	f.min = min
	f.max = max

	return f
end
