dofile('ccpm/ccpm.lua')

ccpm_workspace 'test'
	ccpm_consoleapp 'test'
		ccpm_sources 'test'
		ccpm_pkg 'sfml-all'

ccpm_report()
