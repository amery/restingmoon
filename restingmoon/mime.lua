require "restingmoon.debug"

module(..., package.seeall)

mime_table = {}
mime_ext_table = {}

function load_mimetypes(file)
	local line
	for line in io.lines(file) do
		local mimetype, data = line:match("^([^#][^%s]+)%s+(.*)%s*$")
		local t = {}

		if mimetype then
			local ext

			if mime_table[mimetype] then
				t = mime_table[mimetype]
			else
				mime_table[mimetype] = t
			end

			for ext in data:gmatch("([^%s]+)") do
				if mime_ext_table[ext] and mimetype ~= mime_ext_table[ext] then
					io.stderr:write(string.format(
						"ERROR: MIME: %s (%s) conflicting type (%s)\n",
						ext, mime_ext_table[ext], mimetype))
				else
					mime_ext_table[ext] = mimetype
				end

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
