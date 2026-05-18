local UMG_Input_Blocker_C = _G.NRCPanelBase:Extend("UMG_Input_Blocker_C")

function UMG_Input_Blocker_C:OnConstruct()
  self:AddButtonListener(self.BlockButton, self.OnBlockButtonClick)
end

function UMG_Input_Blocker_C:OnDestruct()
  self:RemoveButtonListener(self.BlockButton)
end

function UMG_Input_Blocker_C:OnPcClose()
end

function UMG_Input_Blocker_C:OnActive()
  local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  if playerController then
    playerController:ClientSetCinematicMode(true, true, true, false)
  end
  self:OnAddDynamicIMC()
end

function UMG_Input_Blocker_C:OnEnable()
  Log.Debug("UMG_Input_Blocker_C OnEnable")
  self:OnActive()
  self:OnConstruct()
end

function UMG_Input_Blocker_C:OnDisable()
  Log.Debug("UMG_Input_Blocker_C OnDisable")
  self:OnDeactive()
  self:OnDestruct()
end

function UMG_Input_Blocker_C:OnDeactive()
  local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  if playerController then
    playerController:ClientSetCinematicMode(false, true, true, false)
  end
  self:OnRemoveDynamicIMC()
end

function UMG_Input_Blocker_C:OnBlockButtonClick()
  Log.Debug("Attention : Input Blocker is opened !!!")
  if self.module and self.module.InputBlockDic then
    local blockDic = self.module.InputBlockDic
    for key, _ in pairs(blockDic) do
      Log.Debug("Block Key Name: ", key)
    end
  end
end

return UMG_Input_Blocker_C
