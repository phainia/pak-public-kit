local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local LoopFXKey = "FXLoopLight"
local NPCActionLearnMagic = Base:Extend("NPCActionLearnMagic")

function NPCActionLearnMagic:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.bIsComingBack = self.Config.action_param2 == "1"
end

function NPCActionLearnMagic:OnNpcAction()
  if not Base.OnNpcAction(self) then
    return false
  end
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player.viewObj and Player.viewObj.CharacterMovement.MovementMode == UE4.EMovementMode.MOVE_Falling then
    Log.Debug("\231\142\169\229\174\182\229\164\132\228\186\142\230\142\137\232\144\189\231\138\182\230\128\129")
    return false
  end
  return true
end

function NPCActionLearnMagic:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  self.playerId = playerId
  self.needSendReq = needSendReq
  self:Lock()
  if self.bIsComingBack then
    self:LeaveLearnMagicLevel()
  else
    self:GoLearnMagicLevel()
  end
end

function NPCActionLearnMagic:Lock()
  local Player = self:GetPlayer()
  local NPC = self:GetOwnerNPC()
  Player.inputComponent:SetInputEnable(self, false)
  Player.inputComponent:SetCameraControlEnable(self, false)
  self:ToggleMovement(Player, false)
  Player.viewObj.CharacterMovement:ConsumeInputVector()
  Player.viewObj.CharacterMovement:ConsumeInputVector()
  self:ToggleMovement(NPC, false)
  _G.NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  return Player, NPC
end

function NPCActionLearnMagic:Unlock()
  local Player = self:GetPlayer()
  local NPC = self:GetOwnerNPC()
  Player.inputComponent:SetInputEnable(self, true)
  Player.inputComponent:SetCameraControlEnable(self, true)
  self:ToggleMovement(Player, true)
  self:ToggleMovement(NPC, true)
  _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  return Player, NPC
end

function NPCActionLearnMagic:GoLearnMagicLevel()
  local Player = self:GetPlayer()
  local NPC = self:GetOwnerNPC()
  local SkillComp = Player.viewObj.RocoSkill
  SkillComp:StopCurrentSkill()
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_Stele_Open_End", SkillComp, PriorityEnum.Active_Player_Action)
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    NPC.viewObj
  })
  Skill:RegisterEventCallback("Recycle", self, self.OnCloseWhiteScreen)
  Skill:RegisterEventCallback("End", self, self.OnEnterPrePerformEnd)
  Skill:PlaySkill(self, self.OnSkillCallBack)
  local Mesh = Player.viewObj.Mesh
  Mesh.BoundsScale = 999
end

function NPCActionLearnMagic:OnCloseWhiteScreen()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_WHITE_SCREEN)
end

function NPCActionLearnMagic:OnEnterPrePerformEnd(Name, Skill)
  local Blackboard = Skill and Skill.Blackboard
  if Blackboard then
    local LoopFX = Blackboard:GetValueAsObject(LoopFXKey)
    if LoopFX then
      Blackboard:RemoveObjectValue(LoopFXKey)
      local OwnerView = self:GetOwnerNPCView()
      if OwnerView then
        OwnerView.BeamFxComponent = LoopFX
      end
    end
  end
  local Player = self:GetPlayer()
  local Mesh = Player.viewObj.Mesh
  Mesh.BoundsScale = 1
  self:Unlock()
  self:Finish()
end

function NPCActionLearnMagic:LeaveLearnMagicLevel()
  local Player = self:GetPlayer()
  local NPC = self:GetOwnerNPC()
  local OwnerView = NPC.viewObj
  local SkillComp = Player.viewObj.RocoSkill
  SkillComp:StopCurrentSkill()
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_Stele_Leave_End", SkillComp, PriorityEnum.Active_Player_Action)
  local BeamFX = OwnerView and OwnerView.BeamFxComponent
  if BeamFX then
    OwnerView.BeamFxComponent = nil
    Skill.Blackboard:SetValueAsObject("Beam", BeamFX)
  end
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    NPC.viewObj
  })
  Skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  Skill:RegisterEventCallback("Recycle", self, self.OnCloseWhiteScreen)
  Skill:RegisterEventCallback("End", self, self.OnBackPrePerformEnd)
  Skill:PlaySkill(self, self.OnSkillCallBack)
  local Mesh = Player.viewObj.Mesh
  Mesh.BoundsScale = 999
end

function NPCActionLearnMagic:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  Skill.BattleGenderType = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex
end

function NPCActionLearnMagic:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionLearnMagic failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionLearnMagic:OnBackPrePerformEnd()
  local Player = self:GetPlayer()
  local Mesh = Player.viewObj.Mesh
  Mesh.BoundsScale = 1
  self:Unlock()
  self:Finish()
end

function NPCActionLearnMagic:ToggleMovement(Character, Enabled)
  if not Character then
    return
  end
  if not Character.viewObj then
    return
  end
  if Character.isLocal then
    Character:SetCharacterMovementTickEnable(self, Enabled)
  else
    local Movement = Character.viewObj.CharacterMovement
    if Movement then
      Movement:SetComponentTickEnabled(Enabled)
    end
  end
end

function NPCActionLearnMagic:Finish(success, data, param)
  Base.Finish(self, success, data, param)
end

return NPCActionLearnMagic
