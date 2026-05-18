local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local UMG_GiftReminder_C = _G.NRCPanelBase:Extend("UMG_GiftReminder_C")

function UMG_GiftReminder_C:OnActive(petGid, bondId)
  self:OnAddEventListener()
  self.petGid = petGid
  self.bondId = bondId
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid)
  if petData then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    if petBaseConf then
      self.Title:SetText(string.format(_G.LuaText.PetGiving_Mystrygift_Congratulations_text, petBaseConf.name))
    end
  end
  _G.NRCAudioManager:PlaySound2DAuto(1152, "UMG_GiftReminder_C:OnActive")
  self:PlayAnimation(self.In)
  self.panelLayer = nil
  if self.panelData and self.panelData.panelLayer == Enum.UILayerType.UI_LAYER_FULLSCREEN then
    _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_DisplayCoordinatorPaused)
    self.panelLayer = self.panelData.panelLayer
  end
end

function UMG_GiftReminder_C:OnDeactive()
  self:RemoveEventListener()
  if self.panelLayer and self.panelLayer == Enum.UILayerType.UI_LAYER_FULLSCREEN then
    _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_DisplayCoordinatorResumed)
  end
end

function UMG_GiftReminder_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_GiftReminder_C", self, AppearanceModuleEvent.OnUpgradeSuitLevelPanelClose, self.OnUpgradeSuitLevelPanelClose)
end

function UMG_GiftReminder_C:RemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, AppearanceModuleEvent.OnUpgradeSuitLevelPanelClose, self.OnUpgradeSuitLevelPanelClose)
end

function UMG_GiftReminder_C:OnUpgradeSuitLevelPanelClose()
  self:DoClose()
end

function UMG_GiftReminder_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    self:DelaySeconds(1, function()
      self:PlayAnimation(self.Out)
    end)
  elseif Anim == self.Out then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenFashionGetHeterochromeSuitPanel, self.bondId)
  end
end

return UMG_GiftReminder_C
