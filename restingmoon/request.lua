module(..., package.seeall)

require "wsapi.request"

function new(wsapi_env)

	-- references to wsapi stuff
	--
	req = {
		wsapi_env = wsapi_env,
		wsapi_req = wsapi.request.new(wsapi_env),
	}

	-- path and optional extension, extension wins againts HTTP_ACCEPT
	--
	req.path_info = wsapi_env["PATH_INFO"]
	req.path_ext = req.path_info:match("[^./]%.([^./]+)$")
	req.path = req.path_ext and req.path_info:sub(1,-1*(#req.path_ext+2)) or req.path_info

	req.method = wsapi_env.REQUEST_METHOD

	req.document_root = wsapi_env.DOCUMENT_ROOT
	req.app_root = wsapi_env.APP_PATH

	return req
end
