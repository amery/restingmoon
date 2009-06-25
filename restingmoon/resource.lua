module(..., package.seeall)

local index = {}

-- return one or more levels in the tree
--
function index.back(tree, steps)
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
function index.finish(tree)
	local v
	tree.current = nil
	tree.finish, tree.back = nil, nil
	tree.literal, tree.numeric = nil, nil

	for _, v in ipairs(tree.children) do
		finish_node(v)
	end
end

function new_node(tree, name)
	local node = {
		name = name,
		children = {},
		parent = tree.current,
	}

	node.parent.children[#node.parent.children + 1] = node
	tree.current = node

	return node
end

-- new literal node, always exactly the same value
--
function index.literal(tree, name, handler, handler404)
	local node = new_node(tree, name)

	node.type = "literal"
	node.handler = handler
	node.handler404 = handler404
end

-- new numeric variable node
--
function index.numeric(tree, name, handler, handler404)
	local node = new_node(tree, name)

	node.type = "numeric"
	node.handler = handler
	node.handler404 = handler404
end

local tree_mt = { __index = index }

-- new resources tree, and / handler
--
function tree(handler, handler404)
	local root = {
		["handler"] = handler,
		["handler404"] = handler404,
		["children"] = {},
	}

	root["current"] = root
	return setmetatable(root, tree_mt)
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
