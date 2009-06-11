module(..., package.seeall)

require "restingmoon.model.table"
local decimal=require("restingmoon.model.decimal")
local integer=require("restingmoon.model.integer")
local enum=require("restingmoon.model.enum")
local boolean=require("restingmoon.model.boolean")
local text=require("restingmoon.model.text")

function new_model()
	return {
		__properties={},
		__fields={},
		__index=get_field,
		__newindex=set_field,
	}
end

function add_property(mt, name, callback)
	if type(name) ~= "string" or #name == 0 then
		error("invalid property name.", 3)
	elseif mt.__properties[name] or mt.__fields[name] then
		error("duplicated property/field name.", 3)
	elseif type(callback) ~= "function" then
		error("invalid callback", 2)
	else
		mt.__properties[name] = callback
	end
end

local function new_field(mt, name, validator)
	if type(name) ~= "string" or #name == 0 then
		error("invalid field name.", 3)
	elseif mt.__properties[name] or mt.__fields[name] then
		error("duplicated property/field name.", 3)
	elseif type(validator) ~= "function" then
		error("no validator given.", 2)
	else
		mt.__fields[name] = {validator=validator}
	end
	return mt.__fields[name]
end

function set_field(t, name, value)
	local mt = getmetatable(t)
	local f = mt.__fields[name]
	if f then
		local v = f.validator(f, value)
		rawset(t, name, v)
	else
		error(string.format("object doesn't allow '%s'", name), 2)
	end
end

function get_field(t, name)
	local mt = getmetatable(t)

	if mt.__properties[name] then
		return mt.__properties[name](t)
	elseif mt.__fields[name] then
		local v = mt.__fields[name].validator(f, value)
		rawset(t, name, v)
		return v
	else
		-- don't break the world intentionally
		return nil
	end
end

function add_integer_field(mt, name, default, min, max)
	local f = new_field(mt, name, integer.validate)

	f.default = default
	f.min = min
	f.max = max
end

function add_decimal_field(mt, name, default, min, max)
	local f = new_field(mt, name, decimal.validate)

	f.default = default
	f.min = min
	f.max = max
end

function add_text_field(mt, name)
	new_field(mt, name, text.validate)
end

function add_boolean_field(mt, name, default)
	local f = new_field(mt, name, boolean.validate)

	f.default = default
end

function add_enum_field(mt, name, ref_enum, default)
	local f = new_field(mt, name, enum.validate)

	f.default = default
	f.enum = ref_enum
end
