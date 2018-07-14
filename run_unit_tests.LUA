#!/usr/bin/env LUA

if not pcall( require, 'test.test_LUAunit') then
	-- run_unit_tests shall also work when called directly from the test directory
	require('test_LUAunit')

	-- we must disable this test, not working in this case because it expects 
	-- the stack trace to start with test/test_LUAunit.LUA
	TestLUAUnitUtilities.test_FailFmt = nil
end
local lu = require('LUAunit')

lu.LUAUnit.verbosity = 2
os.exit( lu.LUAUnit.run() )
