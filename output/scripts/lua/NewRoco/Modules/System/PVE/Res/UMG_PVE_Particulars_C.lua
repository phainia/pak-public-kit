local UMG_PVE_Particulars_C = _G.NRCPanelBase:Extend("UMG_PVE_Particulars_C")
local PVEModuleEnum = require("NewRoco.Modules.System.PVE.PVEModuleEnum")
local PVEModuleEvent = require("NewRoco.Modules.System.PVE.PVEModuleEvent")

function UMG_PVE_Particulars_C:OnConstruct()
  self:RegisterEvent(self, PVEModuleEvent.TalentNodeLockStatusChange, self.OnTalentNodeLockStatusChange)
  self:RegisterEvent(self, PVEModuleEvent.SwitchCurrentTalentNode, self.OnSwitchCurrentTalentNode)
end

function UMG_PVE_Particulars_C:OnDestruct()
end

function UMG_PVE_Particulars_C:OnActive(nodeData)
  self:OnSwitchCurrentTalentNode(nodeData)
end

function UMG_PVE_Particulars_C:OnSwitchCurrentTalentNode(nodeData)
  self.nodeData = nodeData
  local nodeConf = _G.DataConfigManager:GetSeasonGrowthConf(nodeData.id)
  self.SkillTitle:SetText(nodeConf.name)
  self.textBuffDesc:SetText(nodeConf.desc)
  self:OnTalentNodeLockStatusChange(nodeData)
end

function UMG_PVE_Particulars_C:OnTalentNodeLockStatusChange(nodeData)
  if not (self.nodeData and nodeData) or self.nodeData.id ~= nodeData.id then
    return
  end
  local nodeConf = _G.DataConfigManager:GetSeasonGrowthConf(nodeData.id)
  if nodeData.status == PVEModuleEnum.TalentNodeStatus.CanUnlock then
    self.Character:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BtnSwitcher:SetActiveWidgetIndex(0)
    local materialCnt = _G.NRCModeManager:DoCmd(_G.PVEModuleCmd.GetTalentMaterialCnt)
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(nodeConf.material)
    self.UnlockBtn:SetTitleTextAndIcon(bagItemConf and bagItemConf.icon, nodeConf.material_cost)
    if materialCnt >= nodeConf.material_cost then
      self.UnlockBtn:SetQuantityTextColor("F4EEE1FF")
    else
      self.UnlockBtn:SetQuantityTextColor("CF303EFF")
    end
  elseif nodeData.status == PVEModuleEnum.TalentNodeStatus.Unlocked then
    if nodeConf.type == Enum.SeasonGrowthType.SGT_PET then
      self.Character:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if nodeData.petGid and 0 ~= nodeData.petGid then
        self.BtnSwitcher:SetActiveWidgetIndex(3)
      else
        self.BtnSwitcher:SetActiveWidgetIndex(2)
      end
    else
      self.Character:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.BtnSwitcher:SetActiveWidgetIndex(1)
    end
  else
    self.Character:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BtnSwitcher:SetActiveWidgetIndex(4)
    self.NotUnlockedBtn:SetOnlyShowTipText(_G.LuaText.season_growth_unlock_tips)
  end
end

function UMG_PVE_Particulars_C:OnClickLightUpTalentNode()
  local nodeData = self.nodeData
  if not nodeData then
    return
  end
  if nodeData.status == PVEModuleEnum.TalentNodeStatus.CanUnlock then
    _G.NRCModuleManager:DoCmd(_G.PVEModuleCmd.LightUpTalentNode, nodeData.id)
  elseif nodeData.status == PVEModuleEnum.TalentNodeStatus.Unlocked then
    local nodeConf = _G.DataConfigManager:GetSeasonGrowthConf(nodeData.id)
    if nodeConf.type == Enum.SeasonGrowthType.SGT_PET then
    end
  end
end

function UMG_PVE_Particulars_C:OnPcClose()
  self:OnClose()
end

return UMG_PVE_Particulars_C
