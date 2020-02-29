# CCPM
The Codecat Premake framework. Works with the latest version of [premake5](https://premake.github.io/).

Also includes a way to link libraries using `pkg-config` files, by using the `ccpm_pkg()` function.

## Example usage
The following premake file will create a `test` workspace with a `test` console application project, which has its source code located in the `test` folder, and also links with SFML using the `sfml-all` package.

```lua
dofile('ccpm/ccpm.lua')

ccpm_workspace 'test'
	ccpm_consoleapp 'test'
		ccpm_sources 'test'
		ccpm_pkg 'sfml-all'

ccpm_report()
```

Note that `ccpm_pkg()` currently only works on Linux. There is no Windows support yet. It also only handles `-L`, `-l`, and `-I` flags for now.
