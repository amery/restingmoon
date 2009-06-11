module(..., package.seeall)

local decimal = require("restingmoon.model.decimal")
local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) == "string" then
		v = tonumber(v)
	end

	if type(v) ~= "number" or math.floor(v) ~= v then
		v = f.default
	else
		v = decimal.validate(f, v)
	end

	return v
end

function new(mt, name, default, min, max)
	local f = common.new_field(mt, name, validate)

	f.default = default
	f.min = min
	f.max = max
end
