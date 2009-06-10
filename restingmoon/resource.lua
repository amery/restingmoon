module(..., package.seeall)

-- return one or more levels in the tree
--
local function back(tree, steps)
	if steps == nil then
		steps = 1
	end

	while steps > 0 do
		tree.current = tree.current.parent
		steps = steps - 1
	end
end

-- remove all the helpers from the node and it's
-- children
--
local function finish_node(node)
	local v
	node.parent = nil
	for _, v in ipairs(node.children) do
		finish_node(v)
	end
end

-- remove all the helpers from the tree
--
local function finish(tree)
	local v
	tree.current = nil
	tree.finish, tree.back = nil, nil
	tree.literal, tree.numeric = nil, nil

	for _, v in ipairs(tree.children) do
		finish_node(v)
	end
end

-- new literal node, always exactly the same value
--
local function literal(tree, name, handler, handler404)
	local node = {
		["name"] = name,
		["type"] = "literal",
		["handler"] = handler,
		["handler404"] = handler404,
		["children"] = {},
		["parent"] = tree.current,
	}

	node.parent.children[#node.parent.children + 1] = node
	tree.current = node
end

-- new numeric variable node
--
local function numeric(tree, name, handler, handler404)
	local node = {
		["name"] = name,
		["type"] = "numeric",
		["handler"] = handler,
		["handler404"] = handler404,
		["children"] = {},
		["parent"] = tree.current,
	}

	node.parent.children[#node.parent.children + 1] = node
	tree.current = node
end

-- new resources tree, and / handler
--
function tree(handler, handler404)
	local root = {
		["handler"] = handler,
		["handler404"] = handler404,
		["children"] = {},

		["literal"] = literal,
		["numeric"] = numeric,
		["back"] = back,
		["finish"] = finish,
	}

	root["current"] = root
	return root
end

function find_handler(resources, req)
	local args = {}
	local handler, handler404

	if resources then
		local p = resources

		-- the root
		handler = p.handler
		handler404 = p.handler404

		-- for each element of the path
		for i, t in ipairs(req.path) do
			local found = false

			-- look for the right handler
			for j, v in ipairs(p.children) do
				if v.type == "literal" and v.name == t then
					p, found = v, true
					break
				elseif v.type == "numeric" then
					local n = tonumber(t)
					if n then
						p, found = v, true
						args[v.name] = n
						break
					end
				end
			end

			if found then
				if p.handler then
					handler = p.handler
				end
				if p.handler404 then
					handler404 = p.handler404
				end
			else
				handler = handler404
				args.not_found = true
				break
			end
		end
	end

	return handler, args
end
