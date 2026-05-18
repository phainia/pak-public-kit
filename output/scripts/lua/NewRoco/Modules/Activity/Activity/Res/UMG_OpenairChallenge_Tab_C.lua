local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_OpenairChallenge_Tab_C = Base:Extend("UMG_OpenairChallenge_Tab_C")

function UMG_OpenairChallenge_Tab_C:OnConstruct()
end

function UMG_OpenairChallenge_Tab_C:OnDestruct()
end

function UMG_OpenairChallenge_Tab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.TextSelect:SetText(_data.tabName)
  self.UnselectedText:SetText(_data.tabName)
  self:PlayAnimation(self.normal)
end

function UMG_OpenairChallenge_Tab_C:OnItemSelected(_bSelected)
  self.Selected = _bSelected
  self:StopAllAnimations()
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_OpenairChallenge_Tab_C:OnItemSelected")
    self:PlayAnimation(self.change1)
    local data = self.data
    if data and data.clickCallback then
      data.clickCallback(data)
    end
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_OpenairChallenge_Tab_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    if self.Selected then
      self:PlayAnimation(self.select_loop, 0, 0)
    end
  elseif anim == self.change2 and not self.Selected then
    self:PlayAnimation(self.normal)
  end
end

return UMG_OpenairChallenge_Tab_C
