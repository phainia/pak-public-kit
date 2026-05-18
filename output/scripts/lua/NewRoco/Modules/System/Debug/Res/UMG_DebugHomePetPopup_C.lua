local UMG_DebugHomePetPopup_C = _G.NRCPanelBase:Extend("UMG_DebugHomePetPopup_C")

function UMG_DebugHomePetPopup_C:OnConstruct()
  self.npcModule = _G.NRCModuleManager:GetModule("NPCModule")
  self:OnAddEventListener()
end

function UMG_DebugHomePetPopup_C:OnDestruct()
end

function UMG_DebugHomePetPopup_C:OnActive(data)
  UE4Helper.SetDesiredShowCursor(true, "UMG_DebugHomePetPopup_C")
  self.uiData = data
  self:SetMainInfo()
end

function UMG_DebugHomePetPopup_C:OnDeactive()
  UE4Helper.SetDesiredShowCursor(false, "UMG_DebugHomePetPopup_C")
end

function UMG_DebugHomePetPopup_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
end

function UMG_DebugHomePetPopup_C:SetMainInfo()
  local bInFarmScene = _G.NRCModuleManager:DoCmd(_G.FarmModuleCmd.OnCmdGetIsInFarm)
  if bInFarmScene then
    local homePetInfos = {}
    local homeGuardPetInfo = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePlantGuardPetInfo)
    table.insert(homePetInfos, homeGuardPetInfo)
    self.ScrollBox:InitList(homePetInfos)
  else
    local homePetInfos = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePetInfo)
    self.ScrollBox:InitList(homePetInfos)
  end
end

function UMG_DebugHomePetPopup_C:OnCloseBtn()
  self:DoClose()
end

return UMG_DebugHomePetPopup_C
