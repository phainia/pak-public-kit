local NPCActionAsyncBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionAsyncBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = NPCActionAsyncBase
local NPCActionUnlockDungeonEntry = Base:Extend("NPCActionUnlockDungeonEntry")

function NPCActionUnlockDungeonEntry:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
  self.playerLoc = nil
  self.playerRot = nil
end

local SkillResList = {}

function NPCActionUnlockDungeonEntry:GetPerformResourceList()
  local Gender = self:GetPlayer().gender
  if self:IsLocalAction() then
    if Gender == _G.ProtoEnum.ESexValue.SEX_MALE then
      SkillResList.Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Open_Door.G6_Open_Door_C"
    else
      SkillResList.Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Open_Door_PC2.G6_Open_Door_PC2_C"
    end
  elseif Gender == _G.ProtoEnum.ESexValue.SEX_MALE then
    SkillResList.Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Open_Door_Sync.G6_Open_Door_Sync_C"
  else
    SkillResList.Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Open_Door_Sync_PC2.G6_Open_Door_Sync_PC2_C"
  end
  return SkillResList
end

function NPCActionUnlockDungeonEntry:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  local Portal = self:GetOwnerNPCView()
  if Portal then
    Portal.opened = true
  end
  if self:IsLocalAction() then
    local curMode = _G.NRCModeManager:GetCurMode()
    if curMode then
      curMode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    end
    local Player = self:GetPlayer()
    if Player and Player.inputComponent then
      Player.inputComponent:SetInputEnable(self, false)
    end
    if Player and Player.viewObj then
      Player.viewObj.CharacterMovement:SetMovementMode(UE4.EMovementMode.Move_None)
    end
    _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, true, UE4.EPlayerForceHiddenType.Dialogue)
  end
end

function NPCActionUnlockDungeonEntry:OnPerformReady(LoadedAssets, Rsp)
  self.ServerAccept = true
  local Player = self:GetPlayer()
  if not Player then
    self:UnlockDungeonEntry()
    self:OnSkillComplete()
    return
  end
  local SkillComp = Player.viewObj.RocoSkill
  local Skill = SkillComp and SkillComp:FindOrAddSkillObj(LoadedAssets.Skill)
  if not Skill then
    self:LogWarning("\230\138\128\232\131\189\231\130\184\228\186\134")
    self:InitPlayer()
    self:UnlockDungeonEntry()
    self:OnSkillComplete()
    return
  end
  self:Record()
  self:UnLinkHand()
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    self:GetOwnerNPCView()
  })
  Skill:RegisterEventCallback("Interrupt", self, self.OnSkillComplete)
  Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  Skill:RegisterEventCallback("Unlock", self, self.UnlockDungeonEntry)
  Skill:RegisterEventCallback("PreUnlock", self, self.PreUnlockDungeonEntry)
  Skill:RegisterEventCallback("Init", self, self.InitPlayer)
  Skill:RegisterEventCallback("Recover", self, self.RecoverPlayer)
  Skill:RegisterEventCallback("ActivateFailed", self, self.OnSkillComplete)
  local Result = SkillComp:LoadAndPlaySkill(Skill)
  if Result ~= UE.ESkillStartResult.Success then
    self:LogWarning("\230\138\128\232\131\189\230\146\173\230\148\190\229\164\177\232\180\165")
    self:InitPlayer()
    self:UnlockDungeonEntry()
    self:OnSkillComplete()
  end
end

function NPCActionUnlockDungeonEntry:OnPerformFailed(Reason)
  if self:IsNotServerFailed(Reason) then
    self:UnlockDungeonEntry()
    self:OnSkillComplete()
  else
    self.ServerAccept = false
    self.SkipCommit = true
    self:OnSkillComplete()
    local Portal = self:GetOwnerNPCView()
    if Portal then
      Portal.opened = false
    end
  end
end

function NPCActionUnlockDungeonEntry:PreStart(Name, Skill)
  local Blackboard = Skill and Skill.Blackboard
  if not Blackboard or self:IsNotLocalHandPlayer() then
  else
    Blackboard:SetValueAsString("PlayerShow", "True")
  end
