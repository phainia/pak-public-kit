local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local Stat = require("NewRoco.Modules.Core.Scene.Component.Stat.Stat")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ScenePlayerPerceptionBuff = Base:Extend("ScenePlayerPerceptionBuff")
ScenePlayerPerceptionBuff.StatEnum = {
  Prepare = 1,
  WaittingSkill = 2,
  Short = 3,
  ShortResident = 4,
  Long = 5,
  LongResident = 6,
  Finishing = 7
}

function ScenePlayerPerceptionBuff:Ctor(owner, ...)
  Base.Ctor(self, owner)
end

function ScenePlayerPerceptionBuff:OnBegin(param)
  self._stat = self.StatEnum.Prepare
  local abilityHelper = AbilityHelperManager.GetHelper(AbilityID.PERCEPTION)
  self.owner:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_GANZHI, 7)
  self._movement_conf = DataConfigManager:GetRideBasicMovement(7)
  self._PreCmdList = {}
  self._lastRide = false
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, self.OnAttacked)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_LUOPAN_STATE_CHANGED, self.OnLuopanStateChanged)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_VITALITY_OVER, self.OnVitalityOver)
  _G.NRCEventCenter:RegisterEvent("ScenePlayerPerceptionBuff", self, SceneEvent.LoadMapStart, self.LoadMapStart)
  _G.NRCEventCenter:RegisterEvent("ScenePlayerPerceptionBuff", self, DialogueModuleEvent.DialogueStarted, self.OnDialogueStarted)
  _G.NRCPanelManager.layerCenter:AddEventListener(self, UILayerEvent.FULLSCREEN_LAYER_OPENWINDOW, self.OnFullScreenOpened)
  Log.Warning("\230\132\159\231\159\165buff\229\138\160\232\189\189\239\188\140\232\191\155\229\133\165\229\135\134\229\164\135\233\152\182\230\174\181")
end

function ScenePlayerPerceptionBuff:Start()
  if self._stat == self.StatEnum.Prepare and self._pet then
    self._stat = self.StatEnum.WaittingSkill
    Log.Warning("\233\135\138\230\148\190\230\132\159\231\159\165\230\138\128\232\131\189")
    if self.owner.isLocal then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41500307, "ScenePlayerPerceptionBuff:Start")
    end
    if self:IsRidePet(self._pet) then
      self._lastRide = true
      self.owner.PetSensingActivelyComponent:PlayPerceptionSkill(self._pet, self, self.OnPlaySkill)
    else
      self._lastRide = false
      self.owner.PetSensingComponent:PlayPerceptionSkill(self._pet, self, self.OnPlaySkill)
    end
    _G.NRCAudioManager:SetStateByName("ListenMode", "Open", "ScenePlayerPerceptionBuff")
  else
    Log.Error("\230\151\160\230\179\149\232\191\155\229\133\165\231\159\173\230\140\137\231\154\132\230\132\159\231\159\165\231\138\182\230\128\129")
    self:OnSkillEnd()
  end
end

function ScenePlayerPerceptionBuff:OnPlaySkill(Success)
  if self._stat == self.StatEnum.WaittingSkill and Success then
    self._stat = self.StatEnum.Short
    Log.Warning("\230\132\159\231\159\165buff\239\188\140\232\191\155\229\133\165\231\159\173\230\140\137\229\137\141\230\145\135")
    if not self:IsRidePet(self._pet) then
      self._pet:SetStatus(ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_SCENE)
    end
    self._pet:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
    if self:IsRidePet(self._pet) then
      self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, AbilityID.RIDE_ALL_MAIN)
    else
      self.owner.abilityComponent:SendEvent(AbilityEvent.ON_PERCEPTION_BEGIN)
    end
    Log.Dump(self._PreCmdList, 5, "PlayerPerceptionBuffPreCmdList")
    while #self._PreCmdList > 0 do
      local value = self._PreCmdList[1]
      if value == self.StatEnum.ShortResident then
        self:OnCmdEntryShortResident()
      elseif value == self.StatEnum.Long then
        self:OnCmdEntryLong()
      elseif value == self.StatEnum.LongResident then
        self:OnCmdEntryLongResident()
      else
        Log.Warning("\230\156\170\231\159\165\231\154\132\230\132\159\231\159\165\231\188\147\229\173\152\230\140\135\228\187\164")
      end
      table.remove(self._PreCmdList, 1)
    end
  else
    Log.Warning("\230\138\128\232\131\189\233\135\138\230\148\190\229\164\177\232\180\165")
    self:OnCmdFinish()
    local statusComponent = self.owner.statusComponent
    statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_GANZHI, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1)
  end
