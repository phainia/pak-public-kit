local BattlePiecesPlaySkill = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesPlaySkill")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePiecesPlaySkill
local BattlePiecesWorldLeaderSuccessPerform = Base:Extend("BattlePiecesWorldLeaderSuccessPerform")

function BattlePiecesWorldLeaderSuccessPerform:Play(action, finishCallBack)
  self.TriggerAction = action
  self.FinishCallBack = finishCallBack
  self.NpcId = nil
  self.FirstSkillObj = nil
  self.WaitNpcCreate = -1
  self.resList = BattleConst.WorldLeaderSuccessExit
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  _G.NRCEventCenter:RegisterEvent("BattlePiecesWorldLeaderSuccessPerform", self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
  Base.Play(self)
end

function BattlePiecesWorldLeaderSuccessPerform:IsActionRunning()
  if self.TriggerAction then
    if self.TriggerAction.finished or not self.TriggerAction.active then
      return false
    else
      return true
    end
  end
end

function BattlePiecesWorldLeaderSuccessPerform:OnResLoadFinish()
  if self:IsActionRunning() then
    self.Boss = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    self:CheckBossDieOver()
  end
end

function BattlePiecesWorldLeaderSuccessPerform:CheckBossDieOver()
  if self:IsActionRunning() then
    if not self.Boss or not self.Boss.IsPlayLeaderDie then
      self:PrepareFirst()
    else
      self:SafeDelaySeconds("d_CheckBossDieOver", 0.2, self.CheckBossDieOver, self)
    end
  end
end

function BattlePiecesWorldLeaderSuccessPerform:PrepareFirst()
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer or not localPlayer.viewObj then
    Log.Warning("There is no model in localPlayer !!!")
    self:Complete()
    return
  end
  local pos = localPlayer.viewObj:K2_GetActorLocation()
  local posNew = UE4.UNRCStatics.PinActorOnGround(nil, localPlayer.viewObj, pos, localPlayer.viewObj)
  if posNew.Z - pos.Z > 15 then
    localPlayer.viewObj:K2_SetActorLocation(posNew, false, nil, false)
  end
  if not self.Boss then
    Log.Warning("There is no Enemy Boss")
    self:Complete()
    return
  end
  local skillComponent = localPlayer.viewObj.RocoSkill
  if not skillComponent then
    Log.Warning("There is no skillComponent")
    self:Complete()
    return
  end
  local MyPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_TEAM) or {}
  _G.BattleManager.battlePawnManager:TogglePetBuffsVisibility(false)
  local MyCastObject = CastSkillObject.FromSkillResID(BattleConst.WorldLeaderSuccessExit[1])
  if MyCastObject then
    local characters = {}
    characters[BattleConst.CharacterIndex.Player1] = localPlayer.viewObj
    MyCastObject:SetInterrupt(true)
    MyCastObject:SetCallbackOwner(self)
    MyCastObject:SetCaster(self.Boss.model)
    MyCastObject:SetTargets({
      MyPet.model
    })
    MyCastObject:SetCharacters(characters)
    MyCastObject:SetCompleteCallback(self.OnFirstSkillFinish)
    MyCastObject:SetExtraEvents({
      ChangeCamera = self.ChangeCamera
    })
    self:PlaySkill(self.Boss, skillComponent, MyCastObject)
  else
    Log.Error("zgx res is vaild!!", BattleConst.WorldLeaderSuccessExit[2])
    self:OnFirstSkillFinish()
  end
end

function BattlePiecesWorldLeaderSuccessPerform:ChangeCamera()
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
  _G.BattleManager.battlePawnManager:HideAll()
end

function BattlePiecesWorldLeaderSuccessPerform:OnFirstSkillFinish(name, skill)
  local sceneModule = NRCModuleManager:GetModule("SceneModule")
  if sceneModule then
    local actNotifies = sceneModule:GetActionCacheQueueByName("battle_tag")
    if actNotifies then
      local battle_tag = ProtoMessage:newSpaceActionTag_Battle()
      battle_tag.battle_id = BattleManager.battleRuntimeData.battle_id
      for _, v in pairs(actNotifies) do
        if sceneModule:ProcessCachedBattleTag(v, battle_tag) then
          for _, act in ipairs(v.acts or {}) do
            if act.actor_enter then
              local npcInfos = act.actor_enter.actors or {}
              if #npcInfos > 0 then
                for _, npcInfo in ipairs(npcInfos) do
                  if npcInfo.npc and npcInfo.npc.npc_base then
                    local npcConfig = _G.DataConfigManager:GetNpcConf(npcInfo.npc.npc_base.npc_cfg_id)
                    if npcConfig and npcConfig.genre == Enum.ClientNpcType.CNT_CHEST then
                      self.NpcId = npcInfo.npc.base.actor_id
                    end
                  end
                end
              end
            end
          end
        end
      end
      if self.NpcId then
        if self:IsActionRunning() then
          if skill then
            skill:SetPlayRate(0)
            self.FirstSkillObj = skill
          end
          _G.NRCEventCenter:RegisterEvent("BattlePiecesWorldLeaderSuccessPerform", self, NPCModuleEvent.On_NPC_Create, self.OnNPCCreate)
        end
        NRCModuleManager:DoCmd(SceneModuleCmd.ConsumeCachedBattleTag, battle_tag)
        self.cachedBattleTag = battle_tag
        return
      end
    end
  end
  Log.Error("zgx \230\178\161\230\156\137\230\148\182\229\136\176\233\166\150\233\162\134\230\136\152\231\148\159\230\136\144\231\154\132\229\174\157\231\174\177\239\188\129\239\188\129 \228\184\173\230\150\173\232\161\168\230\188\148")
  self:Complete()
end

