local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local AttackComponent
local SceneAttackAimGround = Base:Extend("SceneAttackAimGround")
local GS_SceneGround_Path = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Perception_Aim.G6_Scene_Perception_Aim_C'"

function SceneAttackAimGround:Ctor()
  Base.Ctor(self)
end

function SceneAttackAimGround:Init(inComp)
  self.comp = inComp
  self.owner = inComp.owner
  self.targetActor = nil
  self.hitboxActor = nil
  self:Release()
  self.skillClassRequest = NRCResourceManager:LoadResAsync(self, GS_SceneGround_Path, inComp.ResourcePriority, 10, self.LoadSucc, self.LoadFail)
end

function SceneAttackAimGround:Release()
  if self.skillClassRequest then
    self.skillClassRequest.asset = nil
    NRCResourceManager:UnLoadRes(self.skillClassRequest)
    self.skillClassRequest = nil
  end
end

function SceneAttackAimGround:LoadSucc(req, asset)
  req.asset = asset
  req.assetRef = asset and UnLua.Ref(asset)
  self.comp:LoadFinished(true)
end

function SceneAttackAimGround:LoadFail(req, msg)
  self.comp:LoadFinished(false)
end

function SceneAttackAimGround:OnStart(target, hitbox)
  self.targetActor = target
  self.hitboxActor = hitbox
  local skillClass = self.skillClassRequest.asset
  local skillObj = self.owner.viewObj.RocoSkill:FindOrAddSkillObj(skillClass)
  if skillObj then
    skillObj:ClearDelegates()
    skillObj:SetCaster(self.owner.viewObj):SetTargets({hitbox}):RegisterEventCallback("End", self, self.OnEnd):RegisterEventCallback("PreEnd", self, self.OnEnd):RegisterEventCallback("PreEndAnim", self, self.OnEnd):RegisterEventCallback("Interrupt", self, self.OnEnd)
    local result = self.owner.viewObj.RocoSkill:LoadAndPlaySkill(skillObj)
    if result ~= UE.ESkillStartResult.Success then
      self:OnEnd()
    end
    if self.targetActor then
      _G.UpdateManager:Register(self)
    end
  else
    Log.Warning("SceneAttackAimGround:OnStart, Class load failed", GS_SceneGround_Path)
    return false
  end
  return true
end

function SceneAttackAimGround:OnTick()
  if self.targetActor == nil then
    return
  end
  if not AttackComponent then
    AttackComponent = require("NewRoco.Modules.Core.Scene.Component.Attack.AttackComponent")
  end
  if not self.comp or not self.comp.state == AttackComponent.State.Aiming then
    _G.UpdateManager:UnRegister(self)
    local vObj = self.owner.viewObj
    if not vObj then
      return Log.Warning("SceneAttackAimGround, view missing")
    end
    vObj.RocoSkill:StopCurrentSkill()
    self:OnEnd()
    return
  end
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel9)
  local OutHit, Success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), self.targetActor:GetActorLocation(), self.targetActor:GetActorLocation() - UE4.FVector(0, 0, 2000), TraceChannel, false, {
    self.owner.viewObj,
    self.targetActor.viewObj,
    self.hitboxActor
  })
  if Success then
    self.hitboxActor:Abs_K2_SetActorLocation_WithoutHit(OutHit.Location)
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, self.hitboxActor:Abs_K2_GetActorLocation(), 20, 10, UE4.FLinearColor(1.0, 1, 0.1), 1, 1)
    end
  else
    self.hitboxActor:Abs_K2_SetActorLocation_WithoutHit(self.targetActor:GetActorLocation())
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, self.hitboxActor:Abs_K2_GetActorLocation(), 20, 10, UE4.FLinearColor(1.0, 0.1, 0.1), 1, 1)
    end
  end
end

function SceneAttackAimGround:OnEnd()
  _G.UpdateManager:UnRegister(self)
  if self.owner == nil then
    return
  end
  self.comp:AimEnd()
  self.targetActor = nil
  self.hitboxActor = nil
  Base.OnEnd(self)
end

function SceneAttackAimGround:OnInterrupt()
  local skillClass = self.skillClassRequest and self.skillClassRequest.asset
  if skillClass then
    local skillObj = self.owner.viewObj.RocoSkill:FindSkillObj(skillClass)
    if skillObj then
      self.owner.viewObj.RocoSkill:CancelSkill(skillObj, UE.ESkillActionResult.SkillActionResultInterrupted)
      return
    end
  end
  self:OnEnd()
end

return SceneAttackAimGround