end

function ScenePlayerPerceptionBuff:OnCmdInitPetInfo(pet)
  self._pet = pet
  self:ApplyPerceptionTalent()
  self:Start()
end

function ScenePlayerPerceptionBuff:ApplyPerceptionTalent()
  if self._pet then
    local Talents = self._pet:GetAllEffectTalent()
    if Talents then
      self._StatObjID = {}
      self._StatID = {}
      for _, talent_id in pairs(Talents) do
        local TalentConf = DataConfigManager:GetPetTalentConf(talent_id, true)
        for _, Effect in pairs(TalentConf.effect_group) do
          local effect = Effect.effect
          local effect_param = Effect.effect_param
          if effect == Enum.PetTalentEffect.PTE_PERCEPTION_SKILL_STAMINA_RATIO then
            self.statId_perception_vitality = self.owner.statComponent:ApplyStat(StatType.VITALITY_PERCEPTION_COST_RATIO_TALENT, effect_param / 10000 - 1, Stat.StatApplyType.Percent, nil, 1)
          end
        end
      end
    end
  end
end

function ScenePlayerPerceptionBuff:RemovePerceptionTalent()
  if self.statId_perception_vitality then
    self.owner.statComponent:RemoveStat(StatType.VITALITY_PERCEPTION_COST_RATIO_TALENT, self.statId_perception_vitality)
  end
end

function ScenePlayerPerceptionBuff:OnCmdEntryShortResident()
  if self._stat == self.StatEnum.Short and self._pet then
    self._stat = self.StatEnum.ShortResident
    Log.Warning("\230\132\159\231\159\165buff\239\188\140\232\191\155\229\133\165\231\159\173\230\140\137\229\184\184\233\169\187")
  elseif self._stat == self.StatEnum.Finishing or self._stat == self.StatEnum.WaittingSkill then
    self:PushPreStatList(self.StatEnum.ShortResident)
  else
    Log.Error("\230\151\160\230\179\149\232\191\155\229\133\165\231\159\173\230\140\137\229\184\184\233\169\187\231\154\132\230\132\159\231\159\165\231\138\182\230\128\129")
    self:OnSkillEnd()
  end
end

function ScenePlayerPerceptionBuff:OnCmdEntryLong()
  if self._stat == self.StatEnum.Short and self._pet then
    self._stat = self.StatEnum.Long
    Log.Warning("\230\132\159\231\159\165buff\239\188\140\232\191\155\229\133\165\233\149\191\230\140\137\229\137\141\230\145\135")
  elseif self._stat == self.StatEnum.Finishing or self._stat == self.StatEnum.WaittingSkill then
    self:PushPreStatList(self.StatEnum.Long)
  else
    Log.Error("\230\151\160\230\179\149\232\191\155\229\133\165\233\149\191\230\140\137\231\154\132\230\132\159\231\159\165\231\138\182\230\128\129")
    self:OnSkillEnd()
  end
end