function BattlePiecesWorldLeaderSuccessPerform:OnNPCCreate(npc)
  if npc.serverData.base.actor_id == self.NpcId and self:IsActionRunning() then
    if not npc.viewObj then
      npc:AddEventListener(self, NPCModuleEvent.VIEW_LOADED, self.SceneNpcLoadOver)
    else
      self:SceneNpcLoadOver(npc.viewObj)
    end
  end
end

function BattlePiecesWorldLeaderSuccessPerform:SceneNpcLoadOver(npc)
  if npc and self:IsActionRunning() then
    npc.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.VIEW_LOADED, self.SceneNpcLoadOver)
    _G.NRCEventCenter:RegisterEvent("BattlePiecesWorldLeaderSuccessPerform", self, BattleEvent.BattleOver, self.OnBattleOver)
    self.BoxNpc = npc.sceneCharacter
    self.BoxNpc:SetVisibleForHiddenReason(false)
    self:Complete()
  end
end

function BattlePiecesWorldLeaderSuccessPerform:OnLeaveBattle()
  if self.BoxNpc then
    self.BoxNpc:SetVisibleForHiddenReason(false)
    if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
      local boxPosition = self.BoxNpc.serverData.base.pt.pos
      local boxLocation = UE4.FVector(boxPosition.x, boxPosition.y, boxPosition.z)
      local duration = 30.0
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), boxLocation, 50, 20, UE4.FLinearColor(0, 1, 0, 1), duration)
      local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player then
        local playerLocation = player:GetActorLocation()
        playerLocation.Z = playerLocation.Z + player:GetHalfHeight()
        UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), playerLocation, boxLocation, 10, UE.FLinearColor(0, 1, 0.3, 1), duration, 10)
      end
    end
  end
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
end

function BattlePiecesWorldLeaderSuccessPerform:OnBattleOver()
  if self:PrepareSecond(self.BoxNpc) ~= UE.ESkillStartResult.Success and self.BoxNpc then
    self.BoxNpc:SetVisibleForHiddenReason(true)
    self.BoxNpc = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.BattleOver, self.OnBattleOver)
end

function BattlePiecesWorldLeaderSuccessPerform:PrepareSecond(npc)
  if not npc then
    Log.Error("zgx There is no npc")
    return
  end
  if not self.SecondCache then
    Log.ErrorFormat("zgx Can't load skill class %s", BattleConst.WorldLeaderSuccessExit[2])
    return
  end
  local class = self.SecondCache.skillCla
  if not class then
    Log.ErrorFormat("zgx Can't load skill class %s", BattleConst.WorldLeaderSuccessExit[2])
    return
  end
  local skillComponent = npc.viewObj:GetComponentByClass(UE4.URocoSkillComponent)
  if not skillComponent then
    local Identity = UE4.FTransform()
    skillComponent = self:AddComponentByClass(UE4.URocoSkillComponent, false, Identity, false)
    npc.RocoSkill = skillComponent
  end
  if not skillComponent then
    Log.Error("zgx There is no skillComponent")
    return
  end
  SkillUtils.ClearSkillObj(skillComponent)
  local skill = skillComponent:AddSkillObjFromClassAndReturn(class)
  if not skill then
    Log.ErrorFormat("zgx Can't find or load skill object %s", class)
    return
  end
  skill:SetCaster(npc.viewObj)
  skill:SetTargets({
    npc.viewObj
  })
  skill:RegisterEventCallback("ActionStart", self, function()
    npc:SetVisibleForHiddenReason(true)
  end)
  skill:RegisterEventCallback("End", self, self.SecondEnd)
  skill:RegisterEventCallback("PreEnd", self, self.SecondEnd)
  skill:RegisterEventCallback("PreEndAnim", self, self.SecondEnd)
  if UE.UObject.IsValid(npc.viewObj) then
    local skeMesh = npc.viewObj:GetComponentByClass(UE.USkeletalMeshComponent)
    if skeMesh then
      skeMesh:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Camera, UE.ECollisionResponse.ECR_Ignore)
    end
    if npc.viewObj.BeforeBornPerform then
      npc.viewObj:BeforeBornPerform()
    end
  end
  return skillComponent:LoadAndPlaySkill(skill)
end

function BattlePiecesWorldLeaderSuccessPerform:SecondEnd(Name, Skill)
  if Skill then
    local viewObj = Skill:GetOwner()
    if viewObj and viewObj.AfterBornPerform then
      viewObj:AfterBornPerform()
    end
  end
  if self.SecondCache then
    if self.SecondCache.skillObj then
      self.SecondCache.skillObj:Release()
    end
    if self.SecondCache.skillCla then
      self.SecondCache.skillCla:Release()
    end
    self.SecondCache.callbackList = nil
  end
  self.SecondCache = nil
  if self.cachedBattleTag then
    NRCModuleManager:DoCmd(SceneModuleCmd.ConsumeCachedBattleTagForNpcGuideChange, self.cachedBattleTag)
    self.cachedBattleTag = nil
  end
end

function BattlePiecesWorldLeaderSuccessPerform:OnComplete()
  BattleEventCenter:UnBind(self)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Create, self.OnNPCCreate)
  if self.FirstSkillObj then
    self.FirstSkillObj:SetPlayRate(1)
  end
  if self:IsActionRunning() then
    self.TriggerAction:Finish()
    self.FinishCallBack(self.TriggerAction)
    if self.BoxNpc then
      self.SecondCache = BattleSkillManager:GetAndClearCache(BattleConst.WorldLeaderSuccessExit[2])
    end
  end
  self.TriggerAction = nil
  self.FinishCallBack = nil
  self.FirstSkillObj = nil
end

return BattlePiecesWorldLeaderSuccessPerform
