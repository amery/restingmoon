local error = error
local type = type
local print = print

module(...)

function new_model()
	return { fields={} }
end

local function new_field(mt, name, validator)
	if type(name) ~= "string" or #name == 0 then
		error("invalid field name.", 3)
	elseif mt.fields[name] then
		error("duplicated field name.", 3)
	elseif type(validator) ~= "function" then
		error("no validator given.", 2)
	else
		mt.fields[name] = {validator=validator}
	end
	return mt.fields[name]
end

local function validate_integer(f, v)
	if type(v) == "string" then
		v = tonumber(v)
	end

	if type(v) ~= "number" or math.floor(v) ~= v then
		v = f.default
	else
		v = validate_decimal(f, v)
	end

	return v
end

local function validate_decimal(f, v)
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

local boolean_strings = {
	Y=true, y=true, ["1"]=true,
	on=true, On=true, ON=true,
	N=false, N=false, ["0"]=true,
	off=false, Off=false, OFF=false,
}

local function validate_boolean(f, v)
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

local function validate_string(f, v)
	if type(v) ~= "string" then
		return tostring(v)
	else
		return v
	end
end

local function validate_enum(f, v)
	if type(v) ~= "string" or f.enum[v] == nil then
		return f.default
	else
		return v
	end
end

function add_integer_field(mt, name, default, min, max)
	local f = new_field(mt, name, validate_integer)

	f.default = default
	f.min = min
	f.max = max
end

function add_decimal_field(mt, name, default, min, max)
	local f = new_field(mt, name, validate_decimal)

	f.default = default
	f.min = min
	f.max = max
end

function add_text_field(mt, name)
	new_field(mt, name, validate_string)
end

function add_boolean_field(mt, name, default)
	local f = new_field(mt, name, validate_boolean)

	f.default = default
end

function add_enum_field(mt, name, enum, default)
	local f = new_field(mt, name, validate_enum)

	f.default = default
	f.enum = enum
end
