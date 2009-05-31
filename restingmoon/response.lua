module(..., package.seeall)

require "wsapi.response"

function new(status, headers, body)
	return wsapi.response.new(status, headers, body)
end
