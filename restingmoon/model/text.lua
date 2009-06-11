module(..., package.seeall)

function validate(f, v)
	if type(v) ~= "string" then
		return tostring(v)
	else
		return v
	end
end
