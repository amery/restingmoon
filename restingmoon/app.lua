require "restingmoon.log"

require "restingmoon.request"

require "restingmoon.static"

local h = require "restingmoon.http"
local m = require "restingmoon.mime"
local r = require "restingmoon.resource"

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
	local req = restingmoon.request.new(app, wsapi_env)
	local status, header, body

	restingmoon.log_response(req)

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
			status, header, body = restingmoon.static.wsapi_dispatch_file(req, filename, attr)
		elseif attr.mode == "directory" then
			-- TODO: find possible ${path}.* and ${path}/index.*
			if req.path_info:sub(-1,-1) ~= "/" then
				-- use canonical
				status, header, body = h.send_301(req.path_info .. "/")
			end
		else
			io.stderr(table.show(attr, filename))
		end
	end

	if status == nil then
		-- pick a resource handler
		local handler, args = r.find_handler(app.resources, req)
		local accepted

		-- wanted mime types
		if req.path_ext then
			accepted = {m.parse_media_range(m.mime_by_ext(req.path_ext))}
		else
			accepted = m.parse_media_ranges(req.wsapi_env.HTTP_ACCEPT)
		end

		if handler then
			-- NOP
		elseif app.default_handler then
			handler = app.default_handler
		else
			handler = hello_world
		end

		status, header, body = handler(req, args, accepted)
	end

	restingmoon.log_response(req, status, header and header["Content-Length"])

	return status, header, body
end

function new(app)

	-- wsapi hook
	--
	app.run = function(wsapi_env)
		return run(app, wsapi_env)
	end
end
