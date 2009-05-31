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
	local size = attr.size < attr.blksize and attr.size or attr.blksize
	local headers = {}

	headers["Content-Type"] = m.mime_by_filename(filename)
	headers["Content-Length"] = attr.size
	if attr.modification ~= nil then
		headers["Last-Modified"] = os.date("!%A %d-%b-%y %T %Z", attr.modification)
	end

	-- TODO: handle If-modified-since returning 304
	-- FIXME: what if it's empty?
	return 200, headers, sender(filename, size)
end
