local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local ESequencePlayState = {
  Hidden = "Hidden",
  Stop = "Stop",
  RunningForward = "RunningForward",
  RunningBackward = "RunningBackward"
}
local BP_ActorSequenceBase_C = Base:Extend("BP_ActorSequenceBase_C")

function BP_ActorSequenceBase_C:Ctor()
  Base.Ctor(self)
  self.CurrSignificanceValue = UE.ESignificanceValue.Unload
  self.CurrPlayState = ESequencePlayState.Stop
end

function BP_ActorSequenceBase_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
end

function BP_ActorSequenceBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_ActorSequenceBase_C:OnSignificanceChanged(SignificanceValue)
  self.CurrSignificanceValue = SignificanceValue
  if self.CurrSignificanceValue >= UE.ESignificanceValue.Hidden then
    self.CurrPlayState = ESequencePlayState.Hidden
  end
end

function BP_ActorSequenceBase_C:OnActorSequenceTrigger(ViewDistance)
  if not self.ActorSequenceComp then
    return
  end
  self.ActorSequenceComp.SequencePlayer:Play()
  self.CurrPlayState = ESequencePlayState.RunningForward
end

function BP_ActorSequenceBase_C:OnActorSequenceStatic(ViewDistance)
  if not self.ActorSequenceComp then
    return
  end
  if self.bPlayReverseSequenceWhenStatic then
    self.ActorSequenceComp.SequencePlayer:PlayReverse()
    self.CurrPlayState = ESequencePlayState.RunningBackward
  else
    self.ActorSequenceComp.SequencePlayer:Stop()
    self.CurrPlayState = ESequencePlayState.Stop
  end
end

function BP_ActorSequenceBase_C:OnSequenceFinished()
  self.CurrPlayState = ESequencePlayState.Stop
end

function BP_ActorSequenceBase_C:GetMeshCompAndTransformByName(MeshCompName, SocketName)
  local FxTransform = self:GetTransform()
  local AttachComp = self:K2_GetRootComponent()
  if not UE.UKismetStringLibrary.IsEmpty(MeshCompName) then
    local Comps = self:K2_GetComponentsByClass(UE.UMeshComponent)
    for _, Comp in tpairs(Comps) do
      if Comp:GetName() == MeshCompName then
        AttachComp = Comp
        FxTransform = Comp:GetSocketTransform(SocketName, UE4.ERelativeTransformSpace.RTS_World)
        break
      end
    end
  end
  return AttachComp, FxTransform
end

function BP_ActorSequenceBase_C:SpawnFXAtLocation(FxSoftObjectPtr, OffsetTransform, SocketOwnerMeshCompName, SocketName)
  if self.CurrSignificanceValue == ESequencePlayState.Stop or self.CurrSignificanceValue == ESequencePlayState.Hidden then
    return
  end
  local FxManager = UE.UFXManager.Get()
  if not FxManager then
    return
  end
  local FxTransform = self:GetTransform()
  _, FxTransform = self:GetMeshCompAndTransformByName(SocketOwnerMeshCompName, SocketName)
  FxTransform = UE.UKismetMathLibrary.ComposeTransforms(OffsetTransform, FxTransform)
  local FxPath = FxSoftObjectPtr:GetLongPackageName()
  FxPath = NRCUtils.FormatResPackageNameToFullPath(FxPath)
  FxManager:SpawnFXAtLocationBySoftPath(FxPath, self, FxTransform)
end

function BP_ActorSequenceBase_C:SpawnFXAttached(FxSoftObjectPtr, SocketOwnerMeshCompName, SocketName)
  if self.CurrSignificanceValue == ESequencePlayState.Stop or self.CurrSignificanceValue == ESequencePlayState.Hidden then
    return
  end
  local FxManager = UE.UFXManager.Get()
  if not FxManager then
    return
  end
  local FxTransform = self:GetTransform()
  local AttachComp = self:K2_GetRootComponent()
  AttachComp, FxTransform = self:GetMeshCompAndTransformByName(SocketOwnerMeshCompName, SocketName)
  local FxPath = FxSoftObjectPtr:GetLongPackageName()
  FxPath = NRCUtils.FormatResPackageNameToFullPath(FxPath)
  local FxParam = UE.FPlayFXParam()
  FxParam.AttachPointName = SocketName
  FxParam.AttachToSocket = true
  FxManager:SpawnFXAttachedBySoftPath(FxPath, FxParam, AttachComp)
end

function BP_ActorSequenceBase_C:ModifyMeshMaterialParamFloat(MeshCompName, ParamIndex, ParamNewValue)
  local MeshComp, _ = self:GetMeshCompAndTransformByName(MeshCompName, "")
  if not MeshComp:IsA(UE.UPrimitiveComponent) then
    return
  end
  MeshComp:SetCustomPrimitiveDataFloat(ParamIndex, ParamNewValue)
end

function BP_ActorSequenceBase_C:ModifyMeshMaterialParamVector(MeshCompName, ParamIndex, ParamNewValue)
  local MeshComp, _ = self:GetMeshCompAndTransformByName(MeshCompName, "")
  if not MeshComp:IsA(UE.UPrimitiveComponent) then
    return
  end
  MeshComp:SetCustomPrimitiveDataVector3(ParamIndex, ParamNewValue)
end

return BP_ActorSequenceBase_C
