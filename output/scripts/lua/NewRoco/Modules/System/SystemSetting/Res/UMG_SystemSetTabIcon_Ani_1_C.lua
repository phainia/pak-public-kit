local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SystemSetTabIcon_Ani_1_C = Base:Extend("UMG_SystemSetTabIcon_Ani_1_C")
local SystemSettingModuleEvent = reload("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")

function UMG_SystemSetTabIcon_Ani_1_C:OnClick()
  _G.NRCModuleManager:GetModule("SystemSettingModule"):DispatchEvent(SystemSettingModuleEvent.ChangeTabType, self.TabType)
end

function UMG_SystemSetTabIcon_Ani_1_C:SetSelected(bSelected, skipAnm)
  self.bSelected = bSelected
  if self.preState == bSelected and self.preState == false then
    return
  end
  self:StopAllAnimations()
  self:CancelPlayLoopAnim()
  if not skipAnm then
    if self.preState == false and true == bSelected then
      self:PlayAnimation(self.change1)
    elseif self.preState == true and false == bSelected then
      self:PlayAnimation(self.change2)
    elseif bSelected then
      self:PlayAnimation(self.change1)
    else
      self:PlayAnimation(self.normal)
    end
  elseif bSelected then
    self:PlayAnimation(self.change1)
  else
    self:PlayAnimation(self.normal)
  end
  self.preState = bSelected
end

function UMG_SystemSetTabIcon_Ani_1_C:OnItemUpdate(_data, datalist, index)
  self.SelectLoopTimer = 3
  self.data = _data
  self.icon_1:SetPath(_data.Icon1Path)
  self.icon_2:SetPath(_data.Icon2Path)
  self.TabType = _data.TabType
  self.preState = nil
end

function UMG_SystemSetTabIcon_Ani_1_C:StartPlayLoopAnim()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:PlayAnimation(self.select_loop)
  self.loopFuncID = nil
end

function UMG_SystemSetTabIcon_Ani_1_C:CancelPlayLoopAnim()
  if self.loopFuncID then
    DelayManager:CancelDelayById(self.loopFuncID)
    self.loopFuncID = nil
  end
end

function UMG_SystemSetTabIcon_Ani_1_C:OnAnimationFinished(anim)
  if not self.bSelected then
    return
  end
  if anim == self.change1 then
    self:StartPlayLoopAnim()
  elseif anim == self.select_loop then
    self:CancelPlayLoopAnim()
    self.loopFuncID = DelayManager:DelaySeconds(self.SelectLoopTimer, self.StartPlayLoopAnim, self)
  end
end

function UMG_SystemSetTabIcon_Ani_1_C:OnDestruct()
  self:CancelPlayLoopAnim()
end

return UMG_SystemSetTabIcon_Ani_1_C
