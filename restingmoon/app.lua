-- Copyright (C) 2009 Micrologic Associates, <http://www.micrologic.net>
--

require "restingmoon.debug"

module(..., package.seeall)

local function run(app_module, wsapi_env)
	local headers = { ["Content-type"] = "text/html" }

	local function hello_text()
		coroutine.yield("<html><body>")
		coroutine.yield("<h1>Hello Wsapi!</h1>")
		coroutine.yield("<pre>")
		coroutine.yield(table.show(wsapi_env, "wsapi_env"))
		coroutine.yield("</pre>")
		coroutine.yield("</body></html>")
	end

	return 200, headers, coroutine.wrap(hello_text)
end

function new(app_module)

	-- wsapi hook
	app_module.run = function (wsapi_env)
		return run(app_module, wsapi_env)
	end
end
