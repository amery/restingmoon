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
local function literal(tree, name, handler)
	local node = {
		["name"] = name,
		["type"] = "literal",
		["handler"] = handler,
		["children"] = {},
		["parent"] = tree.current,
	}

	node.parent.children[#node.parent.children + 1] = node
	tree.current = node
end

-- new numeric variable node
--
local function numeric(tree, name, handler)
	local node = {
		["name"] = name,
		["type"] = "numeric",
		["handler"] = handler,
		["children"] = {},
		["parent"] = tree.current,
	}

	node.parent.children[#node.parent.children + 1] = node
	tree.current = node
end

-- new resources tree, and / handler
--
function tree(handler)
	local root = {
		["handler"] = handler,
		["children"] = {},

		["literal"] = literal,
		["numeric"] = numeric,
		["back"] = back,
		["finish"] = finish,
	}

	root["current"] = root
	return root
end

