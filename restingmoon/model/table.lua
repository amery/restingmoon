module(..., package.seeall)

local function newindex(t, key_field, key, value)
	if type(value) ~= "table" then
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

local function after(t, i)
	local j = i + 1
	if j < 1 then
		return 0
	elseif t[j] ~= nil then
		return j
	else
		-- outch
		local chosen
		for k, _ in ipairs(t) do
			if k > i then
				if chosen then
					if k < chosen then
						chosen = k
					end
				else
					chosen = k
				end
			end
		end
		return chosen or 0
	end
end

local function before(t, i)
	local j = i - 1
	if j < 1 then
		return 0
	elseif t[j] ~= nil then
		return j
	else
		-- outch, expensive search
		local chosen = 0
		for k, _ in ipairs(t) do
			if k > chosen and k < i then
				chosen = k
			end
		end
		return chosen
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
	}

	local mt = {
		__index = _index,
		__newindex = _newindex
	}

	return setmetatable({}, mt)
end
