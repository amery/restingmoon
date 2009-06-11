module(..., package.seeall)

local common=require("restingmoon.model.common")

function validate(f, v)
	if type(v) ~= "string" or f.enum[v] == nil then
		return f.default
	else
		return v
	end
end

function new(mt, name, enum, default)
	local f = common.new(mt, name, validate)

	f.default = default
	f.enum = enum

	return f
end
