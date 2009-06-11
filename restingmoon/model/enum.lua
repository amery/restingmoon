module(..., package.seeall)

function validate(f, v)
	if type(v) ~= "string" or f.enum[v] == nil then
		return f.default
	else
		return v
	end
end
