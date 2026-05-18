local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenActionBase")
local HiddenPluginFx = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginFx")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local SkillPath_Ele_Idle = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Ele_Idle.Pet_Hide_Ele_Idle_C'"
local SkillPath_Ele_Alpha = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Ele_Alpha.Pet_Hide_Ele_Alpha_C"
local SkillPath_Ele_End = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Ele_End"
local FxPath_Ele_Idle = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/Hide/NS_Ele_701101_SDB_Hide01.NS_Ele_701101_SDB_Hide01'"
local FxPath_Ele_Move = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/Hide/NR_Hide_Ele.NR_Hide_Ele'"
local IdleFxDelayTime = 3
local HiddenActionThunderrush = Base:Extend("HiddenActionThunderrush")
HiddenActionThunderrush.EleState = {Idle = 1, Alpha = 2}
HiddenActionThunderrush.EleState2SkillPath = {
  [HiddenActionThunderrush.EleState.Idle] = SkillPath_Ele_Idle,
  [HiddenActionThunderrush.EleState.Alpha] = SkillPath_Ele_Alpha
}

function HiddenActionThunderrush:Ctor()
  local prio = _G.PriorityEnum.Passive_World_NPC_Hidden_Other
  self.idleFx = HiddenPluginFx(FxPath_Ele_Idle, true, true, prio)
  self.moveFx = HiddenPluginFx(FxPath_Ele_Move, true, true, prio)
end

function HiddenActionThunderrush:Init(comp)
  Base.Init(self, comp)
  self.idleFx:Init(comp.owner)
  self.moveFx:Init(comp.owner)
  if HomeIndoorSandbox and HomeIndoorSandbox:InHomeIndoor() then
  else
    self.owner.DisappearSkillPath = SkillPath_Ele_End
    self.owner.bDisappearPerform = false
  end
  self.SkillRequests = {}
  self.currentState = self.EleState.Idle
  self.d_DelayRemoveFx = nil
end

function HiddenActionThunderrush:Release()
  if self.d_DelayRemoveFx then
    _G.DelayManager:CancelDelayById(self.d_DelayRemoveFx)
  end
  self:ReleaseSkillReq()
  self.idleFx:Release()
  self.moveFx:Release()
  Base.Release(self)
end

function HiddenActionThunderrush:OnHidden()
  self:SwitchState(self.EleState.Alpha)
  self:UpdateMoveParam(false)
  self.moveFx:Show()
  self.comp:EnterHidden(_G.AIDefines.ActionResult.Success)
end

function HiddenActionThunderrush:AssureHidden(imme)
  self:UpdateMoveParam(false)
  self.moveFx:Show()
  self:SwitchState(self.EleState.Alpha)
end

function HiddenActionThunderrush:OnUnhidden()
  self:UpdateMoveParam(true)
  self.moveFx:UnShow()
  self.idleFx:Show()
  self:SwitchState(self.EleState.Idle)
  if self.d_DelayRemoveFx then
    _G.DelayManager:CancelDelayById(self.d_DelayRemoveFx)
  end
  self.d_DelayRemoveFx = _G.DelayManager:DelaySeconds(IdleFxDelayTime, function()
    self.idleFx:UnShow()
    self.d_DelayRemoveFx = nil
  end)
  self.comp:FinalizeHidden(_G.AIDefines.ActionResult.Success)
end

function HiddenActionThunderrush:AssureUnhidden(imme, remove)
  if not remove then
    self:UpdateMoveParam(true)
    self:SwitchState(self.EleState.Idle)
  end
  self.moveFx:UnShow()
end

function HiddenActionThunderrush:EnablePinToGround()
  return false
end

function HiddenActionThunderrush:SwitchState(newState)
  if self.currentState == newState then
    return
  end
  self.currentState = newState
  _G.NRCResourceManager:LoadResAsync(self, self.EleState2SkillPath[newState], _G.PriorityEnum.Passive_World_NPC_Hidden_Other, 10, self.SwitchStateLoadSucc, self.SwitchStateLoadFail)
end

function HiddenActionThunderrush:SwitchStateLoadSucc(req, skillClass)
  self.SkillRequests[self.currentState] = req
  if not self.owner then
    self:ReleaseSkillReq()
    return
  end
  local Model = self.owner.viewObj
  if Model and UE.UObject.IsValid(Model) then
    local RocoSkill = Model.RocoSkill
    local skillObj = RocoSkill:FindOrAddSkillObj(skillClass)
    skillObj:SetCaster(Model)
    skillObj:SetTargets({Model})
    skillObj:SetPassive(true)
    skillObj:ClearDelegates()
    skillObj:RegisterEventCallback("End", self, self.SkillEnd)
    skillObj:RegisterEventCallback("PreEnd", self, self.SkillEnd)
    skillObj:RegisterEventCallback("Interrupt", self, self.SkillEnd)
    local result = RocoSkill:PlaySkill(skillObj)
    if result ~= UE.ESkillStartResult.Success then
      self:SkillEnd()
    end
  else
    self:SkillEnd()
  end
end

function HiddenActionThunderrush:SkillEnd()
  self:ReleaseSkillReq(self.currentState)
end

function HiddenActionThunderrush:SwitchStateLoadFail(req, errMsg)
end

function HiddenActionThunderrush:UpdateMoveParam(default)
  local model = self.owner.viewObj
  if model then
    local moveComp = model.GetMovementComponent and model:GetMovementComponent()
    if moveComp then
      moveComp.bRequestedMoveUseAcceleration = default
    end
  end
  if self.owner.config.genre == Enum.ClientNpcType.CNT_PETBOSS then
    if default then
      self.owner:SetCollisionDisable(false, 4)
      self.owner:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(false, true, false)
    else
      self.owner:SetCollisionDisable(true, 4)
    end
  end
end

function HiddenActionThunderrush:ReleaseSkillReq(spec)
  local skill_stopped = false
  
  local function stopSkill()
    if not skill_stopped then
      local Model = self.owner and self.owner.viewObj
      if Model and UE.UObject.IsValid(Model) then
        Model.RocoSkill:StopCurrentSkill()
      end
      skill_stopped = true
    end
  end
  
  if spec then
    local req = self.SkillRequests[spec]
    if nil == req then
      return
    end
    self.SkillRequests[spec] = nil
    stopSkill()
    _G.NRCResourceManager:UnLoadRes(req)
  else
    local res = self.SkillRequests
    self.SkillRequests = {}
    for _, req in pairs(res) do
      stopSkill()
      _G.NRCResourceManager:UnLoadRes(req)
    end
  end
end

return HiddenActionThunderrush
