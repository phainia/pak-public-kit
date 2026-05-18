local Base = require("NewRoco.Modules.System.MainUI.Res.compass.CompItemBase")
local UMG_CompItem_CatchPet_C = Base:Extend("UMG_CompItem_CatchPet_C")

function UMG_CompItem_CatchPet_C:PlayCatchPetEffect(event_info)
  local info = event_info
  local status = info.status
  self.CurCatchState = status
  self:SetIcon()
  if _G.ProtoEnum.SceneEventStatus.SES_SMALLER == status then
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif _G.ProtoEnum.SceneEventStatus.SES_BIGGER == status then
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:PlayAnimation(self.Light2)
    self:PlayAnimationIn()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1379, "CompItemBase:PlayCatchPetEffect")
    self:DelaySeconds(0.15, function()
      self:PlayAnimationLoop2()
    end)
    self:DelaySeconds(3.35, function()
      self:PlayAnimationOut()
    end)
  elseif _G.ProtoEnum.SceneEventStatus.SES_EQUAL == status then
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:PlayAnimation(self.Light3)
    self:PlayAnimationIn()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1380, "CompItemBase:PlayCatchPetEffect")
    self:DelaySeconds(0.15, function()
      self:PlayAnimationLoop3()
    end)
    self:DelaySeconds(3.35, function()
      self:PlayAnimationOut()
    end)
  elseif _G.ProtoEnum.SceneEventStatus.SES_BONUS == status then
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimationIn()
    self:PlayAnimation(self.Light4_in)
    self:StopAnimationLoops()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1381, "CompItemBase:PlayCatchPetEffect")
    self.IsWaitCahtAimEnd = true
    self.GapAim = 0
    self.IsFinshCatchAnimation = true
    self:DelaySeconds(5, function()
      self.IsWaitCahtAimEnd = false
    end)
  end
end

function UMG_CompItem_CatchPet_C:SetIcon()
  if self.uiData and self.uiData.WorldMapConfig then
    self:GetCathPetIconPath(self.uiData.WorldMapConfig.npcicon_unlock)
  end
end

function UMG_CompItem_CatchPet_C:GetCathPetIconPath(Icon)
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule then
    Base.SetIcon(self, NRCUtils:FormatConfIconPath(Icon, _G.UIIconPath.UIHeadIconPath))
  end
end

return UMG_CompItem_CatchPet_C
