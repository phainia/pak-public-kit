local TakePhotosEnum = {}

function TakePhotosEnum.TPGlobalNum(Key, Default)
  local Val = _G.DataConfigManager:GetTakephotoGlobalConfig(Key, false)
  return Val and Val.num or Default or 0
end

function TakePhotosEnum.TPGlobalStr(Key, Default)
  local Val = _G.DataConfigManager:GetTakephotoGlobalConfig(Key, false)
  return Val and Val.str or Default or ""
end

function TakePhotosEnum.TPGlobalNumList(Key, Default)
  local Val = _G.DataConfigManager:GetTakephotoGlobalConfig(Key, false)
  return Val and Val.numList or Default or {}
end

return TakePhotosEnum
