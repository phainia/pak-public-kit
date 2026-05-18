local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_EnterHome_HeadItem_C = Base:Extend("UMG_EnterHome_HeadItem_C")
local UIUtils = require("NewRoco.Utils.UIUtils")

function UMG_EnterHome_HeadItem_C:OnConstruct()
end

function UMG_EnterHome_HeadItem_C:OnDestruct()
end

function UMG_EnterHome_HeadItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  if _data then
    UIUtils.SetPlayerHeadIcon(self.HeadPortrait, _data.card_icon, true)
    self.Text_Sort:SetText(string.format("%sP", index))
    self.Text_Name:SetText(_data.name)
    self.NRCSwitcher_65:SetActiveWidgetIndex(1 == index and 1 or 0)
    self:RefreshPrepareState(1)
    self.HeadPortrait:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_Sort:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_65:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.PrepareState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.HeadPortrait:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Sort:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCSwitcher_65:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PrepareState:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_EnterHome_HeadItem_C:RefreshPrepareState(_reason)
  local newIndex
  if self.data then
    if self.data.status == ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_ACCEPT or self.data.status == ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_ENTERING then
      newIndex = 0
    elseif self.data.status == ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_DECLINED then
      newIndex = 1
    else
      newIndex = 2
    end
  end
  local curIndex = self.PrepareState:GetActiveWidgetIndex()
  if curIndex == newIndex then
    return
  end
  self:StopAllAnimations()
  if self.LastRefreshStateReason and 1 == _reason then
    self:PlayAnimation(self.Out_icon)
  else
    self.PrepareState:SetActiveWidgetIndex(newIndex)
    self:PlayAnimation(self.In_icon)
  end
  self.LastRefreshStateReason = _reason
end

function UMG_EnterHome_HeadItem_C:OnItemSelected(_bSelected)
end

function UMG_EnterHome_HeadItem_C:OnDeactive()
end

function UMG_EnterHome_HeadItem_C:OnAnimationFinished(Anim)
  if Anim == self.Out_icon then
    self:RefreshPrepareState(2)
  end
end

return UMG_EnterHome_HeadItem_C
