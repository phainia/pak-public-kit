require("UnLua")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local LocalSpawnTransformObj = UE.FTransform()
local LocalTargetClass = UE.ANPCSimpleSkillTarget
local NPCActionSoulDimoGoUpstairs = Base:Extend("NPCActionSoulDimoGoUpstairs")

function NPCActionSoulDimoGoUpstairs:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionSoulDimoGoUpstairs:Execute()
  Log.Debug("NPCActionSoulDimoGoUpstairs:Execute")
  Base.Execute(self)
end

function NPCActionSoulDimoGoUpstairs:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:StartSkill()
end

function NPCActionSoulDimoGoUpstairs:StartSkill()
  Log.Debug("NPCActionSoulDimoGoUpstairs:StartSkill")
  local player = self:GetPlayer()
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_LingJie_Go_UpStairs", skillComp, PriorityEnum.Active_Player_Action)
  if not skill then
    Log.Error("NPCActionSoulDimoGoUpstairs:Execute \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false)
    return
  end
  local owner = self:GetOwnerNPC()
  if nil == owner then
    self:Finish(false)
    return
  else
    owner:SetNotDestroyFlag(true)
  end
  local contentId = self.Config.action_param1
  local targetNPC
  if contentId and tonumber(contentId) then
    targetNPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByRefreshID, tonumber(contentId))
    if nil == targetNPC then
      self:Finish(false)
      return
    end
  end
  contentId = self.Config.action_param2
  local targetDoorNPC
  if contentId and tonumber(contentId) then
    targetDoorNPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByRefreshID, tonumber(contentId))
    if nil == targetDoorNPC or targetDoorNPC.viewObj == nil then
      self:Finish(false)
      return
    end
    self.targetDoorNPC = targetDoorNPC
    self.targetDoorNPC:SetNotDestroyFlag(true)
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(owner.viewObj)
  LocalSpawnTransformObj.Translation = UE4.FVector(6510, 100, 788)
  local TargetObj = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(LocalTargetClass, LocalSpawnTransformObj, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if owner and owner.AIComponent then
    owner.AIComponent:ForceLockForReason(true, true, AIDefines.LockReason.ACTION_PROCESS)
  end
  local targetDir = targetNPC:GetActorLocation() - owner:GetActorLocation()
  targetDir.z = 0
  owner:SetActorRotation(targetDir:ToRotator())
  owner:DisableVisibilityOptimization()
  local CapsuleComponent = owner.viewObj:GetComponentByClass(UE4.UCapsuleComponent)
  if nil ~= CapsuleComponent then
    CapsuleComponent:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
  end
  local comp = owner.viewObj:GetComponentByClass(UE.USignificanceComponent)
  if comp then
    comp:SelfControlSignificance(true, UE.ESignificanceValue.Highest)
  end
  skill:SetTargets({
    targetNPC.viewObj,
    TargetObj,
    targetDoorNPC.viewObj
  })
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:SetDynamicData({StartPoint = TargetObj})
  skill:PlaySkill(self, self.OnSkillStart)
  _G.NRCEventCenter:RegisterEvent("NPCActionSoulDimoGoUpstairs", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionSoulDimoGoUpstairs:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function NPCActionSoulDimoGoUpstairs:SkillFailed()
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionSoulDimoGoUpstairs:SkillComplete(Name, Skill)
  local owner = self:GetOwnerNPC()
  if owner then
    if owner.AIComponent then
      owner.AIComponent:ForceLockForReason(false, true, AIDefines.LockReason.ACTION_PROCESS)
    end
    owner:EnableVisibilityOptimization()
    owner:SetNotDestroyFlag(false)
  end
  if self.targetDoorNPC then
    self.targetDoorNPC:SetNotDestroyFlag(false)
  end
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionSoulDimoGoUpstairs:OnInterrupted(Name, Skill)
  self.SkillStarted = false
  Log.Error("NPCActionSoulDimoGoUpstairs:OnInterrupted")
  self:SkillComplete()
end

function NPCActionSoulDimoGoUpstairs:OnReconnect()
  Log.Error("NPCActionSoulDimoGoUpstairs:OnReconnect need to complete skill!")
  local owner = self:GetOwnerNPC()
  if owner then
    if owner.AIComponent then
      owner.AIComponent:ForceLockForReason(false, true, AIDefines.LockReason.ACTION_PROCESS)
    end
    owner:EnableVisibilityOptimization()
    owner:SetNotDestroyFlag(false)
  end
  if self.targetDoorNPC then
    self.targetDoorNPC:SetNotDestroyFlag(false)
  end
  self.SkillStarted = false
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

return NPCActionSoulDimoGoUpstairs
