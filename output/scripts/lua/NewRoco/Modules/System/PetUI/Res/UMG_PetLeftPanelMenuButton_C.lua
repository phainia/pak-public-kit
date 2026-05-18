local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetLeftPanelMenuButton_C = _G.NRCViewBase:Extend("UMG_PetLeftPanelMenuButton_C")

function UMG_PetLeftPanelMenuButton_C:Initialize(Initializer)
end

function UMG_PetLeftPanelMenuButton_C:OnConstruct()
end

function UMG_PetLeftPanelMenuButton_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_PetLeftPanelMenuButton_C:OnDestruct()
  table.clear(self.data)
  self.data = nil
  self.activeIcon_1:ReleaseForce()
  self.normalIcon_1:ReleaseForce()
end

function UMG_PetLeftPanelMenuButton_C:OnEnable()
end

function UMG_PetLeftPanelMenuButton_C:OnDisable()
end

function UMG_PetLeftPanelMenuButton_C:SetData(_data)
  self.data = _data
  self:UpdateMenuInfo()
  self:SetSelectState(false)
  self.ClickBtn.OnClicked:Clear()
  self.ClickBtn.OnClicked:Add(self, self.OnClickBtn)
end

function UMG_PetLeftPanelMenuButton_C:SetImpressionPoint(petId)
  local friendInfo = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetFriendInfoToPetMain)
  if friendInfo and friendInfo.type ~= _G.ProtoEnum.PlayerRelationshipType.PRT_SELF then
    self.NrcRedPoint:SetupKey(0)
  else
    self.NrcRedPoint:SetupKey(150, {petId})
  end
end

function UMG_PetLeftPanelMenuButton_C:SetPoint(petId)
  local friendInfo = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetFriendInfoToPetMain)
  if friendInfo and friendInfo.type ~= _G.ProtoEnum.PlayerRelationshipType.PRT_SELF then
    self.NrcRedPoint:SetupKey(0)
  else
    self.NrcRedPoint:SetupKey(132, {petId})
  end
end

function UMG_PetLeftPanelMenuButton_C:SetPetEvoPoint(petId)
  local friendInfo = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetFriendInfoToPetMain)
  if friendInfo and friendInfo.type ~= _G.ProtoEnum.PlayerRelationshipType.PRT_SELF then
    self.NrcRedPoint:SetupKey(0)
  else
    self.NrcRedPoint:SetupKey(137, {petId})
  end
end

function UMG_PetLeftPanelMenuButton_C:SetBagEvoPoint(petId)
  local friendInfo = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetFriendInfoToPetMain)
  if friendInfo and friendInfo.type ~= _G.ProtoEnum.PlayerRelationshipType.PRT_SELF then
    self.NrcRedPoint:SetupKey(0)
  else
    self.NrcRedPoint2:SetupKey(183, {petId})
  end
end

function UMG_PetLeftPanelMenuButton_C:SetSelectState(_flag)
  if self.data.isDisable then
    return
  end
  self.selectFlag = _flag
  self:StopAllAnimations()
  if _flag then
    self:PlayAnimation(self.In)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.normalState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.IsHavePetSkillTips)
  else
    self:PlayAnimation(self.Out)
    self.normalState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetLeftPanelMenuButton_C:UpdateMenuInfo()
  local icon1 = self.data and self.data.icon1 or ""
  local icon2 = self.data and self.data.icon2 or ""
  local title = self.data and self.data.title or ""
  self.normalIcon_1:SetPath(icon1)
  self.activeIcon_1:SetPath(icon2)
end

function UMG_PetLeftPanelMenuButton_C:OnClickBtn()
  if self.data == nil then
    return
  end
  if self.data.isDisable then
    return
  end
  local data = self.data
  if data then
    if data.callbackCaller and data.callbackFunc then
      tcall(data.callbackCaller, data.callbackFunc, data.index or -1)
    end
    if data.soundId then
      _G.NRCAudioManager:PlaySound2DAuto(data.soundId, "UMG_PetLeftPanelMenuButton_C:OnTouchEnded")
    end
  end
  return
end

function UMG_PetLeftPanelMenuButton_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    Log.Trace("UMG_PetLeftPanelMenuButton_C:OnAnimationFinished")
    self:PlayAnimation(self.loop, 0, 9999)
  end
end

return UMG_PetLeftPanelMenuButton_C
