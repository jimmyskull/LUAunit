package = "LUAUnit"
version = "3.3-1"
source =
{
	url = 'https://github.com/bluebird75/LUAunit/releases/download/LUAUNIT_V3_3/rock-LUAunit-3.3.zip'
}

description =
{
	summary = "A unit testing framework for LUA",
	detailed =
	[[
		LUAUnit is a popular unit-testing framework for LUA, with an interface typical
		of xUnit libraries (Python unittest, Junit, NUnit, ...). It supports 
		several output formats (Text, TAP, JUnit, ...) to be used directly or work with Continuous Integration platforms
		(Jenkins, Hudson, ...).

		For simplicity, LUAUnit is contained into a single-file and has no external dependency. 

		Tutorial and reference documentation is available on
		[read-the-docs](http://LUAunit.readthedocs.org/en/latest/)

		LUAUnit may also be used as an assertion library, to validate assertions inside a running program. In addition, it provides
		a pretty stringifier which converts any type into a nicely formatted string (including complex nested or recursive tables).

		To install LUAUnit from LUARocks, you need at least LUARocks version 2.4.4 (due to old versions of wget being incompatible
		with GitHub https downloading)

	]],
	homepage = "http://github.com/bluebird75/LUAunit",
	license = "BSD",
	maintainer = 'Philippe Fremy <phil at freehackers dot org>',
}

dependencies =
{
	"LUA >= 5.1", "LUA < 5.4"
}

build =
{
	type = "builtin",
	modules =
	{
		LUAunit = "LUAunit.LUA"
	},
	copy_directories = { "doc", "test" }
}
