local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_BusinessCard_TabItem_C = Base:Extend("UMG_BusinessCard_TabItem_C")

function UMG_BusinessCard_TabItem_C:OnConstruct()
end

function UMG_BusinessCard_TabItem_C:OnDestruct()
  self:CancelDelayInfo()
end

function UMG_BusinessCard_TabItem_C:CancelDelayInfo()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
  end
end

function UMG_BusinessCard_TabItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.IsSelect = false
  self:SetInfo()
  self:SetRedInfo()
end

function UMG_BusinessCard_TabItem_C:SetRedInfo()
  if self.data.CardEntranceType == FriendEnum.CardEntrance.InformationEditorPanel then
    if self.data.Type == FriendEnum.InformationEditorType.ChangeLabelTab then
      self.RedDot:SetupKey(44)
    elseif self.data.Type == FriendEnum.InformationEditorType.ChangeHeadTab then
      self.RedDot:SetupKey(43)
    end
  elseif self.data.CardEntranceType == FriendEnum.CardEntrance.ImageEditorPanel then
    if self.data.Type == FriendEnum.ImageEditorType.Theme then
      self.RedDot:SetupKey(45)
    elseif self.data.Type == FriendEnum.ImageEditorType.Clothing then
    elseif self.data.Type == FriendEnum.ImageEditorType.PlayerAction then
      self.RedDot:SetupKey(46)
    end
  end
end

function UMG_BusinessCard_TabItem_C:SetInfo()
  self.Ordinary:SetPath(self.data.Icon)
  self.PitchOn:SetPath(self.data.Icon_1)
  self:PlayAnimation(self.normal)
  self:UpdateLock(true)
end

function UMG_BusinessCard_TabItem_C:UpdateLock(_bShow)
  if _bShow then
    self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_BusinessCard_TabItem_C:OnItemSelected(_bSelected)
  self.IsSelect = _bSelected
  if _bSelected then
    self:PlayAnimation(self.change1)
    _G.NRCModeManager:DoCmd(FriendModuleCmd.SelectInformationEditorIndex, self.data.Type)
  else
    self:CancelDelayInfo()
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

function UMG_BusinessCard_TabItem_C:OnAnimationFinished(Anim)
  if Anim == self.change1 then
    self:PlayAnimation(self.select_loop)
  elseif Anim == self.change2 then
    self:StopAnimation(self.select_loop)
  elseif Anim == self.select_loop and self.IsSelect then
    self.DelayId = _G.DelayManager:DelaySeconds(3, function()
      if self and UE4.UObject.IsValid(self) then
        self:PlayAnimation(self.select_loop)
      end
    end)
  end
end

function UMG_BusinessCard_TabItem_C:OnDeactive()
end

return UMG_BusinessCard_TabItem_C
