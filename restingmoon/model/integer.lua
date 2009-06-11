module(..., package.seeall)

local decimal = require("restingmoon.model.decimal")

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
