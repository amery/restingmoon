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

	if req.method == "HEAD" then
		return h.send_200_head(headers)
	elseif req.method ~= "GET" then
		return h.send_405()
	elseif req.wsapi_env.HTTP_IF_MODIFIED_SINCE == headers["Last-Modified"] then
		return h.send_304(headers)
	elseif attr.size == 0 then
		return h.send_204(headers)
	else
		return 200, headers, sender(filename)
	end
end
