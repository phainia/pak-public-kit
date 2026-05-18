local Super = require("NewRoco/Modules/System/TipsModule/Res/UMG_ExperienceAcquisition_C")
local UMG_CabinExperience_C = Super:Extend("UMG_CabinExperience_C")

function UMG_CabinExperience_C:SetExpUpInfo(expInfo)
  Super.SetExpUpInfo(self, expInfo)
  if expInfo.newLevel ~= expInfo.oldLevel then
    local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    localPlayer:PlayLevelUpEffect()
  end
  _G.NRCAudioManager:PlaySound2DAuto(1220002125, "UMG_CabinExperience_C:SetExpUpInfo")
end

function UMG_CabinExperience_C:GetExpText(expInfo)
  return string.format(string.format(LuaText.home_level_get_exp, expInfo.addExp))
end

return UMG_CabinExperience_C
