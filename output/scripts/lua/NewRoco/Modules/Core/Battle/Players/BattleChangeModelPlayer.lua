local EventDispatcher = require("Common.EventDispatcher")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleChangeModelPlayer = BattlePlayerBase:Extend()

function BattleChangeModelPlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.BattleManager = _G.BattleManager
  self.PawnManager = _G.BattleManager.battlePawnManager
  self.newPet = nil
end

function BattleChangeModelPlayer:Reset()
  self.change_model = nil
  self.old_model = nil
  self.Player = nil
  self.performNode = nil
  self.changeModelBaseId = nil
  self.newPet = nil
end

function BattleChangeModelPlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  _G.BattleManager:SaveCraneCameraTemporaryPosData()
  self.BattlePet = self.PawnManager:GetPetByGuid(self.change_model.pet_id)
  if not self.BattlePet then
    Log.Warning("zgx BattleChangeModelPlayer cant find battle pet ,\229\183\178\228\184\139\229\156\186\231\154\132\229\174\160\231\137\169\230\151\160\230\179\149\230\137\167\232\161\140changeModel\239\188\129\239\188\129\239\188\129", self.change_model.pet_id)
    local card = self.PawnManager:GetCardByGuid(self.change_model.pet_id)
    if card then
      card:OverwriteByServer(self.change_model.pet_info)
      card:RefreshByServer()
    end
    self:OnSkillComplete()
    return
  end
  if 1 == self.change_model.role_magic_flag then
    self:OnSkillComplete()
    return
  end
  self:SetHpVisible(false)
  self.BattlePet:ChangeBuffVisibility(false)
  self.Player = self.BattlePet.player
  self.changeModelBaseId = self.change_model.pet_info.battle_inside_pet_info.base_conf_id
  self:PawnNewPetModel()
end

function BattleChangeModelPlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.change_model = performInfo.change_model
end

function BattleChangeModelPlayer:OnSkillComplete()
  if self.performNode then
    self:SetHpVisible(true)
    self:OnFinish()
    Log.Debug("BattleChangeModelPlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
    self.performNode:PerformComplete()
    self:Reset()
  end
end

function BattleChangeModelPlayer:PawnNewPetModel()
  local card = self.Player.deck:GetCardByGuid(self.change_model.pet_id)
  local petInfo = self.change_model.pet_info
  if not card then
    Log.Warning("not find pet by id : ", self.change_model.pet_id)
    self:OnSkillComplete()
    return
  end
  if petInfo.battle_inside_pet_info.pet_id then
    card:OverwriteByServer(petInfo)
    card:RefreshByServer()
    card:RefreshByInfoAndBaseConf(petInfo, self.changeModelBaseId)
    card.petState:ResetAllState()
  end
  card.pos = petInfo.battle_inside_pet_info.pos
  card:SetInBattleField(true)
  self.newPet = nil
  self.newPet = self.PawnManager:PawnPet(self.Player.teamEnm, self.Player.team, card, self.Player)
  _G.BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED)
end

function BattleChangeModelPlayer:OnPawnNewPetFinish(pet)
  if not self.newPet or not self.newPet.model then
    self:OnSkillComplete()
    return
  end
  self.newPet = pet
  self.newPet:SetScale(1)
  if not BattleUtils.IsDeepWater() or not self.newPet:GetCanSwimming() then
    local pos = self.newPet.model:Abs_K2_GetActorLocation()
    local halfHeight = pet:GetHalfHeight()
    local ans, posNew = LineTraceUtils.GetPointValidLocation(pos, halfHeight)
    posNew.Z = posNew.Z + self.newPet:GetHalfHeight()
    self.newPet.model:Abs_K2_SetActorLocation_WithoutHit(posNew)
  end
  _G.BattleEventCenter:UnBind(self)
  self.newPet:SetPetVisibility(false)
  local skillPath = BattleSkillManager:GetChangeModelRes()
  local skillClass = BattleSkillManager:GetLoadedClass(skillPath)
  self:PlayChangeModelSkill(skillClass)
end

function BattleChangeModelPlayer:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED then
    self:OnPawnNewPetFinish(...)
    return true
  end
end

function BattleChangeModelPlayer:IsMultiAttack()
  if not self.performNode then
    return false
  end
  if SkillUtils.IsMultiAttackType(self.performNode:GetCastMoment()) then
    return true
  end
  if self.performNode.OwnerGroup and self.performNode:GetGroupHead() then
    return SkillUtils.IsMultiAttackType(self.performNode:GetGroupHead():GetCastMoment())
  end
  return false
end

function BattleChangeModelPlayer:PlayChangeModelSkill(skillClass)
  if not (skillClass and self.performNode) or self.performNode.IsFastPlay then
    self:OnSkillComplete()
    return
  end
  if not UE.UObject.IsValid(skillClass) then
    Log.Error("BattleChangeModelPlayer:PlayChangeModelSkill skillClass is invalid")
    self:OnSkillComplete()
    return
  end
  local Caster = self.BattlePet
  local casterModel = Caster and Caster.model
  if not casterModel then
    Log.Error("no model found for BattleChangeModelPlayer")
    self:OnSkillComplete()
    return
  end
  casterModel.mesh.BoundsScale = 100
  self.oldPet = self.BattlePet
  self.newPet:ShowPet()
  local skillObj = casterModel.RocoSkill:AddSkillObjFromClassAndReturn(skillClass)
  if not skillObj then
    Log.Error("skillObj is not found")
    return
  end
  skillObj:SetCaster(casterModel)
  skillObj:SetTargets({
    self.newPet.model
  })
  skillObj:SetPassive(true)
  skillObj:RegisterEventCallback("End", self, self.OnSkillComplete)
  skillObj:RegisterEventCallback("PreEnd", self, self.OnSkillComplete)
  skillObj:RegisterEventCallback("RoleMagicTrigger", self, self.OnRoleMagicChangeModel)
  casterModel.RocoSkill:LoadAndPlaySkill(skillObj)
end

function BattleChangeModelPlayer:OnRoleMagicChangeModel()
  Log.Debug("OnChangeModel")
  self:OnSkillCastMoment(ProtoEnum.Buffbasetrigger_type.OnRoleMagicChangeModel)
end

function BattleChangeModelPlayer:SetHpVisible(isShow)
  if not BattleUtils.IsB1FinalBattleP3() then
    return
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_PLAYERSKILL_ISHIDE_HP, isShow)
end

function BattleChangeModelPlayer:OnFinish()
  if self.oldPet then
    self.oldPet:HidePet()
    table.insert(BattleManager.battlePawnManager.PendingKillBattlePets, self.oldPet)
  end
  if self.newPet and self.change_model and 1 ~= self.change_model.role_magic_flag then
    self.newPet:SetIKEnable(true)
  end
end

return BattleChangeModelPlayer
