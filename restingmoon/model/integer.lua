module(..., package.seeall)

local decimal = require("restingmoon.model.decimal")
local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) == "string" then
		v = tonumber(v)
	end

	if type(v) ~= "number" or math.floor(v) ~= v then
		return false
	else
		return decimal.validate(f, v)
	end
end

function new(mt, name, default, min, max)
	local f = common.new(mt, name, validate)

	f.default = default
	f.min = min
	f.max = max

	return f
end
