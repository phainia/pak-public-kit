local HomeLightService = Class("HomeLightService")

function HomeLightService:Ctor()
end

function HomeLightService:OnExitHome()
end

function HomeLightService:ApplyRoomLightSettingsByDecoration(RoomId, Volumes, Lights)
  local WorldRoom = HomeIndoorSandbox.World:GetRoomById(RoomId)
  local RoomData = WorldRoom:GetRoomData()
  local DecoDataList = RoomData:GetDecoDataList()
  local StyleId = 0
  for j = #DecoDataList, 1, -1 do
    local DecoData = DecoDataList[j]
    if DecoData:GetConfigMainType() ~= Enum.InteriorFinishType.IFT_FLOOR then
      StyleId = HomeIndoorSandbox.Utils.GetSceneStyleIdByConfId(DecoData.ConfId)
      break
    end
  end
  local EnvSystemSetting, EnvSystemSettingLow = HomeIndoorSandbox.World:GetStyleEnvSystemSettingByStyleId(StyleId, RoomId)
  for i, v in pairs(Volumes) do
    v:ApplySystemSetting(EnvSystemSetting, EnvSystemSettingLow)
  end
  local RoomLightParam = HomeIndoorSandbox.World:GetStyleEnvLightSettingByStyleId(StyleId, RoomId, false)
  for i, v in pairs(Lights) do
    if not v:IsThemeLight() then
      v:ApplyLightSetting(RoomLightParam)
    else
      local ThemeLightId = v:GetThemeLightUniqueVisualRoomId()
      local ThemeLightParam = HomeIndoorSandbox.World:GetStyleEnvLightSettingByStyleId(StyleId, ThemeLightId, true)
      if ThemeLightParam then
        v:ApplyLightSetting(ThemeLightParam)
        v:SetThemeActivated(true)
      else
        v:SetThemeActivated(false)
      end
    end
  end
end

function HomeLightService:ApplyRoomLightSettingsByConfig(RoomId, ConfId)
  HomeIndoorSandbox.World:ApplyRoomLightSettings(RoomId)
end

return HomeLightService