function ScenePlayerPerceptionBuff:OnCmdEntryLongResident()
  if self._stat == self.StatEnum.Long and self._pet then
    self._stat = self.StatEnum.LongResident
    Log.Warning("\230\132\159\231\159\165buff\239\188\140\232\191\155\229\133\165\233\149\191\230\140\137\229\184\184\233\169\187")
  elseif self._stat == self.StatEnum.Finishing or self._stat == self.StatEnum.WaittingSkill then
    self:PushPreStatList(self.StatEnum.LongResident)
  else
    Log.Error("\230\151\160\230\179\149\232\191\155\229\133\165\233\149\191\230\140\137\229\184\184\233\169\187\231\154\132\230\132\159\231\159\165\231\138\182\230\128\129")
    self:OnSkillEnd()
  end
end

function ScenePlayerPerceptionBuff:OnCmdFinish()
  Log.Warning("\231\167\187\233\153\164\230\132\159\231\159\165\231\138\182\230\128\129")
  if self._pet then
    self._pet:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
    self._pet = nil
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_PERCEPTION_END)
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_END, AbilityID.RIDE_ALL_MAIN)
    self:FinishPerception()
  else
    Log.Debug("\231\144\134\232\174\186\228\184\138\228\184\141\229\186\148\232\175\165\229\135\186\231\142\176\232\191\153\231\167\141\230\131\133\229\134\181\239\188\140\228\189\134\230\158\129\231\171\175\230\147\141\228\189\156\228\184\139\229\143\175\232\131\189\228\188\154buff\229\133\136\231\167\187\233\153\164\239\188\140\229\134\141\230\148\182\229\136\176\230\138\128\232\131\189\229\155\158\232\176\131")
    self.owner.PetSensingComponent:StopPerceptionSkill()
    self.owner.PetSensingActivelyComponent:StopPerceptionSkill()
    self:OnSkillEnd()
  end
end

function ScenePlayerPerceptionBuff:OnCmdOverride(Pet)
  Log.Warning("\230\132\159\231\159\165\231\138\182\230\128\129\232\166\134\231\155\150")
  if #self._PreCmdList > 0 then
    self._PreCmdList = {}
  end
  if self._stat == self.StatEnum.Finishing or self._stat == self.StatEnum.WaittingSkill then
    self._pet = Pet
    return
  end
  if self._pet == Pet then
    self:OnCmdFinish()
    return
  end
  if self._pet then
    self._pet:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
  end
  self._pet = Pet
  self:FinishPerception(false, true)
end

function ScenePlayerPerceptionBuff:OnPetStatusChanged(status, value, pet)
  if self._pet == pet then
    local Status = pet:GetStatus()
    if Status ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_SCENE and Status ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_INTERACT then
      Log.Debug("\229\174\160\231\137\169\231\138\182\230\128\129\230\155\180\230\150\176\230\137\147\230\150\173\230\132\159\231\159\165", table.getKeyName(ProtoEnum.WorldPlayerPetStatusType, Status))
      self:OnCmdFinish()
    end
  end
end

function ScenePlayerPerceptionBuff:FinishPerception(force, bOverriden)
  self:RemovePerceptionTalent()
  force = force or false
  self._PreCmdList = {}
  self._stat = self.StatEnum.Finishing
  if not force then
    if self._lastRide then
      self.owner.PetSensingActivelyComponent:StopPerceptionSkill(self, self.OnSkillEnd)
    else
      self.owner.PetSensingComponent:StopPerceptionSkill(self, self.OnSkillEnd, bOverriden)
    end
  else
    self.owner.PetSensingComponent:StopPerceptionSkill(nil, nil, bOverriden)
    self.owner.PetSensingActivelyComponent:StopPerceptionSkill()
    self:OnSkillEnd()
  end
end

function ScenePlayerPerceptionBuff:OnSkillEnd()
  if self._pet then
    self._stat = self.StatEnum.Prepare
    self:Start()
  else
    local statusComponent = self.owner.statusComponent
    if statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_GANZHI) then
      statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_GANZHI, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1)
    else
      self.owner.buffComponent:RemoveBuff("PerceptionBuff")
    end
  end
