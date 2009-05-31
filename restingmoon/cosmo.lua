require "cosmo"
require "lfs"

function cosmo.fill_file(filename, values)
	local size = lfs.attributes(filename,"size")
	local f = io.open(filename)
	local template

	if f == nil then
		return "failed to open " .. filename
	end

	template = f:read(size)
	f:close()

	return cosmo.fill(template, values)
end
