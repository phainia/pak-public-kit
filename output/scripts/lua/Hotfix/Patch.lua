local Patch = {}

function Patch:Initialize()
  local functions = {}
  local Modules = require("Hotfix.Modules")
  for _, module in ipairs(Modules) do
    for funcName, func in pairs(module) do
      if type(func) == "function" then
        if functions[funcName] then
          error(string.format("repeat function in Patch: %s", funcName))
        end
        functions[funcName] = func
        AddHotfixResource(funcName)
      end
    end
  end
  
  function functions.__index(t, k)
    return functions[k]
  end
  
  setmetatable(Patch, functions)
  for name in pairs(functions) do
    print("Patched cpp function: " .. name)
  end
end

Patch:Initialize()
return Patch
