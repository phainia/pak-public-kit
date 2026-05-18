local rapidjson = require("rapidjson")
local CookResourceCollectorUtils = {}

function CookResourceCollectorUtils:DumpJson(file_path, content)
  local encoded = rapidjson.encode(content)
  local success = UE4.UNRCStatics.WriteToFile(file_path, encoded)
  return success
end

function CookResourceCollectorUtils:RemoveDuplicateValuesFromTable(tbl)
  local unique_elements = {}
  local out_tbl = {}
  for _, value in pairs(tbl) do
    if not unique_elements[value] then
      unique_elements[value] = true
      table.insert(out_tbl, value)
    end
  end
  return out_tbl
end

return CookResourceCollectorUtils
