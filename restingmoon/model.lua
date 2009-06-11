module(..., package.seeall)

require "restingmoon.model.table"
require "restingmoon.model.decimal"
require "restingmoon.model.integer"
require "restingmoon.model.enum"
require "restingmoon.model.boolean"
require "restingmoon.model.text"


-- metatable of the models
local metatable = { __index = {} }

function new_model()
	local model = {
		__properties={},
		__fields={},
		__index=get_field,
		__newindex=set_field,
	}
	return setmetatable(model, metatable)
end

function metatable.__index.add_property(mt, name, callback)
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

function metatable.__index.add_field(mt, type, ...)
	type.new(mt, ...)
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
