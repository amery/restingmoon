local m = require "restingmoon.mime"

module(..., package.seeall)

local function sender(filename, size)
	size = size or 4096
	local f = io.open(filename)
	return function()
		local data = f:read(size)
		if not data then f:close() end
		return data
	end
end

function wsapi_dispatch_file(filename, attr)
	local headers = {}
	local ext, mime
	local size = attr.blksize
	if size > attr.size then
		size = attr.size
	end

	mime = m.mime_by_filename(filename)

	-- attr.modification
	headers["Content-Type"] = mime
	headers["Content-Length"] = attr.size
	if attr.modification ~= nil then
		headers["Last-Modified"] = os.date("!%A %d-%b-%y %T %Z", attr.modification)
	end

	return 200, headers, sender(filename, size)
end
