--[[
LUAcheck configuration
(see http://LUAcheck.readthedocs.io/en/stable/config.html)
Thanks to Peter Melnichenko for providing an example file for LUAUnit.
]]

only = {"1"} -- limit checks to the use of global variables
std = "max"
self = false
ignore = {"[Tt]est[%w_]+"}

files = {
    ["LUAunit.LUA"] = {
        globals = {"EXPORT_ASSERT_TO_GLOBALS", "LUAUnit"},
    },
    ["test/compat_LUAunit_v2x.LUA"] = {
        ignore = {"EXPORT_ASSERT_TO_GLOBALS", "assert[%w_]+", "v", "y"}
    },
    ["test/legacy_example_with_LUAunit.LUA"] = {
        ignore = {"LUAUnit", "EXPORT_ASSERT_TO_GLOBALS",
        "assertEquals", "assertNotEquals", "assertTrue", "assertFalse"}
    },
    ["test/test_LUAunit.LUA"] = {
        ignore = {"TestMock", "TestLUAUnit%a+", "MyTest%w+", "v", "y" } 
    }
}
