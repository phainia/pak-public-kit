local Utils = {}

function Utils.GetQualityLevelLabel(GroupName, str, ...)
  local ImageQuality = UE4.UNRCQualityLibrary.GetImageQuality()
  local level = UE4.UNRCQualityLibrary.GetImageGroupQualityValue(ImageQuality, GroupName)
  local IsCurrent = false
  for _, in_level in pairs({
    ...
  }) do
    if level == in_level then
      IsCurrent = true
    end
  end
  if IsCurrent then
    return str .. "(\229\189\147\229\137\141)"
  else
    return str
  end
end

return Utils
