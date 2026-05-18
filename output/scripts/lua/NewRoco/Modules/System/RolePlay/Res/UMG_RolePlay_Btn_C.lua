local RolePlayModuleDef = require("NewRoco.Modules.System.RolePlay.RolePlayModuleDef")
local UMG_RolePlay_Btn_C = _G.NRCPanelBase:Extend("UMG_RolePlay_Btn_C")

function UMG_RolePlay_Btn_C:OnConstruct()
end

function UMG_RolePlay_Btn_C:OnDestruct()
end

function UMG_RolePlay_Btn_C:OnActive()
end

function UMG_RolePlay_Btn_C:OnDeactive()
end

function UMG_RolePlay_Btn_C:SetIcon(_normalIcon, _selectedIcon, _disableIcon)
  self.Ordinary:SetPath(_normalIcon)
  self.ps:SetPath(_selectedIcon)
  self.normalIcon = _normalIcon
  self.disableIcon = _disableIcon
end

function UMG_RolePlay_Btn_C:SetupRedPointKey(key, extraKey)
  self.RedDot:SetupKey(key, extraKey)
end

function UMG_RolePlay_Btn_C:SetSelected(_bSelected)
  self.bSelected = _bSelected
  local anim = self:GetAnimByIndex(_bSelected and 1 or 3)
  if anim then
    self:StopAllAnimations()
    self:PlayAnimation(anim)
  end
end

function UMG_RolePlay_Btn_C:SetBtnState(_btnState)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if _btnState == RolePlayModuleDef.RolePlayBtnState.Normal then
    self.Ordinary:SetPath(self.normalIcon)
    self:SetSelected(false)
  elseif _btnState == RolePlayModuleDef.RolePlayBtnState.Selected then
    self.Ordinary:SetPath(self.normalIcon)
    self:SetSelected(true)
  elseif _btnState == RolePlayModuleDef.RolePlayBtnState.Disabled then
    self.Ordinary:SetPath(self.disableIcon)
    self:SetSelected(false)
  elseif _btnState == RolePlayModuleDef.RolePlayBtnState.Hide then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.btnState = _btnState
end

function UMG_RolePlay_Btn_C:GetBtnState()
  return self.btnState
end

function UMG_RolePlay_Btn_C:OnAnimationFinished(anim)
  if self.bSelected then
    local animLoop = self:GetAnimByIndex(2)
    if animLoop then
      self:PlayAnimation(animLoop)
    end
  end
end

return UMG_RolePlay_Btn_C
