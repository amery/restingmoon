local r = require "restingmoon.response"

require "os"

module(..., package.seeall)

function timestamp(t)
		return os.date("!%A %d-%b-%y %T %Z", t)
end

function send_200_head(headers)
	return 200, headers, nil
end

function send_204(headers)
	headers["Content-Length"] = 0
	return 204, headers, nil
end

function send_301(location)
	local headers = {
		["Location"] = location,
		["Content-Length"] = 0,
	}

	return 301, headers, nil
end

function send_304(headers)
	return 304, headers, nil
end

function send_405()
	headers["Content-Length"] = 0
	return 405, {}, nil
end