end

function ScenePlayerPerceptionBuff:OnVitalityOver()
  if self._stat ~= self.StatEnum.Finishing then
    self:OnCmdFinish()
  end
end

function ScenePlayerPerceptionBuff:OnUpdate(deltaTime)
  if self._stat == self.StatEnum.ShortResident then
    local Pawn = self.owner.viewObj
    if Pawn.RidePet then
      Pawn = Pawn.RidePet
    end
    local speed = Pawn:GetVelocity():Size()
    if speed > 1 then
      Log.Warning("\231\167\187\229\138\168\230\137\147\230\150\173\231\159\173\230\140\137\229\184\184\233\169\187\230\132\159\231\159\165")
      self:OnCmdFinish()
    end
  end
end

function ScenePlayerPerceptionBuff:OnStatusChanged(status, value, type)
  if self._stat == self.StatEnum.ShortResident and status == Enum.WorldPlayerStatusType.WPST_AIMTHROWING and type == Enum.WPST_OpCode.WPST_OPCODE_ADD then
    Log.Warning("\230\138\149\230\142\183\230\137\147\230\150\173\231\159\173\230\140\137\229\184\184\233\169\187\230\132\159\231\159\165")
    self:OnCmdFinish()
  end
end

function ScenePlayerPerceptionBuff:OnAttacked()
  Log.Warning("\229\143\151\229\135\187\230\137\147\230\150\173\230\132\159\231\159\165")
  self:OnCmdFinish()
end

function ScenePlayerPerceptionBuff:OnLuopanStateChanged(bOpen)
  if bOpen then
    Log.Warning("\231\189\151\231\155\152\230\137\147\230\150\173\230\132\159\231\159\165")
    self:OnCmdFinish()
  end
end

function ScenePlayerPerceptionBuff:OnDialogueStarted()
  Log.Warning("\229\175\185\232\175\157\230\137\147\230\150\173\230\132\159\231\159\165")
  self:OnCmdFinish()
end

function ScenePlayerPerceptionBuff:OnFullScreenOpened()
  Log.Warning("\229\133\168\229\177\143UI\230\137\147\230\150\173\230\132\159\231\159\165")
  self:OnCmdFinish()
end

function ScenePlayerPerceptionBuff:LoadMapStart()
  Log.Warning("\229\156\176\229\155\190\229\138\160\232\189\189\230\137\147\230\150\173\230\132\159\231\159\165")
  self:OnCmdFinish()
end

function ScenePlayerPerceptionBuff:OnFinish(param)
  _G.NRCAudioManager:SetStateByName("ListenMode", "Close", "ScenePlayerPerceptionBuff")
  if self._pet then
    self._pet:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPetStatusChanged)
  end
  if self._stat ~= self.StatEnum.Finishing then
    self._pet = nil
    self:FinishPerception(true)
  end
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, self.OnAttacked)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_LUOPAN_STATE_CHANGED, self.OnLuopanStateChanged)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.LoadMapStart, self.LoadMapStart)
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueStarted, self.OnDialogueStarted)
  _G.NRCPanelManager.layerCenter:RemoveEventListener(self, UILayerEvent.FULLSCREEN_LAYER_OPENWINDOW, self.OnFullScreenOpened)
  self._pet = nil
  Log.Warning("\230\132\159\231\159\165buff\231\167\187\233\153\164")
end

function ScenePlayerPerceptionBuff:PushPreStatList(value)
  self._PreCmdList[#self._PreCmdList + 1] = value
end

function ScenePlayerPerceptionBuff:OnRefresh()
end

function ScenePlayerPerceptionBuff:IsRidePet(pet)
  if self.owner and self.owner.viewObj then
    local RideCompoment = self.owner.viewObj.BP_RideComponent
    if RideCompoment and pet == RideCompoment.ScenePet then
      return true
    end
  end
  return false
end

return ScenePlayerPerceptionBuff
