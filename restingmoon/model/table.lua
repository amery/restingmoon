module(..., package.seeall)

local function newindex(t, key_field, key, value)
	if type(key) ~= "number" then
		rawset(t, key, value)
	elseif value == nil then
		rawset(t, key, nil)
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

local function isfull(t, maxn)
	for i = 1, maxn do
		if t[i] == nil then
			return false
		end
	end
	return true
end

local function iterator(t, maxn)
	maxn = maxn or table.maxn(t)
	if maxn > 0 then
		local f = function (_, last)
			return after(t, last, maxn)
		end
		return f, nil, 0
	else
		return function() end
	end
end

local function html_option(t, current, max, filter)
	local selected = {}

	local function nop() end
	local function yes()
		coroutine.yield({})
	end

	if filter == nil then
		-- default filter, free slots
		filter = function (id, o)
			return (o == nil)
		end
	end

	if type(current) == "nil" then
		-- NOP
	elseif type(current) == "table" then
		for _, v in pairs(current) do
			selected[v] = true
		end
	else
		selected[current] = true
	end

	return function()
		for i = 1, max do
			local data = {
				id = i,
				current = selected[i] and yes or nop,
			}

			if selected[i] or filter(i, t[i]) then
				data.selected = data.current
				coroutine.yield(data)
			end
		end
	end
end

local function update_http_post(list, id, o, post)
	local ok, all_ok, log = true, true, {}
	local key_field = list.key_field

	-- id
	local old, new = o[key_field], post[key_field]
	if new then
		if o.F[key_field].http_validator then
			ok, new = o.F[key_field]:http_validator(new)
		else
			ok, new = o.F[key_field]:validator(new)
		end

		if not ok then
			log[key_field] = "Invalid value"
			return false, log
		elseif old ~= new then
			-- relocate element
			if list[new] then
				log[key_field] = "Already in use"
				return false, log
			else
				o[key_field] = new
				list[new], list[old] = o, nil
			end
		end
	end

	for name, old in pairs(o.F) do
		new = post[name]

		if o.F[name].http_validator then
			ok, new = o.F[name]:http_validator(new)
		else
			ok, new = o.F[name]:validator(new)
		end

		if not ok then
			log[name] = "Invalid value"
		else
			o[name] = new
		end
	end

	return true, log
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
		key_field=key_field,
		after=after,
		before=before,
		iterator=iterator,
		isfull=isfull,
		html_option=html_option,
		update_http_post=update_http_post,
	}

	local mt = {
		__index = _index,
		__newindex = _newindex
	}

	return setmetatable({}, mt)
end
