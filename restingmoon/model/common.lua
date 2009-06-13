module(..., package.seeall)

function new(mt, name, validator)
	if type(name) ~= "string" or #name == 0 then
		error("invalid field name.", 3)
	elseif mt.__properties[name] or mt.F[name] then
		error("duplicated property/field name.", 3)
	elseif type(validator) ~= "function" then
		error("no validator given.", 2)
	else
		mt.F[name] = {validator=validator}
	end
	return mt.F[name]
end
