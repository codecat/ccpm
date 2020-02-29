local _pkg_find_paths = {
	'/usr/lib/pkgconfig',
	'/usr/lib/x86_64-linux-gnu/pkgconfig',
	'/usr/share/pkgconfig',
}

local function _pkg_find_path(name)
	for _, findpath in ipairs(_pkg_find_paths) do
		local p = path.join(findpath, name .. '.pc')
		if os.isfile(p) then
			return p
		end
	end
end

local function _pkg_str_replace(str, variables)
	return str:gsub('${([^}]+)}', function(c)
		return variables[c]
	end)
end

local function _pkg_from_cache(name)
	for _, pkg in ipairs(CCPM_GLOBAL_PACKAGES) do
		if pkg.id == name then
			return pkg
		end
	end
end

local function _pkg_open(name)
	local filepath = _pkg_find_path(name)
	if filepath == nil then
		premake.error('Unable to find package "' .. name .. '"!')
	end

	local variables = {}
	local properties = {}

	for line in io.lines(filepath) do
		if line:len() > 0 and line:sub(1, 1) ~= '#' then
			k, v = line:match('^([A-Z][^:]+): (.*)$')
			if k ~= nil and v ~= nil then
				properties[k] = _pkg_str_replace(v, variables)
			else
				k, v = line:match('^([^=]+)=(.*)$')
				if k == nil or v == nil then
					reading_variables = false
				else
					variables[k] = _pkg_str_replace(v, variables)
				end
			end
		end
	end

	local pkg = {
		id = name,

		name = properties['Name'],
		version = properties['Version'],

		libs = {},
		libdirs = {},
		includedirs = {},
		defines = {},

		requires = {},
	}

	table.insert(CCPM_GLOBAL_PACKAGES, pkg)

	--TODO: Libs.private (for static configurations)
	-- Handle linker flags (-L and -l)
	local libs = properties['Libs']
	if libs ~= nil then
		for flag in libs:gmatch('-[^ ]+') do
			flag_lib = flag:match('^-l(.*)$')
			if flag_lib ~= nil then
				table.insert(pkg.libs, flag_lib)
			end

			flag_libdir = flag:match('^-L(.*)$')
			if flag_libdir ~= nil then
				table.insert(pkg.libdirs, flag_libdir)
			end
		end
	end

	-- Handle compiler flags (-I and -D)
	local cflags = properties['Cflags']
	if cflags ~= nil then
		for flag in cflags:gmatch('-[^ ]+') do
			flag_include = flag:match('^-I(.*)$')
			if flag_include ~= nil and flag_include ~= '/usr/include' and flag_include ~= '/usr/local/include' then
				table.insert(pkg.includedirs, flag_include)
			end

			flag_define = flag:match('^-D(.*)$')
			if flag_define ~= nil then
				table.insert(pkg.defines, flag_define)
			end
		end
	end

	--TODO: Requires.private (for static configurations)
	-- Load any dependencies
	local requires = properties['Requires']
	if requires ~= nil then
		for req in requires:gmatch('[^, ]+') do
			dep = _pkg_from_cache(req)
			if dep == nil then
				dep = _pkg_open(req)
			end
			table.insert(pkg.requires, dep)
		end
	end

	return pkg
end

local function _pkg_add(pkg, added)
	added = added or {}

	for _, libdir in ipairs(pkg.libdirs) do
		libdirs(libdir)
	end

	for _, lib in ipairs(pkg.libs) do
		links(lib)
	end

	for _, dir in ipairs(pkg.includedirs) do
		includedirs(dir)
	end

	for _, define in ipairs(pkg.defines) do
		defines(define)
	end

	for _, dep in ipairs(pkg.requires) do
		if not added[dep.id] then
			added[dep.id] = true
			_pkg_add(dep, added)
		end
	end
end

function ccpm_pkg(name)
	pkg = _pkg_from_cache(name)
	if pkg == nil then
		pkg = _pkg_open(name)
	end

	if pkg ~= nil then
		_pkg_add(pkg)
	end
end
