local m = require "restingmoon.mime"
local h = require "restingmoon.http"

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

function wsapi_dispatch_file(req, filename, attr)
	local headers = {
		["Content-Type"] = m.mime_by_filename(filename),
		["Content-Length"] = attr.size
	}

	if attr.modification ~= nil then
		headers["Last-Modified"] = h.timestamp(attr.modification)
	end

	-- TODO: handle different request methods
	-- TODO: handle If-modified-since returning 304
	-- FIXME: what if it's empty?
	return 200, headers, sender(filename)
end
