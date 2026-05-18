local Enum = require("Data.Config.Enum")
local ProtoEnum = require("Data.PB.ProtoEnum")
local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local BattlePlayer = require("NewRoco.Modules.Core.Battle.Entity.BattlePlayer")
local BattleAttackPlayer = BattlePlayerBase:Extend()

function BattleAttackPlayer:Ctor()
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
  self.BreakFlow = false
  self.finish_cb = nil
  self.finish_cb_owner = nil
end

function BattleAttackPlayer:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.SKillEvent_AllHitEnd then
    self:ClearDefendShieldLoop()
    return true
  elseif eventName == BattleEvent.SKillEvent_BeCounterEnd then
    self:ClearDefendShieldActor()
    return true
  elseif eventName == BattleEvent.SKillEvent_StateEffectEnd then
    self:ClearDefendShieldEffect()
    return true
  elseif eventName == BattleEvent.DefenceOtherStart then
    local petGuid = (...)
    self:DefenceOtherStart(petGuid)
    return true
  elseif eventName == BattleEvent.DefenceOtherEnd then
    local petGuid, ChangePetPlayer = ...
    self:DefenceOtherEnd(petGuid, ChangePetPlayer)
    return true
  end
end

function BattleAttackPlayer:Reset()
  self.CompleteCallback = nil
  self.CompleteCallbackOwner = nil
  self.SkillConf = nil
  self.SkillObject = nil
  self.blackBoard = nil
  self.type = nil
  self.IsFinishSKill = false
  self.movingPlayerCount = 0
  self.consumedHits = 0
  self.consumedDamage = 0
  self.MultiDamageTimes = 0
  self.willWeakUpNumber = 0
  self.IsTriggerOnHit = false
  self.IsTriggerOnCounter = false
  self.IsTriggerOnInterrupt = false
  self.IsTriggerOnCounterEnd = false
  self.BulletTimeId = -1
  self.MultiAtkBulletTimeId = -1
  self.multiAttackEnd = false
  self.IsDelayHidePop = false
end

function BattleAttackPlayer:Play(performNode)
  self:Reset()
  self.performNode = performNode
  self.performInfo = performNode:GetInfo()
  self.totalHits = performNode:GetMultiAttackNumber()
  self.skill_cast = performNode:GetPerformData()
  self.SkillConf = _G.SkillUtils.GetSkillConf(self.skill_cast.skill_id)
  self.IgnoreCamera = false
  self.HideBattleMain = false
  self.IsPreparePlay = false
  self.StopBuffOver = false
  Log.Debug("BattleAttackPlayer:Play caster_id:", self.skill_cast.caster_id, self.skill_cast.skill_id, self, self.totalHits)
  if self:GetRuntimeData("is_finish") == true then
    self:OnFinish()
    return
  end
  if BattleManager.isPureLogicMode then
    self:OnFinish()
    return
  end
  if not self.SkillConf then
    Log.Debug("\230\136\152\230\150\151\230\138\128\232\131\189\233\133\141\231\189\174\231\188\186\229\164\177\239\188\140\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\239\188\129\239\188\129\239\188\129\239\188\129 \230\138\128\232\131\189id\228\184\186", self.skill_cast.skill_id)
    self:OnFinish()
    return
  end
  if self.SkillConf.type == Enum.SkillActiveType.SAT_CHARGE then
    Log.Debug("\232\147\132\229\138\155\230\138\128\232\131\189\231\172\172\228\184\128\233\152\182\230\174\181\239\188\140\232\183\179\232\191\135\232\161\168\230\188\148", self.skill_cast.skill_id)
    self:OnFinish()
    return
  end
  _G.BattleEventCenter:Bind(self, BattleEvent.SKillEvent_AllHitEnd, BattleEvent.SKillEvent_BeCounterEnd, BattleEvent.SKillEvent_StateEffectEnd, BattleEvent.DefenceOtherStart, BattleEvent.DefenceOtherEnd)
  if self.SkillConf.type == Enum.SkillActiveType.SAT_PLAYERSKILL then
    self.Caster = BattleManager.battlePawnManager:GetPlayerByGuid(self.skill_cast.caster_uin)
    if not self.Caster then
      Log.Error("\230\178\161\230\156\137\230\137\190\229\136\176Caster/CasterModel \229\183\178\231\187\143\232\183\179\232\191\135\232\161\168\230\188\148", self.skill_cast.caster_uin)
      self:OnFinish()
      return
    end
    self.Caster.attackPlayer = self
    self.CasterPlayer = self.Caster
    self.CastParam = self:PrepareSkill()
    self:OnPlayPlayerSkill()
  else
    self.Caster = _G.BattleManager.battlePawnManager:GetPetByGuid(self.skill_cast.caster_id)
    if not (self.Caster and self.Caster.model) or self.Caster:IsDead() then
      Log.Error("\230\178\161\230\156\137\230\137\190\229\136\176Caster/CasterModel \229\183\178\231\187\143\232\183\179\232\191\135\232\161\168\230\188\148", self.skill_cast.caster_id)
      self:OnFinish()
      return
    end
    self.CasterPlayer = self.Caster.player
    self.Caster.attackPlayer = self
    self.CastParam = self:PrepareSkill()
    self.Caster:SwimSetLockIdle(false)
    if self.CastParam and self.CastParam.TargetPets then
      local Targets = self.CastParam.TargetPets
      for _, v in pairs(Targets) do
        v:SwimSetLockIdle(false)
        v:SetIKEnable(false)
      end
    end
    if self.CastParam and self.CastParam.ResID:find("Jineng/200001") then
    elseif not self.Caster.card.petState:GetSleep() then
      self.Caster:SetIKEnable(false)
    end
    if BattleConst.MoveToLegalLocationWhenBlock then
      self:MoveToValidPos()
    else
      self:CheckCopeSkill()
    end
  end
