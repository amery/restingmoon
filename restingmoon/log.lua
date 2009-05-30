require "restingmoon"

local function resource(req)
	if req.QUERY_STRING and req.QUERY_STRING ~= "" then
		return req.PATH_INFO .. "?" .. req.QUERY_STRING
	else
		return req.PATH_INFO
	end
end

function restingmoon.log_request(req)
	-- trying to mimic Apache common format
	-- http://httpd.apache.org/docs/1.3/logs.html#common
	-- "%h %l %u %t \"%r\" %>s %b"
	local fmt='%s - - %s "%s %s %s" - -'
	print(string.format(fmt,
		req.REMOTE_ADDR,
		os.date("[%F %T %z]"),
		req.REQUEST_METHOD,
		resource(req),
		req.SERVER_PROTOCOL
		))
end
