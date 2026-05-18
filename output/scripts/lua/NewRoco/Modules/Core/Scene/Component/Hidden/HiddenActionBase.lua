local Class = _G.MakeSimpleClass
local HiddenActionBase = Class("HiddenActionBase")

function HiddenActionBase:Init(comp)
  self.comp = comp
  self.owner = comp.owner
end

function HiddenActionBase:Release()
  self.comp = nil
  self.owner = nil
end

function HiddenActionBase:OnHidden()
  error("HiddenActionBase:OnHidden unimplemented")
end

function HiddenActionBase:AssureHidden(imme)
  error("HiddenActionBase:AssureHidden unimplemented")
end

function HiddenActionBase:OnUnhidden()
  error("HiddenActionBase:OnUnhidden unimplemented")
end

function HiddenActionBase:AssureUnhidden(imme, remove)
  error("HiddenActionBase:AssureUnhidden unimplemented")
end

function HiddenActionBase:EnablePinToGround()
  return true
end

function HiddenActionBase:OnInitialHide()
end

function HiddenActionBase:SetVisible(subItemVisibility, ownerVisibility)
end

function HiddenActionBase:OnVisibilityChange(visible)
end

function HiddenActionBase:EnterBattle()
end

function HiddenActionBase:LeaveBattle()
end

return HiddenActionBase