end

function NPCActionUnlockDungeonEntry:StartCallback(skillProxy, result)
  if result == UE4.ESkillStartResult.StartFailed then
    self:InitPlayer()
    self:UnlockDungeonEntry()
    self:OnSkillComplete()
  end
end

function NPCActionUnlockDungeonEntry:PreUnlockDungeonEntry()
  if self.GetOwnerNPCView then
    local OwnerNpcView = self:GetOwnerNPCView()
    if OwnerNpcView and UE4.UObject.IsValid(OwnerNpcView) then
      OwnerNpcView:PreOpen()
    end
  end
end

function NPCActionUnlockDungeonEntry:InitPlayer()
  local player = self:GetPlayer()
  if player then
    if not player.isLocal then
      return
    else
      local localPlayer = player
      if localPlayer.movementComponent then
        localPlayer.movementComponent:SetSyncMove(false)
      end
    end
  end
  local portal = self:GetOwnerNPCView()
  if player and UE4.UObject.IsValid(portal) and portal.PlayerStandPoint then
    local StandLocation = portal.PlayerStandPoint:Abs_K2_GetComponentLocation()
    local downPos = SceneUtils.GetPosInLand(StandLocation, player:GetHalfHeight(), 300, 1000, {}, {}, nil, true, true)
    player:SetActorLocation(downPos)
    player:FaceTo(self:GetOwnerNPC())
  else
    Log.Error("\228\184\186\228\187\128\228\185\136\228\188\154\230\178\161\230\156\137\231\142\169\229\174\182\230\136\150\232\128\133\228\188\160\233\128\129\233\151\168\229\145\162")
  end
end

function NPCActionUnlockDungeonEntry:UnlockDungeonEntry()
  local Portal = self:GetOwnerNPCView()
  if UE4.UObject.IsValid(Portal) then
    Portal:Opening()
  end
end

function NPCActionUnlockDungeonEntry:OnSkillComplete()
  self.playerLoc = nil
  self.playerRot = nil
  if self:IsLocalAction() then
    local player = self:GetPlayer()
    if player then
      if player.inputComponent then
        player.inputComponent:SetInputEnable(self, true)
      end
      if player.viewObj then
        player.viewObj.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Walking)
      end
    end
    local curMode = _G.NRCModeManager:GetCurMode()
    if curMode then
      curMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    end
    if self.ServerAccept then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Dungeon_Unlock)
    end
    _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, false, UE4.EPlayerForceHiddenType.Dialogue)
  end
  self:ReLinkHand()
  self:Finish()
  self.ServerAccept = false
  self.SkipCommit = false
end

function NPCActionUnlockDungeonEntry:RecoverPlayer()
  self:Recover()
  self:ReLinkHand()
  if self:IsLocalAction() then
    _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, false, UE4.EPlayerForceHiddenType.Dialogue)
  end
  local localPlayer = self:GetPlayer()
  if localPlayer and localPlayer.movementComponent then
    localPlayer.movementComponent:SetSyncMove(true)
  end
end

function NPCActionUnlockDungeonEntry:Recover()
  local player = self:GetPlayer()
  if not player then
    return
  end
  if self.playerLoc and self.playerRot then
    player:SetActorLocation(self.playerLoc)
    player:SetActorRotation(self.playerRot)
  end
  self.playerLoc = nil
  self.playerRot = nil
end

function NPCActionUnlockDungeonEntry:Record()
  local player = self:GetPlayer()
  if not player then
    return
  end
  self.playerLoc = player:GetActorLocation()
  self.playerRot = player:GetActorRotation()
end

function NPCActionUnlockDungeonEntry:IsNotLocalHandPlayer()
  local player = self:GetPlayer()
  if not player then
    return true
  end
  return not player.isLocal and player.statusComponent:HasAnyStatus(_G.ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND, _G.ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
end

return NPCActionUnlockDungeonEntry
