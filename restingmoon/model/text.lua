module(..., package.seeall)

local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) ~= "string" then
		v = tostring(v)
	end

	if type(v) == "string" then
		return true, v
	else
		return false
	end
end

function new(mt, name)
	return common.new(mt, name, validate)
end
