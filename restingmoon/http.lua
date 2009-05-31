require "os"

module(..., package.seeall)

function timestamp(t)
		return os.date("!%A %d-%b-%y %T %Z", t)
end
