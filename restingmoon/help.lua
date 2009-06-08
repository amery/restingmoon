local lfs = require "lfs"

-- io.read_file() reads the entire content
-- of a file at once
--
function io.read_file(filename)
	local size = lfs.attributes(filename,"size")

	if size == nil then
		return nil
	elseif size > 0 then
		local f = io.open(filename)
		local data = f:read(size)
		f:close()
		return data
	end
	return ""
end

-- string.split(s, d)
-- splits an string using a delimiter

function string.split(s, d)
	local t = {}
	d = "([^"..d.."]+)"

	for v in string.gmatch(s, d) do
		t[#t+1] = v
	end
	return t
end

-- table.show() stolen from
-- http://lua-users.org/wiki/TableSerialization
--
function table.show(t, name, indent)
	local cart	-- a container
	local autoref	-- for self references

	-- (RiciLake) returns true if the table is empty
	local function isemptytable(t) return next(t) == nil end

	local function basicSerialize (o)
		local so = tostring(o)
		if type(o) == "function" then
			local info = debug.getinfo(o, "S")
			-- info.name is nil because o is not a calling level
			if info.what == "C" then
				return string.format("%q", so .. ", C function")
			else
				-- the information is defined through lines
				return string.format("%q", so .. ", defined in (" ..
					info.linedefined .. "-" .. info.lastlinedefined ..
					")" .. info.source)
			end
		elseif type(o) == "boolean" then
			return o and "true" or "false"
		elseif type(o) == "number" then
			return so
		else
			return string.format("%q", so)
		end
	end

	local function addtocart (value, name, indent, saved, field)
		indent = indent or ""
		saved = saved or {}
		field = field or name

		cart = cart .. indent .. field

		if type(value) ~= "table" then
			cart = cart .. " = " .. basicSerialize(value) .. ";\n"
		elseif saved[value] then
			cart = cart .. " = {}; -- " .. saved[value] ..
				" (self reference)\n"
			autoref = autoref ..  name .. " = " .. saved[value] ..
				";\n"
		else
			saved[value] = name
			if isemptytable(value) then
				cart = cart .. " = {};\n"
			else
				cart = cart .. " = {\n"
				for k, v in pairs(value) do
					k = basicSerialize(k)
					local fname = string.format("%s[%s]", name, k)
					field = string.format("[%s]", k)
					-- three spaces between levels
						addtocart(v, fname, indent .. "   ", saved, field)
				end
				cart = cart .. indent .. "};\n"
			end
		end
	end

	name = name or "__unnamed__"
	if type(t) ~= "table" then
		return name .. " = " .. basicSerialize(t)
	end
	cart, autoref = "", ""
	addtocart(t, name, indent)
	return cart .. autoref
end