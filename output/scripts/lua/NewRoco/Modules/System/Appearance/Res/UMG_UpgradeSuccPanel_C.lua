local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local UMG_UpgradeSuccPanel_C = _G.NRCPanelBase:Extend("UMG_UpgradeSuccPanel_C")

function UMG_UpgradeSuccPanel_C:OnConstruct()
  self.data = self.module:GetData("AppearanceModuleData")
end

function UMG_UpgradeSuccPanel_C:OnActive(itemInfo)
  self:PlayAnimation(self.In)
  self:OnAddEventListener()
  self.uiData = itemInfo
  self:UpdatePanelInfo()
end

function UMG_UpgradeSuccPanel_C:OnDeactive()
end

function UMG_UpgradeSuccPanel_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose, self.OnCloseBtnClicked)
end

function UMG_UpgradeSuccPanel_C:OnRemoveEventListener()
end

function UMG_UpgradeSuccPanel_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_UpgradeSuccPanel_C:OnCloseBtnClicked()
  if self:IsPlayingAnimation() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40010018, "UMG_UpgradeSuccPanel_C:OnCloseBtnClicked")
  self:PlayAnimation(self.Out)
  self.btnClose:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_UpgradeSuccPanel_C:UpdatePanelInfo()
  if self.uiData then
    _G.NRCAudioManager:PlaySound2DAuto(40010016, "UMG_UpgradeSuccPanel_C:UpdatePanelInfo")
    local unlockCompNum = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetSuitUnlockComponentsNum, self.uiData.suitId)
    local totalCompNum = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetSuitComponentsTotalNum, self.uiData.suitId)
    local str = string.format("%d/%d", unlockCompNum, totalCompNum)
    self.TitleText:SetText(str)
    self.HorizontalBox_91:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Lock_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Closet1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Closet2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local initList = {}
    for _, item in pairs(self.uiData.itemList or {}) do
      local tmp = {
        index = item + 1,
        suitId = self.uiData.suitId
      }
      table.insert(initList, tmp)
    end
    self.List:InitGridView(initList)
  end
end

function UMG_UpgradeSuccPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:StopAllAnimations()
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnAppearanceUpgradeSuccPanelClose)
    self:DoClose()
  end
end

return UMG_UpgradeSuccPanel_C
