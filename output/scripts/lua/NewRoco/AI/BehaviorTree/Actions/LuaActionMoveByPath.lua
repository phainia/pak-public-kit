local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionMoveByPath = Base:Extend("LuaActionMoveByPath")

function LuaActionMoveByPath:OnStart(AIController, ...)
  local owner = AIController
  local pointsetId = self.PointsetId:GetValue(owner)
  local areaConf = _G.DataConfigManager:GetAreaConf(pointsetId)
  if not areaConf then
    return self:Finish(false)
  end
  local Path = UE.UNRCStatics.FillArrayByAreaConf(areaConf)
  local Speed = self.Speed:GetValue(owner)
  owner.Npc:SetSpeed(Speed)
  local MovementMode = self.Movement:GetValue(owner)
  local Model = owner.Npc.viewObj
  if Model and Model.CharacterMovement then
    Model.CharacterMovement:SetOverridenMoveAnim(MovementMode)
  end
  local UseNavmesh = self.UseNavmesh:GetValue(owner)
  local AcceptRadius = self.AcceptRadius:GetValue(owner)
  local PartialAcceptRadius = self.PartialAcceptRadius:GetValue(owner)
  local multiPosComp = owner:GetComponentByClass(UE.URocoMultiposFlowComponent)
  if not multiPosComp then
    return self:Finish(false)
  end
  multiPosComp:SetFollowingType(UE.EMultiPosFollowingType.Movement)
  multiPosComp:SetMoveParameters(AcceptRadius, PartialAcceptRadius, true, UseNavmesh, true, UseNavmesh, true)
  local success = multiPosComp:MoveToMultiPoints(Path)
  if not success then
    return self:Finish(false)
  end
  self.controller = owner
  self._onSucc = self.controller:AddDelegateListener(multiPosComp.OnSuccess, self, self.OnSuccess)
  self._onFail = self.controller:AddDelegateListener(multiPosComp.OnFail, self, self.OnFail)
end

function LuaActionMoveByPath:OnSuccess(MovementResult)
  self:CleanUp()
  self:Finish(true)
end

function LuaActionMoveByPath:OnFail(MovementResult)
  self:CleanUp()
  self:Finish(false)
end

function LuaActionMoveByPath:OnInterrupt(AIController, Finalizing, ...)
  if Finalizing then
    self._onSucc = nil
    self._onFail = nil
    self.controller = nil
    return
  end
  local owner = AIController
  local multiPosComp = owner:GetComponentByClass(UE.URocoMultiposFlowComponent)
  if multiPosComp then
    multiPosComp:AbortMove()
  else
    owner:StopMovement()
  end
  self:OnFail(nil)
end

function LuaActionMoveByPath:CleanUp()
  if self.controller then
    local multiPosComp = self.controller:GetComponentByClass(UE.URocoMultiposFlowComponent)
    if multiPosComp then
      self.controller:RemoveDelegateListener(multiPosComp.OnSuccess, self._onSucc)
      self.controller:RemoveDelegateListener(multiPosComp.OnFail, self._onFail)
    end
    self._onSucc = nil
    self._onFail = nil
    self.controller = nil
  end
end

return LuaActionMoveByPath
