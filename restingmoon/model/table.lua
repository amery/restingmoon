module(..., package.seeall)

local function newindex(t, key_field, key, value)
	if type(key) ~= "number" then
		rawset(t, key, value)
	elseif type(value) ~= "table" then
		error("indexed ts only accept tables as elements", 2)
	elseif t[key_field] then
		error(string.format("slot %d already in use", key), 2)
	elseif value[key_field] ~= key then
		error("trying to inject a field on the wrong slot", 2)
	else
		rawset(t, key, value)
	end
end

local function newelement(t, constructor, key, ...)
	if t[key] == nil then
		t[key] = constructor(key, ...)
	end
	return t[key]
end

local function after(t, id, maxn)
	local e
	maxn = maxn or table.maxn(t)
	id = id or 0

	while id < maxn do
		id = id + 1
		e = t[id]

		if e ~= nil then
			return id, e
		end
	end
end

local function before(t, id)
	local e
	id = id or 0

	while id > 1 do
		id = id - 1
		e = t[id]
		if e ~= nil then
			return id, e
		end
	end
end

local function html_option(t, current, max)
	local function nop() end
	local function yes()
		coroutine.yield({})
	end

	return function()
		local i = 1
		while i <= max do
			if i == current then
				coroutine.yield({id=i, current=yes})
			elseif t[i] == nil then
				coroutine.yield({id=i, current=nop})
			end
			i = i + 1
		end
	end
end

function new(key_field, constructor)
	local _newindex = function(t, key, value)
		return newindex(t, key_field, key, value)
	end

	local _newelement = function(t, key, ...)
		return newelement(t, constructor, key, ...)
	end

	local _index = {
		new=_newelement,
		after=after,
		before=before,
		html_option=html_option,
	}

	local mt = {
		__index = _index,
		__newindex = _newindex
	}

	return setmetatable({}, mt)
end
