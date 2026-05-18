local UMG_Skill_List_C = _G.NRCPanelBase:Extend("UMG_Skill_List_C")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")

function UMG_Skill_List_C:OnConstruct()
  self:SetChildViews(self.AbilitySlot_Q, self.AbilitySlot_W, self.AbilitySlot_E)
end

function UMG_Skill_List_C:OnDestruct()
end

function UMG_Skill_List_C:OnActive()
end

function UMG_Skill_List_C:OnDeactive()
end

function UMG_Skill_List_C:OnPetDataChange()
  self.AbilitySlot_Q:ShowPetSwitch(false)
  self.AbilitySlot_E:ShowPetSwitch(false)
  self.AbilitySlot_W:ShowPetSwitch(false)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local isOwnWolf = GlobalConfig.DebugOpenRideAbility or DataModelMgr.PlayerDataModel:IsOwnPetByPetBaseId(3011)
  if isOwnWolf then
    local rideAbility = localPlayer.abilityComponent:GetAbility(AbilityID.RIDE_ENTRY, true)
    self.AbilitySlot_Q:BindAbility(rideAbility)
  else
    self.AbilitySlot_Q:UnBindAbility()
  end
  local isOwnNiao = GlobalConfig.DebugOpenRideAbility or DataModelMgr.PlayerDataModel:IsOwnPetByPetBaseId(3028)
  if isOwnNiao then
    local glidingAbility = localPlayer.abilityComponent:GetAbility(AbilityID.GLIDING_ENTRY, true)
    self.AbilitySlot_W:BindAbility(glidingAbility)
  else
    self.AbilitySlot_W:UnBindAbility()
  end
  local isOwnDandelion = GlobalConfig.DebugOpenRideAbility or DataModelMgr.PlayerDataModel:IsOwnPetByPetBaseId(3027)
  if isOwnDandelion then
    local balloonAbility = localPlayer.abilityComponent:GetAbility(AbilityID.DANDELION_ENTRY, true)
    self.AbilitySlot_E:BindAbility(balloonAbility)
  else
    self.AbilitySlot_E:UnBindAbility()
  end
  if isOwnNiao or isOwnDandelion then
    localPlayer.abilityComponent:CastAbility(AbilityID.GLIDING_OFF_PASSIVE)
  else
    localPlayer.abilityComponent:StopAbility(true, AbilityID.GLIDING_OFF_PASSIVE)
  end
end

function UMG_Skill_List_C:InitForLocalMode()
  self.AbilitySlot_E:OnConstruct()
  self.AbilitySlot_Q:OnConstruct()
  self.AbilitySlot_W:OnConstruct()
end

return UMG_Skill_List_C
