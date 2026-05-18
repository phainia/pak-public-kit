local VideoEnum = require("Common/VideoEnum")
local MediaUtils = {}
MediaUtils.DIALOGUE_VIDEO_RESOLUTION = UE4.FVector2D(2560, 1440)
MediaUtils.COMMON_VIDEO_RESOLUTION = UE4.FVector2D(2580, 1080)

function MediaUtils.ExtractFileRelativePath(filePath)
  local projectContentDir = UE4.UBlueprintPathsLibrary.ProjectContentDir()
  Log.DebugFormat("projectContentDir %s", projectContentDir)
  if filePath:sub(1, #projectContentDir) == projectContentDir then
    local fileRelativePath = filePath:sub(#projectContentDir + 1, #filePath)
    return fileRelativePath
  end
  return filePath
end

function MediaUtils.GetExternalDirRoot()
  return UE4.UBlueprintPathsLibrary.ProjectSavedDir()
end

function MediaUtils.GetInternalDirRoot()
  return UE4.UBlueprintPathsLibrary.ProjectContentDir()
end

function MediaUtils.ComputeCoverFilePath(filePath)
  local fileRelativePath = MediaUtils.ExtractFileRelativePath(filePath)
  local fileRelativePathWithoutExtension = UE4.UNRCStatics.GetBaseFilename(fileRelativePath, false)
  local fileRelativePathAfterMovies = string.sub(fileRelativePathWithoutExtension, string.find(fileRelativePathWithoutExtension, "Movies") + string.len("Movies"))
  local fileName = UE4.UNRCStatics.GetBaseFilename(fileRelativePath, true)
  local coverFileRef = string.format("Texture2D'/Game/MovieCovers%s.%s'", fileRelativePathAfterMovies, fileName)
  local coverFilePath = string.format("%sMovieCovers%s.uasset", UE4.UBlueprintPathsLibrary.ProjectContentDir(), fileRelativePathAfterMovies)
  Log.Info("MediaUtils.ComputeCoverFilePath coverFilePath:", coverFilePath, " filePath ", filePath)
  return coverFileRef, coverFilePath
end

function MediaUtils.CheckCurrentDeviceShouldPlayHDVideo()
  return MediaUtils.ComputeVideoLevelByDeviceLevel() == VideoEnum.VideoLevel.HD
end

function MediaUtils.ComputeVideoLevelByDeviceLevel()
  local deviceLevel = UE4.UNRCQualityLibrary.GetDeviceLevel()
  if RocoEnv.PLATFORM == "PLATFORM_WINDOWS" then
    return VideoEnum.VideoLevel.HD
  elseif 4 == deviceLevel or 5 == deviceLevel or 6 == deviceLevel then
    return VideoEnum.VideoLevel.HD
  else
    return VideoEnum.VideoLevel.SD
  end
  return VideoEnum.VideoLevel.HD
end

function MediaUtils.ComputeFilePathByDeviceLevelAndPlatform(filePath)
  local fileRelativePath = MediaUtils.ExtractFileRelativePath(filePath)
  local fileRelativePathWithoutExtension = UE4.UNRCStatics.GetBaseFilename(fileRelativePath, false)
  local fileExtension = UE4.UNRCStatics.GetExtension(fileRelativePath, true)
  if not string.find(fileRelativePathWithoutExtension, "Movies") then
    return filePath
  end
  local fileRelativePathAfterMovies = string.sub(fileRelativePathWithoutExtension, string.find(fileRelativePathWithoutExtension, "Movies") + string.len("Movies"))
  local deviceMiddleDir = "HD"
  local possibleMiddleDirArr = {}
  local moviesDir = "Movies"
  if RocoEnv.IS_EDITOR then
    moviesDir = "MoviesPC"
  end
  local videoLevel = MediaUtils.ComputeVideoLevelByDeviceLevel()
  if videoLevel == VideoEnum.VideoLevel.HD then
    deviceMiddleDir = "HD"
    possibleMiddleDirArr = {"HD"}
  else
    deviceMiddleDir = "SD"
    possibleMiddleDirArr = {"SD"}
  end
  local baseDirRootArr = {
    MediaUtils.GetExternalDirRoot(),
    MediaUtils.GetInternalDirRoot()
  }
  for j = 1, table.len(possibleMiddleDirArr) do
    for i = 1, table.len(baseDirRootArr) do
      local tempFilePath = baseDirRootArr[i] .. moviesDir .. "/" .. possibleMiddleDirArr[j] .. fileRelativePathAfterMovies .. fileExtension
      Log.DebugFormat("MediaUtils Check filePath %s", tempFilePath)
      if UE4.UBlueprintPathsLibrary.FileExists(tempFilePath) then
        Log.DebugFormat("MediaUtils filePath %s Exists", tempFilePath)
        return tempFilePath
      end
    end
  end
  for i = 1, table.len(baseDirRootArr) do
    local tempFilePath = baseDirRootArr[i] .. moviesDir .. fileRelativePathAfterMovies .. fileExtension
    Log.DebugFormat("MediaUtils Check filePath %s", tempFilePath)
    if UE4.UBlueprintPathsLibrary.FileExists(tempFilePath) then
      Log.DebugFormat("MediaUtils filePath %s Exists", tempFilePath)
      return tempFilePath
    end
  end
  if RocoEnv.IS_EDITOR then
    for i = 1, table.len(baseDirRootArr) do
      local tempFilePath = baseDirRootArr[i] .. "Movies" .. fileRelativePathAfterMovies .. fileExtension
      Log.DebugFormat("MediaUtils Check filePath %s", tempFilePath)
      if UE4.UBlueprintPathsLibrary.FileExists(tempFilePath) then
        Log.DebugFormat("MediaUtils filePath %s Exists", tempFilePath)
        return tempFilePath
      end
    end
  end
  return filePath
end

return MediaUtils
