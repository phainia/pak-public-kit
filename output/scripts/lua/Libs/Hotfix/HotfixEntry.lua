local function HotfixPrint(...)
  print("[HotFix] ", ...)
end

HotfixPrint("Load Hotfix service...")
local HOTFIX_MODULENAME = "HotFix"
local hotfixFunc, err = loadfile("Utils/HotFix.lua")
if hotfixFunc and type(hotfixFunc) == "function" then
  package.loaded[HOTFIX_MODULENAME] = hotfixFunc()
  _G.HotFix = package.loaded[HOTFIX_MODULENAME]
  require = _G.HotFix.RequireFile
else
  HotfixPrint("Require HotFix Module Fail " .. tostring(err))
end
if _G.HotFix then
  function _G.HotFix.ReloadAll()
    _G.HotFix.ClearLoadedModule()
  end
  
  function _G.HotFix.HotFix(bKeepUpvalues)
    _G.HotFix.HotFixModifyFile(bKeepUpvalues)
  end
end
