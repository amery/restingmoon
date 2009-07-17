module(..., package.seeall)

require "restingmoon.model.table"
require "restingmoon.model.decimal"
require "restingmoon.model.integer"
require "restingmoon.model.enum"
require "restingmoon.model.boolean"
require "restingmoon.model.text"

-- metatable of the models
local metatable = { __index = {} }

function new()
	local model = {
		P={},
		F={},
		T={},
		__index=get_field,
		__newindex=set_field,
	}
	return setmetatable(model, metatable)
end

function metatable.__index.add_property(model, name, callback)
	if type(name) ~= "string" or #name == 0 then
		error("invalid property name.", 3)
	elseif model.P[name] or model.F[name] then
		error("duplicated property/field name.", 3)
	elseif type(callback) ~= "function" then
		error("invalid callback", 2)
	else
		model.P[name] = callback
	end
end

function metatable.__index.add_field(model, type, name, ...)
	local f = type.new(model, name, ...)
	if f then
		model.T[name] = type
		return f
	end
end

function metatable.__index.init(model, o)
	for k, f in pairs(model.F) do
		if o[k] == nil and f.default ~= nil then
			o[k] = f.default
		end
	end

	return setmetatable(o, model)
end

function set_field(t, name, value)
	local model = getmetatable(t)
	local f = model.F[name]
	if f then
		local ok, v = f.validator(f, value)
		if ok then
			rawset(t, name, v)
		elseif value == nil and f.default ~= nil then
			rawset(t, name, f.default)
		else
			error(string.format("invalid value (%q) for %s.", tostring(value), name), 2)
		end
	else
		error(string.format("object doesn't allow '%s'", name), 2)
	end
end

function get_field(t, name)
	local model, v = getmetatable(t), rawget(t, name)

	if v ~= nil then
		return v
	elseif model.P[name] then
		return model.P[name](t)
	elseif model[name] then
		return model[name]
	else
		return
	end
end
