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
