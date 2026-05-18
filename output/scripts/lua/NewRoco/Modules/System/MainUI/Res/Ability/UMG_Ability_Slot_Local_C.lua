local UMG_Ability_Slot_Local_C = _G.NRCClass:Extend("UMG_Ability_Slot_Local_C")

function UMG_Ability_Slot_Local_C:OnConstruct()
  self.Btn_Slot.OnPressed:Add(self, self.OnSlotPressed)
  self.Btn_Slot.OnReleased:Add(self, self.OnSlotReleased)
  self.Btn_Slot.OnClicked:Add(self, self.OnSlotClicked)
  self.Btn_Slot.OnNxLongPressed:Add(self, self.OnSlotLongPressed)
  Log.Debug("UMG_Ability_Slot_Local_C:OnConstruct")
end

function UMG_Ability_Slot_Local_C:OnDestruct()
end

function UMG_Ability_Slot_Local_C:BindStatus(status, subStatus)
  Log.Debug("UMG_Ability_Slot_Local_C:BindStatus")
  self.status = status
  self.subStatus = subStatus or 1
end

function UMG_Ability_Slot_Local_C:OnCast(isPress)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    if not localPlayer.statusComponent:HasStatus(self.status, self.subStatus) then
      localPlayer.statusComponent:ApplyStatus(self.status, nil, self.subStatus)
    else
      localPlayer.statusComponent:RemoveStatus(self.status, nil, self.subStatus)
    end
  end
end

function UMG_Ability_Slot_Local_C:OnSlotPressed(bind)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(self.SoundID, "UMG_Ability_Slot_C:OnSlotPressed")
  self:OnCast(true)
  Log.Debug("UMG_Ability_Slot_Local_C:OnSlotPressed")
  if self.press then
    self:PlayAnimation(self.press)
  end
end

function UMG_Ability_Slot_Local_C:OnSlotReleased(bind)
end

function UMG_Ability_Slot_Local_C:OnSlotClicked(bind)
end

function UMG_Ability_Slot_Local_C:OnSlotLongPressed()
end

return UMG_Ability_Slot_Local_C
