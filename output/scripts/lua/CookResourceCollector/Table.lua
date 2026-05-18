local PathValidator = require("CookResourceCollector.Validator")
local Logger = require("CookResourceCollector.Logger")

local function CreateResourceTable(tableName)
  local resource_table = {}
  if UE4.UNRCStatics.IsEditor() then
    local mt = {
      _isResourceTable = true,
      __newindex = function(t, key, value)
        local isRegex = type(value) == "table" and value.isRegex
        if isRegex then
          rawset(resource_table, key, value)
          if 0 == UE4.UAssetPipelineHelper.GatherResourcePackageNames("/Game", value.pattern):Length() then
            Logger:LogScreenError("No resource found in Game Content for pattern: " .. value.pattern)
          end
        else
          local is_valid = PathValidator:ValidatePath(value)
          if not is_valid then
            local msg = "Invalid Resource Path: " .. value
            if nil ~= tableName then
              Logger:LogScreenError("[" .. tableName .. "] " .. msg)
            else
              Logger:LogScreenError("[..] " .. msg)
            end
          else
            Logger:LogScreenError("Valid path:", value)
          end
          rawset(resource_table, key, value)
        end
      end
    }
    setmetatable(resource_table, mt)
  end
  return resource_table
end

return CreateResourceTable
