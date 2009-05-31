require "restingmoon.debug"
require "restingmoon.log"

require "restingmoon.request"

require "restingmoon.static"

require "lfs"

module(..., package.seeall)

function hello_world(req)
	local headers = { ["Content-type"] = "text/html" }

	local function hello_text()
		coroutine.yield("<html><body>")
		coroutine.yield("<h1>Hello Wsapi!</h1>")
		coroutine.yield("<pre>")
		coroutine.yield(table.show(req, "req"))
		coroutine.yield("</pre>")
		coroutine.yield("</body></html>")
	end

	return 200, headers, coroutine.wrap(hello_text)
end

local function run(app, wsapi_env)
	local req = restingmoon.request.new(wsapi_env)
	local status, header, body

	restingmoon.log_response(req)

	--local res = restingmoon.static.wsapi_handler(req)

	if req.document_root ~= "" then
		local filename, attr

		-- first trying straight matches
		--
		filename = req.document_root .. req.path_info
		attr = lfs.attributes(filename)

		if attr == nil then
			-- NOP
		elseif attr.mode == "file" then
			-- sweet, let's serve it immediately
			status, header, body = restingmoon.static.wsapi_dispatch_file(filename, attr)
		--[[
		elseif attr.mode == "directory" then
			print("DIR:", filename)
			]]--
		else
			print(table.show(attr, filename))
		end
	end

	if status == nil then
		status, header, body = app.app_run(req)
	end

	restingmoon.log_response(req, status, header["Content-Length"])

	return status, header, body
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
end
