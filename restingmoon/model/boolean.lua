module(..., package.seeall)

local common=require("restingmoon.model.common")

local boolean_string = {
	Y=true, y=true, ["1"]=true,
	on=true, On=true, ON=true,
	N=false, n=false, ["0"]=false,
	off=false, Off=false, OFF=false,
}

function validate(f, v)
	if type(v) == "number" then
		v = (v ~= 0) -- C style booleans
	elseif type(v) == "string" then
		local b = boolean_string[v]

		if b ~= nil then
			v = b
		end
	end

	if type(v) ~= "boolean" then
		return false
	else
		return true, v
	end
end

function http_validator(f, v)
	if v == nil then
		return true, false
	elseif v == "on" then
		return true, true
	else
		return false
	end
end

function new(mt, name, default)
	local f = common.new(mt, name, validate)

	f.default = default
	f.http_validator = http_validator

	return f
end
