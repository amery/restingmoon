local r = require "restingmoon.response"

require "os"

module(..., package.seeall)

function timestamp(t)
		return os.date("!%A %d-%b-%y %T %Z", t)
end

function send_301(location)
	local headers = { ["Location"] = location }
	local res = r.new(301, headers)

	res:write("redirect")

	return res:finish()
end
