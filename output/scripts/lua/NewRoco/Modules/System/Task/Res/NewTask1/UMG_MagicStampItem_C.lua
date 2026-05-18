local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local UMG_MagicStampItem_C = Base:Extend("UMG_MagicStampItem_C")

function UMG_MagicStampItem_C:OnConstruct()
end

function UMG_MagicStampItem_C:OnDestruct()
end

function UMG_MagicStampItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.OpenPanelType = nil
  self:SetInfo()
end

function UMG_MagicStampItem_C:SetInfo()
  self:SetInitializeInfo()
  self.SelectMagicStampIndex = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetSelectMagicStampIndex)
  if self.SelectMagicStampIndex == TaskEnum.MagicStampTabType.Lacquer then
    local data = self.data
    if data and data.task_token_id then
      local TaskTokenConf = _G.DataConfigManager:GetTaskTokenConf(data.task_token_id)
      self.Icon:SetPath(TaskTokenConf.token__source)
      self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NameText:SetText(TaskTokenConf.name)
      self.NumText:SetText(data.num)
      self:SetIsEnabled(true)
    elseif data and data.IsEmpty then
      self.bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetIsEnabled(false)
    else
      self:SetIsEnabled(false)
    end
  else
    local data = self.data
    if data and data.IsHas then
      self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Icon:SetPath(data.BagItem.icon)
      self.NameText:SetText(data.BagItem.name)
    elseif data and data.IsEmpty then
      self.bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetIsEnabled(false)
    else
      self:SetIsEnabled(false)
    end
  end
end

function UMG_MagicStampItem_C:SetOpenPanelType(_OpenPanelType)
  self.OpenPanelType = _OpenPanelType
end

function UMG_MagicStampItem_C:SetInitializeInfo()
  self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SelectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NumText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.bg:SetVisibility(UE4.ESlateVisibility.Visible)
  self:SetIsEnabled(true)
  self:PlayAnimation(self.Pick_out)
end

function UMG_MagicStampItem_C:SelectTokenInfo(_bSelected)
  if _bSelected then
    self.SelectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Pick_in)
  else
    self:PlayAnimation(self.Pick_out)
  end
end

function UMG_MagicStampItem_C:OnItemSelected(_bSelected)
  self:SelectTokenInfo(_bSelected)
  if _bSelected then
    if self.OpenPanelType == TaskEnum.OpenToKenType.operation then
      _G.NRCModeManager:DoCmd(TaskModuleCmd.SelectTokenInfo, self.data)
    else
      _G.NRCModuleManager:DoCmd(TaskModuleCmd.SelectBaDgeInfo, self.data)
    end
  end
end

function UMG_MagicStampItem_C:OnDeactive()
end

return UMG_MagicStampItem_C
