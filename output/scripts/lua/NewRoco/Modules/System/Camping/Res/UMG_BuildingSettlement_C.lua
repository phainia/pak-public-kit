local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UMG_BuildingSettlement_C = _G.NRCPanelBase:Extend("UMG_BuildingSettlement_C")

function UMG_BuildingSettlement_C:OnConstruct()
  self.IsGuideBook = nil
  self:OnAddEventListener()
end

function UMG_BuildingSettlement_C:OnDestruct()
end

function UMG_BuildingSettlement_C:OnActive(itemInfos, IsGuideBook)
  self.IsGuideBook = IsGuideBook
  if IsGuideBook then
    self:PlayAnimation(self.Map_Open)
    self.NRCTitle_1:SetText(LuaText.umg_buildingsettlement_1)
  else
    self:PlayAnimation(self.open)
    self.NRCTitle_1:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_TITLE_Exchange_huode").msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  end
  if IsGuideBook then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1066, "UMG_BuildingSettlement_C:OnActive")
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1231, "UMG_BuildingSettlement_C:OnActive")
  end
  self.List:InitGridView(itemInfos)
  self.UMG_Common_BIconPar:PlayAnimation(self.UMG_Common_BIconPar.open)
end

function UMG_BuildingSettlement_C:OnDeactive()
end

function UMG_BuildingSettlement_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRewardPanel, self.OnBtnCloseRewardPanelClick)
end

function UMG_BuildingSettlement_C:OnBtnCloseRewardPanelClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1070, "UMG_BuildingSettlement_C:OnBtnCloseRewardPanelClick")
  if self:IsAnimationPlaying(self.close) or self:IsAnimationPlaying(self.Map_Close) then
    return
  end
  if self.IsGuideBook then
    self:PlayAnimation(self.Map_Close)
  else
    self:PlayAnimation(self.close)
  end
end

function UMG_BuildingSettlement_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    self:DoClose()
  elseif Animation == self.open then
    self:PlayAnimation(self.loop)
  elseif Animation == self.Map_Open then
    self.ParticleSystemWidget2_82:SetActivate(false)
    self.ParticleSystemWidget2:SetActivate(false)
  elseif Animation == self.Map_Close then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.CloseGuideBook)
    self:DoClose()
  end
end

return UMG_BuildingSettlement_C
