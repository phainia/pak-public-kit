local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattlePlaySeqBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlaySeqBaseAction")
local BattleB1P1EnterSequenceAction = BattlePlaySeqBaseAction:Extend("BattleB1P1EnterSequenceAction")
FsmUtils.MergeMembers(BattlePlaySeqBaseAction, BattleB1P1EnterSequenceAction, {})

function BattleB1P1EnterSequenceAction:DoEnter()
  if _G.BattleManager.debugEnv.closeB1FBP1Seq then
    self:Finish()
    return
  end
  BattlePlaySeqBaseAction.DoEnter(self)
end

function BattleB1P1EnterSequenceAction:OnEnter()
  self:Play(BattleConst.B1P1EnterSequence, function(levelSequenceActor)
    if not levelSequenceActor then
      self:Finish()
      return
    end
    self:SetBpUsePlayer(levelSequenceActor)
    Log.Debug("BattleB1P1EnterSequenceAction:OnEnter")
    _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_BLACK_SCREEN)
    _G.NRCModuleManager:DoCmd(CinematicModuleCmd.CloseBlackScreen)
  end, true)
end

function BattleB1P1EnterSequenceAction:SetBpUsePlayer(levelSequenceActor)
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    player:SetVisible(true)
    NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
    player:SetCharacterMovementTickEnable(self, false, "BattleB1P1EnterSequenceAction")
    local MeshBasedPlayerBinding = levelSequenceActor:FindNamedBindings("NewBP")
    if MeshBasedPlayerBinding:Length() > 0 then
      self.CachedPlayerMeshTrans = player.viewObj.Mesh:GetRelativeTransform()
      player.viewObj.Mesh:ResetRelativeTransform()
    end
    levelSequenceActor:ApplyWorldOffsetToSequence()
    levelSequenceActor:SetBindingByTag("Player1", {
      player.viewObj
    }, false)
    levelSequenceActor:SetBindingByTag("Player2", {
      player.viewObj
    }, false)
  end
end

function BattleB1P1EnterSequenceAction:RemoveLevelSequence()
  if self.levelSequence then
    _G.BattleManager.battleRuntimeData:CacheB1P1LevelSequence(self.levelSequence)
    local battleFieldActor = self.currentBattleFieldActor
    if UE.UObject.IsValid(battleFieldActor) then
      self.levelSequence.OnFinished:Remove(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
    end
    local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      if self.CachedPlayerMeshTrans then
        player.viewObj.Mesh:K2_SetRelativeTransform(self.CachedPlayerMeshTrans, false, nil, true)
        self.CachedPlayerMeshTrans = nil
      end
      player:SetCharacterMovementTickEnable(self, true, "BattleB1P1EnterSequenceAction")
      NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, true)
    end
    self.levelSequence = nil
    self.levelSequenceActor = nil
  end
end

return BattleB1P1EnterSequenceAction
