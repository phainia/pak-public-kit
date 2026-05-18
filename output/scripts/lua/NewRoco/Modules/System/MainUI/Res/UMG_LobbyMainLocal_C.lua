local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local UMG_LobbyMainLocal_C = _G.NRCPanelBase:Extend("UMG_LobbyMainLocal_C")

function UMG_LobbyMainLocal_C:OnConstruct()
  Log.Debug("UMG_LobbyMainLocal_C:OnConstruct")
  self:SetChildViews(self.UMG_PlayerAbilities)
end

function UMG_LobbyMainLocal_C:OnActive(...)
  local localMode = NRCModeManager:GetCurMode()
  local playerModule = localMode:GetModule("PlayerModule")
  self.UMG_PlayerAbilities.module = playerModule
  self.UMG_PlayerAbilities:OnActive()
end

function UMG_LobbyMainLocal_C:OnEnable()
end

function UMG_LobbyMainLocal_C:OnDisable()
end

function UMG_LobbyMainLocal_C:OnDestruct()
end

function UMG_LobbyMainLocal_C:OnDeactive(...)
end

return UMG_LobbyMainLocal_C
