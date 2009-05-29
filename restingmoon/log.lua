require "restingmoon"

local function resource(req)
	if req.wsapi_env.QUERY_STRING and req.wsapi_env.QUERY_STRING ~= "" then
		return req.wsapi_env.PATH_INFO .. "?" .. req.wsapi_env.QUERY_STRING
	else
		return req.wsapi_env.PATH_INFO
	end
end

function restingmoon.log_request(req)
	-- trying to mimic Apache common format
	-- http://httpd.apache.org/docs/1.3/logs.html#common
	-- "%h %l %u %t \"%r\" %>s %b"
	local fmt='%s - - %s "%s %s %s" - -'
	print(string.format(fmt,
		req.wsapi_env.REMOTE_ADDR,
		os.date("[%F %T %z]"),
		req.wsapi_env.REQUEST_METHOD,
		resource(req),
		req.wsapi_env.SERVER_PROTOCOL
		))
end
