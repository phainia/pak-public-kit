local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AnnouncementListItem1_C = Base:Extend("UMG_AnnouncementListItem1_C")

function UMG_AnnouncementListItem1_C:OnConstruct()
end

function UMG_AnnouncementListItem1_C:OnDestruct()
end

function UMG_AnnouncementListItem1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Title_2:SetText(_data.Title)
  self.RedDot_1:ShowRedPoint(_data.bShowRedPoint)
  self:PlayAnimation(self.In)
end

function UMG_AnnouncementListItem1_C:OnItemSelected(_bSelected)
  if self.Selected == _bSelected then
    return
  end
  self.Selected = _bSelected
  if _bSelected then
    if self.data.bShowRedPoint then
      self.data.bShowRedPoint = false
      self.RedDot_1:ShowRedPoint(false)
    end
    if not self:IsAnimationPlaying(self.In) or not self:IsAnimationPlaying(self.Unselect_1) then
      self:PlayAnimation(self.Select)
    end
    _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.SetAnnouncementNotice, self.data)
  elseif not self:IsAnimationPlaying(self.Select) then
    self:PlayAnimation(self.Unselect_1)
  end
end

function UMG_AnnouncementListItem1_C:OnDeactive()
end

function UMG_AnnouncementListItem1_C:OnAnimationFinished(Anim)
  if Anim == self.Unselect_1 then
    if self.Selected then
      self:PlayAnimation(self.Select)
    end
  elseif Anim == self.Select and not self.Selected then
    self:PlayAnimation(self.Unselect_1)
  end
end

return UMG_AnnouncementListItem1_C
