require "restingmoon.help"

require "cosmo"
require "lfs"

function cosmo.fill_file(filename, values)
	local template = io.read_file(filename)

	if template == nil then
		return "-- failed to read "..filename.." --"
	elseif template == "" then
		return ""
	else
		return cosmo.fill(template, values)
	end
end

function cosmo.f_file(filename)
	local template = io.read_file(filename)

	return cosmo.f(template)
end
