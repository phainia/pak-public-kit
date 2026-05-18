local BattleClientBranchActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleClientBranchActionBase")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleClientBranchActionBase
local BattlePlayAnimBaseAction = Base:Extend("BattlePlayAnimBaseAction")
FsmUtils.MergeMembers(Base, BattlePlayAnimBaseAction, {})

function BattlePlayAnimBaseAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.LerpCamera = false
  self:SetActionType(BattleActionBase.ActionType.ClientAnimAction)
end

function BattlePlayAnimBaseAction:DoEnter()
  self.cachedValueTable = {}
  Base.DoEnter(self)
end

function BattlePlayAnimBaseAction:Play(caster, targets, skillClaPath, isPassive)
  Log.Debug("BattlePlayAnimBaseAction Play:", skillClaPath)
  targets = targets or {}
  self.time = 0
  self.timeRemain = 0
  self.TickCamera = false
  if self.LerpCamera then
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0, nil, nil, true)
  end
  skillClaPath = NRCUtils.FormatBlueprintAssetPath(skillClaPath)
  self.caster = caster
  self.targets = targets
  self.isPassive = isPassive
  _G.BattleResourceManager:LoadResAsync(self, skillClaPath, self.OnLoadResComplete, self.OnLoadResFail)
end

function BattlePlayAnimBaseAction:OnLoadResComplete(skillClass)
  if not self.active then
    return
  end
  self:OnBeforePlay()
  self:LoadSkillOver(skillClass, self.caster, self.targets, self.isPassive)
  self:OnAfterPlay()
end

function BattlePlayAnimBaseAction:OnLoadResFail()
  if self.finished then
    return
  end
  self:OnBeforePlay()
  self:Finish()
end

function BattlePlayAnimBaseAction:OnBeforePlay()
end

function BattlePlayAnimBaseAction:OnAfterPlay()
end

function BattlePlayAnimBaseAction:LoadSkillOver(skillClass, caster, targets, isPassive)
  self.g6SkillClass = skillClass
  self:CastG6Ability(caster, targets, isPassive)
end

function BattlePlayAnimBaseAction:CastG6Ability(Caster, targets, isPassive)
  local model
  if Caster and Caster.viewObj then
    Log.Debug("BattlePlayAnimBaseAction BattlePet")
    model = Caster.viewObj
  elseif Caster and Caster.model then
    Log.Debug("BattlePlayAnimBaseAction SceneCharacter")
    model = Caster.model
  else
    Log.Debug("BattlePlayAnimBaseAction nil:", type(Caster), Caster)
    self:Finish()
    return
  end
  if self.g6SkillClass then
    self.skillComponent = model.RocoSkill
    if not self.skillComponent then
      self:Finish()
      return
    end
    self.skillObj = self.skillComponent:FindOrAddSkillObj(self.g6SkillClass)
    self:SetTimeoutValueBySkillObj(self.skillObj)
    if not self.skillObj then
      Log.Error("\229\136\157\229\167\139\229\140\150\230\138\128\232\131\189\229\164\177\232\180\165:", self.g6SkillClass)
      self:Finish()
      return
    end
    self:OnSetSkillObj(self.skillObj)
    self.skillObj:SetCaster(model)
    self.skillObj:RegisterRawCallback(self, self.OnSkillEvent)
    self.skillObj:SetTargets(targets)
    self.skillObj:SetPassive(isPassive)
    if self.cachedValueTable and #self.cachedValueTable > 0 then
      self:ApplyCacheBlackboardValue(self.cachedValueTable, self.skillObj:GetBlackboard())
    end
    self:CustomCastG6BeforePlay(self.skillObj)
    local result = self.skillComponent:LoadAndPlaySkill(self.skillObj)
    Log.Debug("BattlePlayAnimBaseAction Play result:", result, UE4.ESkillStartResult.Success)
    return result == UE4.ESkillStartResult.Success
  else
    self:Finish()
  end
  return false
end

function BattlePlayAnimBaseAction:OnSetSkillObj(skillObj)
end

function BattlePlayAnimBaseAction:CustomCastG6BeforePlay(skillObj)
end

function BattlePlayAnimBaseAction:SetCacheBlackboardValue(valueTable)
  self.cachedValueTable = valueTable
end

function BattlePlayAnimBaseAction:ApplyCacheBlackboardValue(valueTable, blackboard)
  for _, value in ipairs(valueTable) do
    if 2 == #value and type(value[1]) == "string" and nil ~= value[2] then
      blackboard:SetValueAsString(value[1], tostring(value[2]))
    end
  end
end

function BattlePlayAnimBaseAction:OnCameraUnbind()
  self.timeRemain = self.skillObj:GetLength() - self.skillObj:GetCurrentTime()
  local Blackboard = self.skillObj:GetBlackboard()
  self.Kamera = Blackboard:GetValueAsObject("camActor_0002")
  self.KameraBone = Blackboard:GetValueAsObject("camActor_0002_SA")
  self.FOV = self.Kamera:GetComponentByClass(UE4.UCameraComponent).FieldOfView
  self.TickCamera = true
  if _G.BattleManager.vBattleField.battleCameraManager then
    _G.BattleManager.vBattleField.battleCameraManager.KontrolEnabled = false
  end
end

function BattlePlayAnimBaseAction:OnTick(DeltaTime)
  if self.TickCamera and self.LerpCamera then
    self.time = self.time + DeltaTime
    local alpha = self.time / self.timeRemain
    if alpha >= 1 then
      alpha = 1
      self.TickCamera = false
      _G.BattleManager.vBattleField.battleCameraManager.KontrolEnabled = true
    end
    local CamVec = _G.BattleManager.vBattleField:GetPCGCamTransform()
    local FOVDiff = _G.BattleManager.vBattleField.battleCameraManager.FOV - self.FOV
    self.KamVec = self.KameraBone.SkeletalMeshComponent:GetSocketTransform("cam_01")
    self.Kamera:Abs_K2_SetActorTransform_WithoutHit(UE4.UKismetMathLibrary.TLerp(self.KamVec, CamVec, alpha))
    self.Kamera:GetComponentByClass(UE4.UCameraComponent).FieldOfView = self.FOV + FOVDiff * math.min(alpha, 1)
  end
end

function BattlePlayAnimBaseAction:OnSkillEvent(event, skill)
  Log.Debug("BattlePlayAnimBaseAction OnSkillEvent:", event)
  if self[event] then
    self[event](self, event, skill)
  end
  if "Unbind" == event and self.LerpCamera then
    self:OnCameraUnbind()
  end
  if "End" == event or "Interrupt" == event or "PreEnd" == event then
    Log.Debug("\229\138\168\231\148\187\230\146\173\230\148\190\229\174\140\230\175\149")
    self:Finish(false)
  else
  end
end

function BattlePlayAnimBaseAction:OnFinish()
  self.Caster = nil
  self.targets = nil
end

function BattlePlayAnimBaseAction:OnExit()
  if self.skillComponent then
    self.skillComponent:StopCurrentSkill()
    self.skillComponent = nil
  end
  self.Caster = nil
  self.skillObj = nil
  self.g6SkillClass = nil
end

return BattlePlayAnimBaseAction
