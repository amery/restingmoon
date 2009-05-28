require "restingmoon.debug"
require "restingmoon.static"

module(..., package.seeall)

function hello_world(wsapi_env)
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

local function run(app, wsapi_env)
	if (app.overlay) then
		local status, header, body = restingmoon.static.wsapi_handler(app, wsapi_env)

		if (status) then
			return status, header, body
		end
	end
	return app.app_run(wsapi_env)
end

function new(app)

	-- wsapi hook
	--
	app.run = function (wsapi_env)
		return run(app, wsapi_env)
	end

	-- callback to the real app
	--
	app.app_run = hello_world

	-- directory for overwriting what is served by the app
	--
	app.overlay = "public"
end
