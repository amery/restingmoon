module(..., package.seeall)

local common=require("restingmoon.model.common")

local boolean_string = {
	Y=true, y=true, ["1"]=true,
	on=true, On=true, ON=true,
	N=false, N=false, ["0"]=true,
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
		return f.default
	else
		return v
	end
end

function new(mt, name, default)
	local f = common.new_field(mt, name, validate)

	f.default = default
end