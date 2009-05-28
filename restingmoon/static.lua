module(..., package.seeall)

require "lfs"

local types = {
	ico = "image/x-icon",
	gif = "image/gif",
	jpg = "image/jpeg",
	txt = "text/plain",
	}

local function content_type(path)
	local ext = path:match("%.([^.]+)$")
	return types[ext]
end

local function make_header(filename)
	return {
		["Content-Type"] = content_type(filename),
		["Content-Length"] = lfs.attributes(filename, "size")
		}
end

local function sender(filename, size)
	size = size or 4096
	local f = io.open(filename)
	return function()
		local data = f:read(size)
		if not data then f:close() end
		return data
	end
end

local function dispatch_file(app, env, filename)
	return 200, make_header(filename), sender(filename)
end

function wsapi_handler(app, env)
	local filename = env.APP_PATH .. "/" .. app.overlay .. env.PATH_INFO
	local mode = lfs.attributes(filename, "mode")

	if (mode == "directory") then
		-- TODO: consider Accept: header
		filename = filename .. "/index.html"
		mode = lfs.attributes(filename, "mode")
	end

	if (mode == "file") then
		return dispatch_file(app, env, filename)
	else
		return nil
	end
end
