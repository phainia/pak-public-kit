local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local NRCUtils = require("Core.NRCUtils")
local WorldCombatResLoadComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatResLoadComponent")
local ResRequest = require("Core.Service.ResourceManager.ResRequest")
local Base = WorldCombatBuffBase
local WorldCombatBuffCastSkill = Base:Extend("WorldCombatBuffCastSkill")

function WorldCombatBuffCastSkill:Ctor(Parent, Buff, Conf)
  Base.Ctor(self, Parent, Buff, Conf)
  if UE.UObject.IsValid(self.Parent.owner.viewObj) then
    self.ownerSkillComp = self.Parent.owner.viewObj.RocoSkill
  end
end

function WorldCombatBuffCastSkill:OnInit()
  Base.OnInit(self)
  self:OnCastSkill()
end

function WorldCombatBuffCastSkill:OnAdd()
  Base.OnAdd(self)
  self:OnCastSkill()
end

function WorldCombatBuffCastSkill:OnRemove(Reason)
  Base.OnRemove(self, Reason)
  if self.skillObj then
    self.skillObj:ClearDelegates()
    self.ownerSkillComp:CancelSkill(self.skillObj, UE4.ESkillActionResult.SkillActionResultSuccessful)
    self.skillObj = nil
  end
  if self.skillRequest then
    _G.NRCResourceManager:UnLoadRes(self.skillRequest)
    self.skillRequest = nil
  end
  self.ownerSkillComp = nil
end

function WorldCombatBuffCastSkill:OnCastSkill()
  if not self.Parent.owner then
    return
  end
  if not UE.UObject.IsValid(self.ownerSkillComp) then
    return
  end
  local skillPath = self.Config.option[1].skill_name
  local classPath = NRCUtils.FormatBlueprintAssetPath(skillPath)
  if self.Caster.config.genre == Enum.ClientNpcType.CNT_PETBOSS then
    local WorldCombatResLoadComp = self.Caster:EnsureComponent(WorldCombatResLoadComponent)
    if table.containsKey(WorldCombatResLoadComp.normalResList, classPath) then
      local resRequest = ResRequest()
      self:SkillLoadSuccess(resRequest, WorldCombatResLoadComp.normalResList[classPath])
      return true
    end
  end
  if _G.NRCResourceManager then
    self.skillRequest = _G.NRCResourceManager:LoadResAsync(self, classPath, PriorityEnum.Active_World_Combat_Boss, 10, self.SkillLoadSuccess, self.SkillLoadFailed)
  end
end

function WorldCombatBuffCastSkill:SkillLoadSuccess(req, asset)
  if not UE.UObject.IsValid(self.ownerSkillComp) then
    return
  end
  if self.skillObj then
    self.skillObj:ClearDelegates()
    self.ownerSkillComp:CancelSkill(self.skillObj, UE4.ESkillActionResult.SkillActionResultSuccessful)
    self.skillObj = nil
  end
  self.skillObj = self.ownerSkillComp:FindOrAddSkillObj(asset)
  if not self.skillObj then
    Log.Error("cannot find skill from RocoSkillComponent!")
  end
  self.skillObj:SetCaster(self.Parent.owner.viewObj)
  self.skillObj:SetTargets({
    self.Parent.owner.viewObj
  })
  self.skillObj:SetPassive(true)
  self.skillObj.IsSkipMeleeBackswing = true
  self.skillObj.CanInterrupt = true
  self.skillObj:ClearDelegates()
  self.skillObj:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  self.skillObj:RegisterEventCallback("End", self, self.SkillComplete)
  self.skillObj:RegisterEventCallback("Interrupt", self, self.SkillComplete)
  local result = self.ownerSkillComp:LoadAndPlaySkill(self.skillObj)
  if result ~= UE.ESkillStartResult.Success then
    Log.Error("failed to play skill! result=", UE.ESkillStartResult:GetNameByValue(result), "path=", req.assetPath)
    return self:SkillPlayFailed(result)
  end
end

function WorldCombatBuffCastSkill:SkillLoadFailed(req, msg)
  Log.Error("failed to load skill! msg=", msg, "path=", req.assetPath)
end

function WorldCombatBuffCastSkill:SkillPlayFailed(result)
  if self.skillObj then
    self.skillObj:ClearDelegates()
    self.skillObj = nil
  end
  self.ownerSkillComp = nil
end

function WorldCombatBuffCastSkill:SkillComplete(name, skill)
  skill:ClearDelegates()
  self.skillObj = nil
  self.ownerSkillComp = nil
end

return WorldCombatBuffCastSkill
