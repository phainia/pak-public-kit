local RapidJson = require("rapidjson")
local LoginConfig = {}

function LoginConfig.GetRecord(fileName)
  local saveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(UE4.UBlueprintPathsLibrary.ProjectSavedDir())
  local contentDir = string.format("%s/%s", UE.UBlueprintPathsLibrary.ProjectContentDir(), "NewRoco/DataConfig")
  local filePath = string.format("%s/%s", contentDir, fileName)
  local savedFilePath = string.format("%s/%s", saveDir, fileName)
  if UE4.UBlueprintPathsLibrary.FileExists(savedFilePath) then
    filePath = savedFilePath
  end
  local data = RapidJson.uload(filePath)
  return data
end

return LoginConfig
