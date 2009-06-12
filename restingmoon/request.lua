module(..., package.seeall)

require "wsapi.request"

function new(app, wsapi_env)
	local p, t

	-- references to wsapi stuff
	--
	req = {
		wsapi_env = wsapi_env,
		wsapi_req = wsapi.request.new(wsapi_env),
	}

	-- path list and optional extension, extension wins againts HTTP_ACCEPT
	--
	req.path_info = wsapi_env["PATH_INFO"]
	req.path_ext = req.path_info:match("[^./]%.([^./]+)$")
	req.path = req.path_ext and req.path_info:sub(1,-1*(#req.path_ext+2)) or req.path_info
	p = {}
	for t in req.path:gmatch("([^/]+)") do
		p[#p+1] = t
	end
	req.path = p

	req.method = wsapi_env.REQUEST_METHOD

	req.document_root = wsapi_env.DOCUMENT_ROOT
	req.app_root = wsapi_env.APP_PATH
	req.app = app

	if req.method == "GET" then
		req.GET = req.wsapi_req.GET
	elseif req.method == "POST" then
		-- HACK HACK HACK HACK
		-- <form /> doesn't support PUT or DELETE yet, so hackish. a "delete" button will turn this
		-- into a DELETE and a "put" button will turn this into a "PUT" (update)

		if req.wsapi_req.POST["delete"] ~= nil then
			req.method = "DELETE"
		elseif req.wsapi_req.POST["put"] ~= nil then
			req.method = "PUT"
			req.POST = req.wsapi_req.POST
			req.POST["put"] = nil
		else
			req.POST = req.wsapi_req.POST
		end
	end

	return req
end
