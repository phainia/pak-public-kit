local TurnComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.TurnComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local BubbleComponent = Base:Extend("BubbleComponent")

function BubbleComponent:Ctor()
  Base.Ctor(self)
  self.RunningSkills = setmetatable({}, {__mode = "v"})
  self.ClassCaches = setmetatable({}, {__mode = "v"})
  self.Requests = {}
  self:Clear()
end

function BubbleComponent:Clear()
  self.FinishCallbackOwner = nil
  self.FinishCallbackFunc = nil
  self.FinishCallbackPayload = nil
  self.PlayingSkill = nil
  self.Type = nil
  self.Turning = false
end

function BubbleComponent:Attach(owner)
  Base.Attach(self, owner)
  self:SetEnable(false)
end

function BubbleComponent:DeAttach()
  self:StopAll()
  self:Clear()
  Base.DeAttach(self)
end

function BubbleComponent:StopAll()
  local SkillComp = self:GetSkillComponent()
  if SkillComp then
    for _, Skill in pairs(self.RunningSkills) do
      SkillComp:CancelSkill(Skill, UE.ESkillActionResult.SkillActionResultInterrupted)
    end
  end
  for Request, _ in pairs(self.Requests) do
    _G.NRCResourceManager:UnLoadRes(Request)
  end
  table.clear(self.Requests)
  table.clear(self.ClassCaches)
  table.clear(self.RunningSkills)
  self.PlayingSkill = nil
end

function BubbleComponent:IsPlaying()
  return self.PlayingSkill ~= nil and not self.Turning
end

function BubbleComponent:Play(Target, Type, Owner, Func, ...)
  if self:IsPlaying() then
    self:Emit(Owner, Func, false, ...)
    return
  end
  local View = self:GetOwnerView()
  if not View then
    self:Emit(Owner, Func, false, ...)
    return
  end
  self.Type = Type
  self.FinishCallbackOwner = Owner
  self.FinishCallbackFunc = Func
  self.FinishCallbackPayload = table.pack(...)
  self.Turning = false
  self:TurnTo(Target)
end

function BubbleComponent:Stop(Type)
  local TargetRequest
  for Request, Value in pairs(self.Requests) do
    if Type == Value then
      _G.NRCResourceManager:UnLoadRes(Request)
      TargetRequest = Request
      break
    end
  end
  if TargetRequest then
    self.Requests[TargetRequest] = nil
  end
  local View = self:GetOwnerView()
  if not View then
    return false
  end
  local SkillComp = self:GetSkillComponent()
  if not SkillComp then
    return false
  end
  local Klass = self.ClassCaches[Type]
  if not Klass then
    return false
  end
  self.ClassCaches[Type] = nil
  local Skill = SkillComp:FindOrAddSkillObj(Klass)
  if not Skill then
    return false
  end
  if not SkillComp:IsPassiveActive(Skill) then
    return false
  end
  if self:IsLoop(Type) then
    Skill.Blackboard:SetValueAsInt("Continue", 0)
  else
    SkillComp:CancelSkill(Skill, UE.ESkillActionResult.SkillActionResultInterrupted)
  end
  return true
end

function BubbleComponent:TurnTo(Target)
  if not Target then
    self:LoadSkill()
    return
  end
  local Owner = self:GetOwner()
  local TurnComp = Owner:EnsureComponent(TurnComponent)
  if not TurnComp then
    self:LoadSkill()
    return
  end
  local Rot = Owner:RotationTo(Target)
  local Now = Owner:GetActorRotation()
  local RawDiff = Now.Yaw - Rot.Yaw
  local Offset = math.floor(RawDiff / 360) * 360
  local YawDiff = RawDiff - Offset
  self.Turning = true
  Log.Debug("BubbleComponent:TurnTo Start", self:GetOwnerName())
  Owner:AddEventListener(self, NPCModuleEvent.TURN_END, self.LoadSkill)
  TurnComp:StartTurn_S(Rot.Yaw, YawDiff / 360, true)
end

function BubbleComponent:LoadSkill()
  local Owner = self:GetOwner()
  Owner:RemoveEventListener(self, NPCModuleEvent.TURN_END, self.LoadSkill)
  local Path = self:GetClassPath(self.Type)
  if string.IsNilOrEmpty(Path) then
    self:FireFinishCallback(false)
    return
  end
  self.PlayingSkill = true
  Path = _G.NRCUtils.FormatBlueprintAssetPath(Path)
  local Request = _G.NRCResourceManager:LoadResAsync(self, Path, 0, 0, self.RunSkill, self.OnFailed)
  self.Requests[Request] = self.Type
end

