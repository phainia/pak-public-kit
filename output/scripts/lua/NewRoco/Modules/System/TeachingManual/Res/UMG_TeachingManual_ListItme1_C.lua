local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TeachingManual_ListItme1_C = Base:Extend("UMG_TeachingManual_ListItme1_C")

function UMG_TeachingManual_ListItme1_C:OnConstruct()
end

function UMG_TeachingManual_ListItme1_C:OnDestruct()
  if self.DelayId then
    DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_TeachingManual_ListItme1_C:OnItemUpdate(_data, datalist, index)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.DelayId = _G.DelayManager:DelaySeconds(0.04 * index, function()
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    if self:IsAnimationPlaying(self.Unselect_1) then
      self:StopAnimation(self.Unselect_1)
    end
    self:PlayAnimation(self.In)
  end)
  self.data = _data
  self.index = index
  self:SetInfo()
end

function UMG_TeachingManual_ListItme1_C:SetInfo()
  local data = self.data.TeachList
  self.Title:SetText(data.list_des)
  self.Title_1:SetText(data.list_des)
  if self.data.Status == ProtoEnum.PlayerTeachInfo.TeachStatus.UNLOCK then
  else
  end
  self.NrcRedPoint:SetupKey(220, {
    self.data.TeachList.list_type,
    self.data.TeachList.id
  })
  self.NRCImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_TeachingManual_ListItme1_C:SelectChange(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self.NRCImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Select)
  else
    self:PlayAnimation(self.Unselect_1)
  end
end

function UMG_TeachingManual_ListItme1_C:SetReadState()
  self.data.Status = ProtoEnum.PlayerTeachInfo.TeachStatus.READED
end

function UMG_TeachingManual_ListItme1_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:SetOnNewStateRemove()
    self:SelectChange(_bSelected)
    _G.NRCModeManager:DoCmd(TeachingManualModuleCmd.SelectTeachIndex, self.data.TeachList, self.index)
  else
    self:SelectChange(_bSelected)
  end
end

function UMG_TeachingManual_ListItme1_C:SetOnNewStateRemove()
  if self.NrcRedPoint and self.NrcRedPoint:IsRed() then
    self.NrcRedPoint:EraseRedPoint()
  end
end

function UMG_TeachingManual_ListItme1_C:OnDeactive()
end

return UMG_TeachingManual_ListItme1_C
