local M = Class("StaticMeshProxy")

function M:OnInit(Actor, MeshComponent)
  self.HardStaticActor = Actor
  self.MeshComponent = MeshComponent
  self.MeshRequest = nil
  self.MaterialRequests = {}
  self.FinishMaterials = {}
  self.FinishMaterialRefs = {}
  self.FinishMesh = nil
  self.FinishMeshRef = nil
  if MeshComponent then
    MeshComponent:SetMobility(UE.EComponentMobility.Movable)
    self.OriginalMeshPath = UE.UNRCStatics.GetSoftObjPath(MeshComponent.SoftStaticMesh) or ""
    if self.OriginalMeshPath == "" then
      self.OriginalMeshPath = UE.UNRCStatics.GetSoftObjPath(MeshComponent.StaticMesh)
    end
    self.OriginalMaterialPaths = {}
    local Num = MeshComponent:GetNumMaterials()
    for i = 1, Num do
      local Material = MeshComponent:GetMaterial(i - 1)
      local Path = Material and UE.UKismetSystemLibrary.GetPathName(Material) or ""
      self.OriginalMaterialPaths[i] = Path
    end
    for i, Material in tpairs(MeshComponent.SoftOverrideMaterials) do
      local Path = UE.UNRCStatics.GetSoftObjPath(Material) or self.OriginalMaterialPaths[i] or ""
      self.OriginalMaterialPaths[i] = Path
    end
  end
end

function M:SetFinishDelegate(Delegate)
  self.FinishDelegate = Delegate
end

function M:StartLoadResources()
  if not self.MeshComponent then
    return
  end
  self:StopLoadResources()
  if self.OriginalMeshPath ~= "" then
    self.MeshRequest = NRCResourceManager:LoadResAsync(self, self.OriginalMeshPath, 255, 0, self.OnMeshLoaded, self.OnMeshLoadedFailed, nil, FPartial(self.OnMeshUnloaded, self))
  else
    HomeIndoorSandbox:Ensure(false, "empty static mesh", self.HardStaticActor:GetName(), self.HardStaticActor:GetActorId())
    return
  end
  for i, MaterialPath in ipairs(self.OriginalMaterialPaths) do
    if "" ~= MaterialPath then
      self.MaterialRequests[i] = NRCResourceManager:LoadResAsync(self, MaterialPath, 254, 0, FPartial(self.OnMaterialLoaded, self, i), FPartial(self.OnMaterialLoadedFailed, self, i), nil, FPartial(self.OnMaterialUnLoad, self, i))
    end
  end
end

function M:OnMeshLoaded(resRequest, asset)
  self.MeshRequest = nil
  self.FinishMesh = asset
  self.FinishMeshRef = asset and UnLua.Ref(asset)
  HomeIndoorSandbox:Ensure(asset, "logical error")
  self:TryFinishDecorate()
end

function M:OnMeshLoadedFailed(resRequest, errMsg)
  self.MeshRequest = nil
  HomeIndoorSandbox:Ensure(false, "mesh load failed:", errMsg, resRequest.assetPath)
  self:TryFinishDecorate()
end

function M:OnMeshUnloaded()
  self.MeshRequest = nil
  self:TryFinishDecorate()
end

function M:OnMaterialLoaded(i, _, resRequest, asset)
  self.FinishMaterials[i] = asset
  self.FinishMaterialRefs[i] = UnLua.Ref(asset)
  self.MaterialRequests[i] = nil
  self:TryFinishDecorate()
end

function M:OnMaterialLoadedFailed(i, _, resRequest, errMsg)
  self.MaterialRequests[i] = nil
  HomeIndoorSandbox:Ensure(false, "material load failed:", errMsg, resRequest.assetPath)
  self:TryFinishDecorate()
end

function M:OnMaterialUnLoad(i)
  self.MaterialRequests[i] = nil
  self:TryFinishDecorate()
end

function M:TryFinishDecorate()
  if next(self.MaterialRequests) then
    return
  end
  if self.MeshRequest then
    return
  end
  if self.FinishMesh and UE.UObject.IsValid(self.MeshComponent) then
    self.MeshComponent:SetMobility(UE.EComponentMobility.Movable)
    self.MeshComponent:SetStaticMesh(self.FinishMesh)
    for i, mat in pairs(self.FinishMaterials) do
      self.MeshComponent:SetMaterial(i - 1, mat)
    end
  end
  if self.FinishDelegate then
    self.FinishDelegate()
  end
end

function M:StartLoadResourceByPath(MeshPath, MaterialPathArray)
  if not self.MeshComponent then
    return
  end
  self:StopLoadResources()
  if "" ~= MeshPath then
    self.MeshRequest = NRCResourceManager:LoadResAsync(self, MeshPath, 255, 0, self.OnMeshLoaded, self.OnMeshLoadedFailed, nil, FPartial(self.OnMeshUnloaded, self))
  else
    HomeIndoorSandbox:Ensure(false, "empty static mesh", self.HardStaticActor:GetName(), self.HardStaticActor:GetActorId())
  end
  for i, MaterialPath in tpairs(MaterialPathArray) do
    if "" ~= MaterialPath then
      self.MaterialRequests[i] = NRCResourceManager:LoadResAsync(self, MaterialPath, 254, 0, FPartial(self.OnMaterialLoaded, self, i), FPartial(self.OnMaterialLoadedFailed, self, i), nil, FPartial(self.OnMaterialUnLoad, self, i))
    end
  end
end

function M:SyncLoadMesh()
  if not self.MeshComponent then
    return
  end
  self:StopLoadResources()
  if self.OriginalMeshPath ~= "" then
    self:OnMeshLoaded(nil, UE.UObject.Load(self.OriginalMeshPath))
  end
end

function M:SyncLoadResources()
  if not self.MeshComponent then
    return
  end
  self:StopLoadResources()
  if self.OriginalMeshPath ~= "" then
    self:OnMeshLoaded(nil, UE.UObject.Load(self.OriginalMeshPath))
  else
    HomeIndoorSandbox:Ensure(false, "empty static mesh", self.HardStaticActor:GetName(), self.HardStaticActor:GetActorId())
  end
  for i, MaterialPath in ipairs(self.OriginalMaterialPaths) do
    if "" ~= MaterialPath then
      self:OnMaterialLoaded(i, nil, nil, UE.UObject.Load(MaterialPath))
    end
  end
end

function M:StopLoadResources()
  if self.MeshRequest then
    NRCResourceManager:UnLoadRes(self.MeshRequest)
    self.MeshRequest = nil
  end
  for k, v in pairs(self.MaterialRequests) do
    NRCResourceManager:UnLoadRes(v)
    self.MaterialRequests[k] = nil
  end
  self.FinishMeshRef = nil
  self.FinishMesh = nil
  self.FinishMaterials = {}
  self.FinishMaterialRefs = {}
end

function M:HasMesh()
  return self.MeshComponent and self.MeshComponent.StaticMesh
end

function M:OnRelease()
  self:StopLoadResources()
  self.HardStaticActor = nil
  self.MeshComponent = nil
end

return M
