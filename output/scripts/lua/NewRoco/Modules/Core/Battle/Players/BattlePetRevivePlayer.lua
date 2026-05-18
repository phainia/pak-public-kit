local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattlePetRevivePlayer = BattlePlayerBase:Extend()

function BattlePetRevivePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattlePetRevivePlayer:Reset()
  self.reviveInfo = nil
  self.target = nil
  self.Player = nil
  self.performNode = nil
end

function BattlePetRevivePlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.reviveInfo = performInfo.revive_info
end

function BattlePetRevivePlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  _G.BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED)
  local player = self.PawnManager:GetPlayerByGuid(self.reviveInfo.uin)
  if player then
    player.deck:IncrementalRefreshByServer({
      self.reviveInfo.pet
    })
  end
  local targetCard = self.PawnManager:GetCardByGuid(self.reviveInfo.caster_id)
  if targetCard then
    if not targetCard.petState:GetDead() then
      local pet = self.PawnManager:GetPetByGuid(self.reviveInfo.caster_id)
      if pet and pet.card:IsExistAtField() then
        Log.Error("BattlePetRevivePlayer \229\164\141\230\180\187\231\154\132\231\155\174\230\160\135\229\185\182\230\178\161\230\156\137\230\173\187\228\186\161\239\188\129\239\188\129 \228\190\157\231\132\182\229\156\168\230\136\152\229\156\186\228\184\138", self.reviveInfo.caster_id, targetCard.name)
        pet:OverwriteByServer(self.reviveInfo.pet)
        pet:RefreshByServer()
        self:Finish()
        return
      end
    end
    self.Player = targetCard.owner
    targetCard:OverwriteByServer(self.reviveInfo.pet)
    targetCard:RefreshByServer()
    targetCard:SummonBattlePet(self.Player.teamEnm, self.Player.team, targetCard.pos)
  else
    Log.Error("BattlePetRevivePlayer \230\178\161\230\156\137\230\137\190\229\136\176\229\164\141\230\180\187\231\154\132\231\155\174\230\160\135\239\188\129\239\188\129 ", self.reviveInfo.caster_id)
    self:Finish()
  end
end

function BattlePetRevivePlayer:GetSkillPath()
  if self.target then
    return self.target.card.AppearancePath:GetHuanChong()
  end
  Log.Error("zgx \230\178\161\230\156\137\231\155\174\230\160\135\229\174\160\231\137\169")
end

function BattlePetRevivePlayer:PawnPetOver(pet)
  if self.reviveInfo and pet.guid == self.reviveInfo.caster_id then
    self.target = pet
    if self.Player and self.Player.model then
      self:PlayReviveSkill()
    else
      Log.Error("BattlePetRevivePlayer player is nil!!")
      self:RestoreCamera()
      self:SupplyEnd()
    end
  end
end

function BattlePetRevivePlayer:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED then
    self:PawnPetOver(...)
    return true
  end
end

