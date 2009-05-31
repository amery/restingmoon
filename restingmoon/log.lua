require "restingmoon"

local function resource(req)
	local qs = req.wsapi_env.QUERY_STRING or ""

	if qs ~= "" then
		return req.path_info .. "?" .. qs
	else
		return req.path_info
	end
end

function restingmoon.log_response(req, status, length)
	-- trying to mimic Apache common format
	-- http://httpd.apache.org/docs/1.3/logs.html#common
	-- "%h %l %u %t \"%r\" %>s %b"
	local fmt='%s - - %s "%s %s %s" %s %s'
	print(string.format(fmt,
		req.wsapi_env.REMOTE_ADDR,
		os.date("[%F %T %z]"),
		req.wsapi_env.REQUEST_METHOD,
		resource(req),
		req.wsapi_env.SERVER_PROTOCOL,
		status ~= nil and status or "-",
		length ~= nil and length or "-"
		))
end
