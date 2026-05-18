local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.SceneAttackBase")
local SceneAttackActionWater = Base:Extend("SceneAttackActionWater")
local SkillBlueprint_Path = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Perception_Water_02.G6_Scene_Perception_Water_02_C'"

function SceneAttackActionWater:Ctor()
  Base.Ctor(self)
  self.skillPath = SkillBlueprint_Path
end

function SceneAttackActionWater:Init(inComp)
  self.comp = inComp
  self.owner = inComp.owner
  self.target = nil
  self.hitbox = nil
  self:Release()
  self.skillClassRequest = NRCResourceManager:LoadResAsync(self, self.skillPath, inComp.ResourcePriority, 10, self.LoadSucc, self.LoadFail)
end

function SceneAttackActionWater:LoadSucc(req, asset)
  req.asset = asset
  req.assetRef = asset and UnLua.Ref(asset)
  self.comp:LoadFinished(true)
end

function SceneAttackActionWater:LoadFail(req, msg)
  self.comp:LoadFinished(false)
end

function SceneAttackActionWater:Release()
  if self.skillClassRequest then
    self.skillClassRequest.asset = nil
    NRCResourceManager:UnLoadRes(self.skillClassRequest)
    self.skillClassRequest = nil
  end
end

function SceneAttackActionWater:OnStart(target, hitbox)
  self.hitbox = hitbox
  local skillClass = self.skillClassRequest.asset
  local skillObj = self.owner.viewObj.RocoSkill:FindOrAddSkillObj(skillClass)
  if skillObj then
    skillObj:ClearDelegates()
    skillObj:SetCaster(self.owner.viewObj):SetTargets({hitbox}):RegisterEventCallback("End", self, self.OnEnd):RegisterEventCallback("PreEnd", self, self.OnEnd):RegisterEventCallback("PreEndAnim", self, self.OnEnd):RegisterEventCallback("Interrupt", self, self.OnEnd):RegisterEventCallback("TriggerBeHit", self, self.AttackHitEvent)
    local result = self.owner.viewObj.RocoSkill:LoadAndPlaySkill(skillObj)
    if result == UE.ESkillStartResult.Success then
      return true
    else
      Log.Warning("SceneAttackActionNearbyHit:OnStart, PlaySkillFailed", result)
    end
  else
    Log.Warning("SceneAttackAction:OnStart, SkillObj Init Failed", self.skillPath)
  end
  return false
end

function SceneAttackActionWater:AttackHitEvent()
  local hitboxPos
  if self.hitbox and self.hitbox.K2_GetActorLocation then
    hitboxPos = self.hitbox:Abs_K2_GetActorLocation()
  else
    return
  end
  local hit = false
  local radius = self.comp.AttackParam.Radius
  local outActors, result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(self.owner.viewObj, hitboxPos, radius, nil, nil, nil)
  if result then
    for i = 1, outActors:Length() do
      local curActor = outActors:Get(i)
      local sceneCharacter = curActor and curActor.sceneCharacter
      if sceneCharacter and self.comp:OnHit(sceneCharacter) then
        hit = true
        break
      end
    end
  end
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(self.owner.viewObj, self.hitbox:Abs_K2_GetActorLocation(), hitboxPos, 10, UE4.FLinearColor(1, 1, 1), 1, 1)
    if hit then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(1.0, 0.1, 0.1), 1, 1)
    else
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self.owner.viewObj, hitboxPos, radius, 10, UE4.FLinearColor(0.1, 1.0, 0.1), 1, 1)
    end
  end
end

function SceneAttackActionWater:OnEnd()
  if self.owner == nil then
    return
  end
  self.hitbox = nil
  self.comp:ActEnd()
  Base.OnEnd(self)
end

function SceneAttackActionWater:OnInterrupt()
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

return SceneAttackActionWater