function BubbleComponent:OnFailed(Request)
  if Request then
    _G.NRCResourceManager:UnLoadRes(Request)
    self.Requests[Request] = nil
  end
  self.PlayingSkill = nil
  self:FireFinishCallback(false)
end

function BubbleComponent:RunSkill(Request, Klass)
  self.Requests[Request] = nil
  Log.Debug("BubbleComponent:TurnTo End", self:GetOwnerName())
  self.Turning = false
  local View = self:GetOwnerView()
  if not View then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
    return
  end
  local SkillComp = self:GetSkillComponent()
  if not SkillComp then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
    return
  end
  if not Klass then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
    return
  end
  local Skill = SkillComp:FindOrAddSkillObj(Klass)
  if not Skill then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
    return
  end
  if not UE.UObject.IsValid(Skill) then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
    return
  end
  if not Skill.SetCaster then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
    return
  end
  Skill:SetCaster(View)
  Skill:SetPassive(true)
  if SkillComp:IsPassiveActive(Skill) then
    SkillComp:CancelSkill(Skill, UE.ESkillActionResult.SkillActionResultSuccessful)
  end
  if self:IsLoop(self.Type) then
    local Blackboard = Skill.Blackboard
    if Blackboard then
      Blackboard:SetValueAsInt("Continue", -1)
    else
      Log.Error("Can't find blackboard")
    end
    local Result = SkillComp:LoadAndPlaySkill(Skill)
    if Result == UE.ESkillStartResult.Success then
      self.PlayingSkill = nil
      self.RunningSkills[self.Type] = Skill
      self.ClassCaches[self.Type] = Klass
      self:FireFinishCallback(true)
    else
      self:FireFinishCallback(false)
    end
  else
    local Result = SkillComp:LoadAndPlaySkill(Skill)
    if Result == UE.ESkillStartResult.Success then
      Log.Debug("BubbleComponent:RunSkill Start", self:GetOwnerName())
      Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
      Skill:RegisterEventCallback("PreEnd", self, self.OnSkillComplete)
      Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillComplete)
      Skill:RegisterEventCallback("Interrupt", self, self.OnSkillInterrupted)
      self.PlayingSkill = Skill
      self.RunningSkills[self.Type] = Skill
      self.ClassCaches[self.Type] = Klass
    else
      self:FireFinishCallback(false)
    end
  end
end

function BubbleComponent:OnSkillComplete(EventName, Skill)
  Log.Debug("BubbleComponent:OnSkillComplete", self:GetOwnerName(), EventName, Skill == self.PlayingSkill)
  table.removeValue(self.RunningSkills, Skill)
  if Skill == self.PlayingSkill then
    self.PlayingSkill = nil
    self:FireFinishCallback(true)
  end
end

function BubbleComponent:OnSkillInterrupted(EventName, Skill)
  Log.Debug("BubbleComponent:OnSkillInterrupted", self:GetOwnerName(), EventName, Skill == self.PlayingSkill)
  table.removeValue(self.RunningSkills, Skill)
  if Skill == self.PlayingSkill then
    self.PlayingSkill = nil
    self:FireFinishCallback(false)
  end
end

function BubbleComponent:Emit(Owner, Func, Success, ...)
  if not Func then
    return
  end
  if Owner then
    Func(Owner, Success, ...)
  else
    Func(Success, ...)
  end
end

function BubbleComponent:FireFinishCallback(Success)
  local Owner = self.FinishCallbackOwner
  local Func = self.FinishCallbackFunc
  local Payload = self.FinishCallbackPayload
  self.FinishCallbackOwner = nil
  self.FinishCallbackFunc = nil
  self.FinishCallbackPayload = nil
  if not Func then
    return
  end
  self:Emit(Owner, Func, Success, table.unpack(Payload))
end

function BubbleComponent:GetSkillComponent()
  local View = self:GetOwnerView()
  if not View then
    return
  end
  if not UE.UObject.IsValid(View) then
    return
  end
  return View.RocoSkill
end

function BubbleComponent:GetClassPath(Type)
  if type(Type) == "string" then
    return Type
  end
  if 0 == Type then
    return ""
  end
  local Conf = _G.DataConfigManager:GetEmotionConf(Type)
  if not Conf then
    return nil
  end
  return Conf.action_res
end

function BubbleComponent:IsLoop(Type)
  if type(Type) == "string" then
    return false
  end
  if 0 == Type then
    return false
  end
  local Conf = _G.DataConfigManager:GetEmotionConf(Type)
  if not Conf then
    return false
  end
  return Conf.loop == true
end

function BubbleComponent:GetOwnerName()
  if self.owner and self.owner.DebugNPCNameAndID then
    return self.owner:DebugNPCNameAndID()
  else
    return "Owner Not Found"
  end
end

return BubbleComponent