end

function BattleAttackPlayer:NeedCancelGatherBefore()
  if not self.Caster.card.petState:GetGather() then
    return false
  end
  if SkillUtils.IsCollectEnergySkill(self.skill_cast.skill_id) then
    return true
  end
  local gatherSkill = self.Caster.card.petInfo.battle_inside_pet_info.charging_skill_id or 0
  if self.skill_cast.skill_id == gatherSkill then
    return true
  end
  gatherSkill = gatherSkill + 100
  if self.skill_cast.skill_id == gatherSkill then
    return true
  end
  return false
end

function BattleAttackPlayer:HandleBuffComplete()
  if self.StopBuffOver then
    return
  end
  self.StopBuffOver = true
  self:TryOnPlay()
end

function BattleAttackPlayer:PreparePlay()
  if self.IsPreparePlay then
    return
  end
  self.IsPreparePlay = true
  self:TryOnPlay()
end

function BattleAttackPlayer:TryOnPlay()
  if self.StopBuffOver and self.IsPreparePlay then
    self:OnPlay()
  end
end

function BattleAttackPlayer:StopBuffPerform()
  if self:NeedCancelGatherBefore() then
    self.Caster.buffComponent:RegisterCompleteCallBack(Enum.BuffGroupSign.BGS_GATHER, self, self.HandleBuffComplete)
    self.Caster.card.petState:CloseState(Enum.BuffGroupSign.BGS_GATHER)
    return
  end
  self:HandleBuffComplete()
end

function BattleAttackPlayer:CheckCopeSkill()
  self:StopBuffPerform()
  if self:IsCopeSkill() then
    if self.performNode.performPlayer.turnPlayer.IsMySelfPerform then
      BattleManager.vBattleField.battleCameraManager:ChangeToPlayerPetByCopeSkill(0, nil, function()
        self:EnterBulletTime()
      end)
    end
    BattlePiecesManager:Play("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePieceCounterSkillPrePlay", self.Caster, self.PreparePlay, self)
    self:ShowPopup()
  else
    self:EnterBulletTime()
    self:ShowPopup()
    self:PreparePlay()
  end
end

function BattleAttackPlayer:ShowPopup()
  local isPop = false
  if not self.Caster.card:CheckIsMimic() then
    local skillConf = _G.SkillUtils.GetSkillConf(self.skill_cast.skill_id)
    if nil ~= skillConf then
      if skillConf.type ~= Enum.SkillActiveType.SAT_FEATURE then
        isPop = true
      elseif skillConf.skill_feature == Enum.SkillFilterTitleType.SFTT_SPECIAL then
        isPop = true
      else
        isPop = false
      end
    else
      isPop = true
    end
  end
  if isPop then
    local type = BattleEnum.InfoPopupType.UseSkill
    if self:IsTriggerInterrupt() or self:IsTriggerCounter() then
      type = BattleEnum.InfoPopupType.UseSkillCountered
    end
    _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
      type,
      self.Caster.player,
      self
    }, self)
  else
    self.performNode:SyncEnergyForSkillPlayer(SkillUtils.InstSkillIdToCfgId(self.skill_cast.skill_id), self.performInfo.sync_data)
  end
end

function BattleAttackPlayer:DelayHidePopup()
  if not self.IsDelayHidePop then
    self.IsDelayHidePop = true
    self:SafeDelaySeconds("d_HidePopup", 1.2, self.HidePopup, self)
  end
end

function BattleAttackPlayer:HidePopup()
  self.IsDelayHidePop = true
  if self.CasterPlayer then
    _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, self.CasterPlayer, self)
  end
end

function BattleAttackPlayer:OnLastHit()
end

function BattleAttackPlayer:PrepareSkill()
