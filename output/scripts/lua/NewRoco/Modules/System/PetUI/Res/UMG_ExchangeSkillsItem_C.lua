local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ExchangeSkillsItem_C = Base:Extend("UMG_ExchangeSkillsItem_C")

function UMG_ExchangeSkillsItem_C:OnConstruct()
  self:AddButtonListener(self.ClickBtn, self.OnTipsbtnClick)
  self.ClickBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ExchangeSkillsItem_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_ExchangeSkillsItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:StopAllAnimations()
  self:PlayAnimation(self.Normal)
  if not _data then
    Log.Error("UMG_ExchangeSkillsItem_C:OnItemUpdate _data is nil")
    return
  end
  local skillConf = _G.DataConfigManager:GetSkillConf(_data.id)
  self.skillConfig = skillConf
  if skillConf then
    self.NRCText_47:SetText(skillConf.name)
    self.SkillIcon:SetPath(skillConf.icon)
  end
  if _data.is_equipped then
    self.Number:SetText(_data.pos)
    self.OrderBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.OrderBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.data.notSelect then
    self.ClickBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCImage_35:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ClickBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_35:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_ExchangeSkillsItem_C:OnItemSelected(_bSelected)
  self.bSelected = _bSelected
  self:StopAllAnimations()
  if self.data.notSelect then
    return
  end
  if _bSelected then
    self:PlayAnimation(self.Select_Anim)
    self.ClickBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.data then
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnSelectSkillOperationItem, self.data.id)
    end
  else
    self.ClickBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_ExchangeSkillsItem_C:OnTipsbtnClick()
  if self.data then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBagSKillTips, self.data.id)
  end
end

function UMG_ExchangeSkillsItem_C:OnDeactive()
end

function UMG_ExchangeSkillsItem_C:OnAnimationFinished(Anim)
  if Anim == self.Select and self.bSelected then
    self:PlayAnimation(self.Select_Normal)
  end
end

return UMG_ExchangeSkillsItem_C
