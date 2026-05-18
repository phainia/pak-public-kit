local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MarkingBoxiItem_C = Base:Extend("UMG_MarkingBoxiItem_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_MarkingBoxiItem_C:OnConstruct()
end

function UMG_MarkingBoxiItem_C:OnDestruct()
end

function UMG_MarkingBoxiItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data and self.data.conf then
    self.mark_type = self.data.conf.mark_type
    self.Lock:SetVisibility(self.data.isUnlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
    self.Icon:SetPath(self.data.isUnlock and self.data.conf.mark_icon or self.data.conf.locked_mark_icon)
    if self.data.conf.mark_name then
      if self.data.isUnlock then
        self.SortText:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.MarkText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.MarkText:SetText(self.data.conf.mark_name)
      else
        self.MarkText:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.SortText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.SortText:SetText(self.data.conf.mark_name)
      end
    end
  end
end

function UMG_MarkingBoxiItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MarkingBoxiItem_C:OnItemSelected")
    if self.data then
      NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnSwitchPetBoxMark, self.mark_type, self.data.isUnlock)
      if not self.data.isUnlock then
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self:GetMarkUnlockRuleDesc())
      end
    end
  else
    self:PlayAnimationReverse(self.Select_In)
  end
  self.selected = _bSelected
end

function UMG_MarkingBoxiItem_C:GetMarkUnlockRuleDesc()
  for _, conf in pairs(self.data.allConf or {}) do
    if conf and conf.mark_type == self.mark_type and conf.mark_unlock_text and conf.mark_unlock_amount then
      local str = string.format(conf.mark_unlock_text, conf.mark_unlock_amount)
      return str
    end
  end
  return nil
end

function UMG_MarkingBoxiItem_C:OnDeactive()
end

return UMG_MarkingBoxiItem_C