function BattlePetRevivePlayer:PlayReviveSkill()
  local skillPath = self:GetSkillPath()
  local skillClass = BattleSkillManager:GetLoadedClass(skillPath)
  local Skill = self.Player.model.RocoSkill:AddSkillObjFromClassAndReturn(skillClass)
  if not Skill then
    self:RestoreCamera()
    self:SupplyEnd()
    return
  end
  self.target:SetScale(1)
  self.target:SwimSetLockIdle(false)
  BattleUtils.SetParticleKeyForSkillObj(self.target.model, Skill, self.target.card.medalBlackBoard)
  if not self.performNode.performPlayer.turnPlayer.IsMySelfPerform and self.Player ~= self.PawnManager.TeamatePlayer then
    Skill.IsIgnoreCameraAction = true
  elseif BattleUtils.IsTeam() and self.Player ~= self.PawnManager.TeamatePlayer then
    Skill.IsIgnoreCameraAction = true
  end
  local characters = _G.BattleManager.battlePawnManager:GetAllPawnActorForSkill()
  do
    local playerStartIndex = UE4.EBattleStaticActorType.Player_1
    local petStartIndex = UE4.EBattleStaticActorType.Pet_1_1
    if self.Player.teamEnm == BattleEnum.Team.ENUM_ENEMY then
      playerStartIndex = UE4.EBattleStaticActorType.Player_2
      petStartIndex = UE4.EBattleStaticActorType.Pet_2_1
    end
    characters[playerStartIndex] = self.Player.model
    characters[petStartIndex] = self.target.model
  end
  Skill.PlayerAmountType = 1
  Skill:SetCaster(self.Player.model)
  Skill:SetTargets({
    self.target.model
  })
  Skill:SetCharacters(characters)
  Skill:SetDynamicData({
    BallPath = self.target:GetBallPath(),
    BallAdditionalPaths = {"None", "None"}
  })
  Skill:RegisterEventCallback("ActionStart", self, self.ShowTarget)
  Skill:RegisterEventCallback("AdjustCamera", self, self.RestoreCamera)
  Skill:RegisterEventCallback("PreEnd", self, self.SupplyEnd)
  Skill:RegisterEventCallback("PreEndAnim", self, self.SupplyEnd)
  Skill:RegisterEventCallback("End", self, self.SupplyEnd)
  self.Player:PlaySkillObject(Skill)
end

function BattlePetRevivePlayer:ShowTarget(name, skill)
  if not self.target then
    return
  end
  self.target:ShowPet()
  self.target.card.IgnoreAnimCheck = true
  self.target.buffComponent:OnPetBeCatch()
end

function BattlePetRevivePlayer:RestoreCamera(name, skill)
  if not self.target then
    return
  end
  self.target:ShowPet()
  local Blackboard
  if skill then
    Blackboard = skill:GetBlackboard()
  else
    return
  end
  if not skill.IsIgnoreCameraAction then
    BattleManager.vBattleField.battleCameraManager:CalcPos()
    if self.Player.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if Blackboard then
        self.Kamera = Blackboard:GetValueAsObject("camActor_0002")
        self.KameraBone = Blackboard:GetValueAsObject("camActor_0002_SA")
      end
      BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0, nil, nil, true)
      if self.Kamera then
        self.Kamera:Abs_K2_SetActorTransform_WithoutHit(BattleManager.vBattleField:GetPCGCamTransform())
        self.Kamera:GetComponentByClass(UE4.UCameraComponent).FieldOfView = BattleManager.vBattleField.battleCameraManager.FOV
      end
      BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0)
    else
      if Blackboard then
        self.Kamera = Blackboard:GetValueAsObject("camActor_Save1")
        self.KameraBone = Blackboard:GetValueAsObject("camActor_Save1_SA")
      end
      BattleUtils.GetMainWindow().counter = 0
      BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0, nil, nil, true)
      if self.Kamera then
        self.Kamera:Abs_K2_SetActorTransform_WithoutHit(BattleManager.vBattleField:GetPCGCamTransform())
        self.Kamera:GetComponentByClass(UE4.UCameraComponent).FieldOfView = BattleManager.vBattleField.battleCameraManager.FOV
      end
      BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0)
    end
  end
end

function BattlePetRevivePlayer:SupplyEnd()
  if self.Kamera then
    self.Kamera:K2_DestroyActor()
    self.Kamera = nil
  end
  if self.KameraBone then
    self.KameraBone:K2_DestroyActor()
    self.KameraBone = nil
  end
  if self.target then
    self.target.card.IgnoreAnimCheck = false
    self.target.buffComponent:RestartBattleState()
  end
  self:Finish()
end

function BattlePetRevivePlayer:Finish()
  if self.performNode then
    _G.BattleEventCenter:UnBind(self)
    self.performNode:PerformComplete()
  end
  self:Reset()
end

return BattlePetRevivePlayer
