module(..., package.seeall)

mime_table = {}
mime_ext_table = {}

function load_mimetypes(file)
	local line
	for line in io.lines(file) do
		local mimetype, data = line:match("^([^#][^%s]+)%s+(.*)%s*$")

		if mimetype then
			local ext t = {}

			if mime_table[mimetype] then
				t = mime_table[mimetype]
			else
				mime_table[mimetype] = t
			end

			for ext in data:gmatch("([^%s]+)") do
				if mime_ext_table[ext] and mimetype ~= mime_ext_table[ext] then
					io.stderr:write(string.format(
						"WARNING: MIME: %s: %s overwrites %s.\n",
						ext, mimetype, mime_ext_table[ext]))
				end

				mime_ext_table[ext] = mimetype
				t[#t + 1] = ext
			end
		end
	end
end

-- /etc/mime.types comes from debian's mime-support package
-- but other systems may not have it
--
load_mimetypes("/etc/mime.types")

-- print(table.show(mime_table,"mime_table"))
-- print(table.show(mime_ext_table,"mime_ext_table"))

function mime_by_ext(ext)
	local mime = restingmoon.mime.mime_ext_table[ext]

	return mime ~= nil and mime or "application/octet-stream"
end

function mime_by_filename(filename)
	return mime_by_ext(filename:match("[^./]%.([^./]+)$"))
end

local cache_media_range = {}
local cache_media_type = {
	["*/*"] = { type="*", subtype="*" },
}
cache_media_type["*"] = cache_media_type["*/*"]

function parse_mime_type(s)
	if type(s) ~= "string" then
		return nil
	elseif not cache_media_type[s] then
		local t = {}
		t.type, t.subtype = string.match(s, "^ *([^/]+)/([^/]+) *$")

		if not t.type then
			io.stderr:write(s, "Invalid mime-type\n")
			return nil
		end
		cache_media_type[s] = t
	end
	return cache_media_type[s]
end

function parse_media_range(s)
	if not cache_media_range[s] then
		local t = {}

		for x in string.gmatch(s, " *([^;]+) *") do
			if not t.type then
				local ct = parse_mime_type(x)
				if not ct then
					return nil
				end

				t.type, t.subtype, t.params = ct.type, ct.subtype, {q=1}
			else
				local k, v = string.match(x," *([^=]+)=([^ ]*)")
				local n = tonumber(v)
				if n then
					t.params[k] = n
				else
					t.params[k] = v
				end
			end
		end

		if next(t) ~= nil then
			if type(t.params.q) ~= "number" or t.params.q <0 or t.params.q > 1 then
				t.params.q = 1
			end

			cache_media_range[s]=t
		else
			return nil
		end
	end

	return cache_media_range[s]
end

function parse_media_ranges(s)
	if not cache_media_range[s] then
		local t = {}
		for v in string.gmatch(s, " *([^,]+) *") do
			t[#t+1] = parse_media_range(v)
		end
		cache_media_range[s]=t
	end

	return cache_media_range[s]
end

function match_media_type(a, b)
	if a.type == "*" or b.type == "*" or a.type == b.type then
		if a.subtype == "*" or b.subtype == "*" or a.subtype == b.subtype then
			return true
		end
	end
end

function choose_media_type(supported, accepted)
	local chosen, q = 0, 0
	for i, x in ipairs(supported) do
		if type(x) == "string" then
			x = parse_mime_type(x)
		end
		supported[i] = 0
		for _, t in pairs(accepted) do
			if match_media_type(x, t) then
				if supported[i] < t.params.q then
					supported[i] = t.params.q
				end
			end
		end

		if supported[i] > q then
			chosen, q = i, supported[i]
		end
	end
	return chosen
end
