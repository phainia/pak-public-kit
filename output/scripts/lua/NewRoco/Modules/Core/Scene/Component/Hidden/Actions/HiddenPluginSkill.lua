local Class = _G.MakeSimpleClass
local HiddenPluginSkill = Class("HiddenPluginSkill")
local Delegate = require("Utils.Delegate")
local AsyncCacheTime = 10
HiddenPluginSkill:SetMemberCount(12)

function HiddenPluginSkill:Ctor(skillPath, async, preload, priority)
  async = true
  self.owner = nil
  self.path = skillPath
  self.showing = false
  self.skillObj = nil
  self.skillObjRef = nil
  self.use_async = async or false
  self.preload = async and preload or false
  self.load_priority = priority or _G.PriorityEnum.Passive_World_NPC_Hidden_Other
  self.loading_res = false
  self.res_req = nil
  self.SkillEndEvent = Delegate()
  self.preres_req = nil
end

function HiddenPluginSkill:Init(owner)
  self.owner = owner
  if self.preload and not self.preres_req then
    self.preres_req = _G.NRCResourceManager:LoadResAsync(self, self.path, self.load_priority, AsyncCacheTime, self.PreloadSucc, self.PreloadFail)
  end
end

function HiddenPluginSkill:PreloadSucc(req, asset)
  Log.Debug("[HiddenPluginSkill] Preload asset", self.path)
end

function HiddenPluginSkill:PreloadFail(req, msg)
end

function HiddenPluginSkill:Release()
  if self.showing then
    local Model = self.owner.viewObj
    if Model and UE.UObject.IsValid(Model) then
      Model.RocoSkill:CancelSkill(self.skillObj, UE.ESkillActionResult.SkillActionResultSuccessful)
    end
  end
  self.skillObj = nil
  self.skillObjRef = nil
  self:ReleaseRes()
  if self.preload and self.preres_req then
    _G.NRCResourceManager:UnLoadRes(self.preres_req)
    self.preres_req = nil
  end
  self.owner = nil
end

function HiddenPluginSkill:Show(caller, callback)
  if not self.owner or self.loading_res or self.showing then
    if callback then
      callback(caller, AIDefines.ActionResult.Success)
    end
    return
  end
  if callback then
    self.SkillEndEvent:Add(caller, callback)
  end
  self.loading_res = true
  self.res_req = _G.NRCResourceManager:LoadResAsync(self, self.path, self.load_priority, AsyncCacheTime, self.LoadSucc, self.LoadFail)
end

function HiddenPluginSkill:Stop()
  if self.owner then
    self:StopSkill()
  end
end

function HiddenPluginSkill:LoadSucc(req, skillClass)
  self.loading_res = false
  self:PlaySkill(skillClass)
end

function HiddenPluginSkill:LoadFail(req, errMsg)
  self.loading_res = false
  self.res_req = nil
  self.SkillEndEvent:Invoke(AIDefines.ActionResult.Failed)
  self.SkillEndEvent:Clear()
end

function HiddenPluginSkill:SkillEnd()
  self:ReleaseRes()
  self.showing = false
  self.skillObj = nil
  self.skillObjRef = nil
  self.SkillEndEvent:Invoke(AIDefines.ActionResult.Success)
  self.SkillEndEvent:Clear()
end

function HiddenPluginSkill:ReleaseRes()
  if self.use_async and self.res_req then
    local req = self.res_req
    self.res_req = nil
    _G.NRCResourceManager:UnLoadRes(req)
  end
end

function HiddenPluginSkill:PlaySkill(SkillClass)
  self.showing = true
  local Model = self.owner.viewObj
  if not Model then
    self:SkillEnd()
    return Log.Error("[HiddenPluginSkill] PlaySkill no viewObj")
  end
  local RocoSkill = Model.RocoSkill or Model:GetComponentByClass(UE.URocoSkillComponent)
  if not RocoSkill then
    self:SkillEnd()
    return Log.Warning("[HiddenPluginSkill] PlaySkill no SkillComponent")
  end
  local skillObj = RocoSkill:FindOrAddSkillObj(SkillClass)
  if not skillObj or not skillObj.SetCaster then
    self:SkillEnd()
    return Log.Warning("[HiddenPluginSkill] PlaySkill no valid skillObj")
  end
  skillObj:SetPassive(true)
  skillObj:SetCaster(Model)
  skillObj:SetTargets({Model})
  skillObj:ClearDelegates()
  skillObj:RegisterEventCallback("End", self, self.SkillEnd)
  skillObj:RegisterEventCallback("PreEnd", self, self.SkillEnd)
  skillObj:RegisterEventCallback("Interrupt", self, self.SkillEnd)
  self.skillObj = skillObj
  self.skillObjRef = UnLua.Ref(skillObj)
  local result = RocoSkill:LoadAndPlaySkill(skillObj, self.prio)
  if result ~= UE.ESkillStartResult.Success then
    self:SkillEnd()
    return Log.Warning("[HiddenPluginSkill] PlaySkill Failed")
  end
end

function HiddenPluginSkill:StopSkill()
  if self.loading_res then
    self:ReleaseRes()
    self.loading_res = false
    return
  end
  if not self.showing or not self.skillObj then
    return
  end
  local Model = self.owner.viewObj
  if not Model then
    return Log.Error("[HiddenPluginSkill] StopSkill no viewObj")
  end
  local skillObj = self.skillObj
  self.skillObj = nil
  self.skillObjRef = nil
  local RocoSkill = Model.RocoSkill or Model:GetComponentByClass(UE.URocoSkillComponent)
  if RocoSkill then
    RocoSkill:CancelSkill(skillObj, UE4.ESkillActionResult.SkillActionResultInterrupted)
  end
end

function HiddenPluginSkill:GetBlackboard(name)
  if self.showing and self.skillObj and UE.UObject.IsValid(self.skillObj) and UE.UObject.IsValid(self.skillObj.Blackboard) then
    return self.skillObj.Blackboard:GetValueAsObject(name)
  end
  return nil
end

return HiddenPluginSkill
