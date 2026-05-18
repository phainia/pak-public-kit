local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = PetActionBase
local PetActionForceTester = Base:Extend("PetActionForceTester")

function PetActionForceTester:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  if 0 == rsp.ret_info.ret_code then
    self:StartSkill()
  else
    self:Finish(false)
  end
end

function PetActionForceTester:ContinueNormalInteract()
  return false
end

function PetActionForceTester:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAN_FRONT
end

function PetActionForceTester:StartSkill()
  local petView = self:GetRunnerView()
  if not petView then
    Log.Error("Cannot find pet view!")
    self:SkillFailed()
    return
  end
  local IsMain = self:GetIsMainPerformAction()
  local HasControlAuthority = self:HasControlAuthority()
  local skillPath
  if IsMain and HasControlAuthority then
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_ForceTesterMain.G6_Scene_ForceTesterMain"
  else
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_ForceTester.G6_Scene_ForceTester"
  end
  local targetView = self:GetOwnerNPCView()
  if not targetView then
    Log.Error("cannot find target view!")
    self:SkillFailed()
    return
  end
  local skillComp = self:GetRunnerSkillComponent()
  if not skillComp then
    Log.Error("Cannot find RocoSkillComponent from BP!")
    self:SkillFailed()
    return
  end
  local skillObj = RocoSkillProxy.Create(skillPath, skillComp, PriorityEnum.Active_Throw_Pet)
  if not skillObj then
    Log.Error("cannot find skill from RocoSkillComponent!")
    self:SkillFailed()
    return
  end
  skillObj:SetCaster(petView)
  skillObj:SetTargets({targetView})
  skillObj:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skillObj:RegisterEventCallback("PreEndAnim", self, self.SkillComplete)
  skillObj:RegisterEventCallback("End", self, self.SkillComplete)
  skillObj:RegisterEventCallback("Interrupt", self, self.SkillComplete)
  skillObj:RegisterEventCallback("RiseHighest", self, self.OnRiseHighest)
  targetView.IsPlaying = IsMain
  if IsMain and not self:HasControlAuthority() then
    targetView.isRiseHighest = true
  end
  skillObj:PlaySkill(self, self.OnSkillCallBack)
end

function PetActionForceTester:OnSkillCallBack(skillProxy, result)
  self.skillObj = skillProxy.SkillObject
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("PetActionForceTester failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function PetActionForceTester:SkillFailed()
  local targetView = self:GetOwnerNPCView()
  if targetView then
    targetView.IsPlaying = false
  end
  self:Finish(false)
end

function PetActionForceTester:OnRiseHighest(name, skill)
  if not self:HasControlAuthority() then
    return
  end
  if self.bShowPerformEnd then
    return
  end
  local bShowSuccess = false
  local targetView = self:GetOwnerNPCView()
  if targetView and type(targetView.DoShow) == "function" then
    targetView.isRiseHighest = true
    bShowSuccess = targetView:DoShow()
  end
  if not bShowSuccess then
    return
  end
  self.bShowPerformEnd = true
end

function PetActionForceTester:SkillComplete(name, skill)
  self:OnRiseHighest("RiseHighest", self.skillObj)
  local targetView = self:GetOwnerNPCView()
  if targetView then
    targetView.IsPlaying = false
  end
  self:Finish(true)
end

function PetActionForceTester:OnRunnerLeave(Runner)
  if self.Runner ~= Runner then
    Log.Error("Runner\229\175\185\228\184\141\228\184\138\228\186\134", self.Runner and self.Runner:DebugNPCNameAndID() or "\229\183\178\233\148\128\230\175\129", Runner and Runner:DebugNPCNameAndID() or "\229\183\178\233\148\128\230\175\129")
    return
  end
  if self.bShowPerformEnd then
    return
  end
  self:OnRiseHighest("RiseHighest", self.skillObj)
  local targetView = self:GetOwnerNPCView()
  if targetView then
    targetView.IsPlaying = false
  end
end

return PetActionForceTester
