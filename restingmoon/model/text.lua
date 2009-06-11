module(..., package.seeall)

local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) ~= "string" then
		return tostring(v)
	else
		return v
	end
end

function new(mt, name)
	return common.new(mt, name, validate)
end
