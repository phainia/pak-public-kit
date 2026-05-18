local PostProcessFilter = Class("PostProcessFilter")

function PostProcessFilter:Ctor()
  self.FilterPath = ""
  self.FilterAssetRequest = nil
  self.FilterAsset = nil
  self.FilterAssetRef = nil
end

function PostProcessFilter:Destroy()
  if self.FilterAssetRequest then
    NRCResourceManager:UnLoadRes(self.FilterAssetRequest)
    self.FilterAssetRequest = nil
  end
  self:InternalRemoveFilter(self.FilterAsset)
end

function PostProcessFilter:GetEnvActor()
  local EnvSys = self:GetEnvSubSystem()
  if EnvSys then
    local CurEnvActor = EnvSys:GetEnvActor()
    return CurEnvActor
  end
end

function PostProcessFilter:GetEnvSubSystem()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  return EnvSys
end

function PostProcessFilter:UnBindBlendProgress()
  if self.BlendProgress then
    self.BlendProgress:UnBind()
    self.BlendProgress = nil
  end
end

function PostProcessFilter:OnBlendProgressChanged(Value)
  self:InternalRefreshBlend()
end

function PostProcessFilter:InternalRefreshBlend()
  if self.FilterAsset and UE.UObject.IsValid(self.FilterAsset) and self.FilterAsset.PostProcessMaterial then
    local EvnActor = self:GetEnvActor()
    if EvnActor then
      self:OnUpdateBlend(EvnActor)
    end
  end
end

function PostProcessFilter:SetupFilterParamCollection(Collection)
  self.FilterParamCollection = Collection
end

function PostProcessFilter:OnUpdateBlend(EvnActor)
  local BlendValue = self.BlendProgress and self.BlendProgress:GetValue() or 1.0
  UE.UNRCStatics.PostProcessAddOrUpdateBlendable(EvnActor.PostProcess, self.FilterAsset.PostProcessMaterial, 1)
  if self.FilterParamCollection and UE.UObject.IsValid(self.FilterParamCollection) then
    UE.UKismetMaterialLibrary.SetScalarParameterValue(UE4Helper.GetCurrentWorld(), self.FilterParamCollection, "UI_Filter_BlendInt", math.clamp(BlendValue, 0, 1))
  end
end

function PostProcessFilter:SetFilterBlendProgress(Progress)
  self:UnBindBlendProgress()
  self.BlendProgress = Progress
  self.BlendProgress.OnValueChanged:Add(self, self.OnBlendProgressChanged)
  self:InternalRefreshBlend()
end

function PostProcessFilter:SetFilterPath(Path)
  if self.FilterPath == Path then
    return
  end
  if self.FilterAssetRequest then
    NRCResourceManager:UnLoadRes(self.FilterAssetRequest)
    self.FilterAssetRequest = nil
  end
  self:InternalRemoveFilter()
  self.FilterPath = Path
  if Path and "" ~= Path then
    self.FilterAssetRequest = NRCResourceManager:LoadResAsync(self, Path, 255, -1, self.OnLoaded)
  end
end

function PostProcessFilter:OnLoaded(Request, Asset)
  self.FilterAssetRequest = nil
  if Asset then
    self.FilterAsset = Asset
    self.FilterAssetRef = UnLua.Ref(Asset)
    self:InternalUpdateFilter()
  end
end

function PostProcessFilter:InternalUpdateFilter()
  if self.FilterAsset and UE.UObject.IsValid(self.FilterAsset) then
    local EvnActor = self:GetEnvActor()
    if EvnActor then
      local System = self:GetEnvSubSystem()
      if System then
        System:SetNewEnvtEnvSystemFilterData(self.FilterAsset)
      end
      Log.Debug("PostProcess AddOrUpdateBlendable", self.FilterAsset:GetName(), "material:", self.FilterAsset.PostProcessMaterial and self.FilterAsset.PostProcessMaterial:GetName())
      if self.FilterAsset.PostProcessMaterial then
        self:OnUpdateBlend(EvnActor)
      end
    end
  end
end

function PostProcessFilter:InternalRemoveFilter()
  if self.FilterAsset and UE.UObject.IsValid(self.FilterAsset) then
    local EvnActor = self:GetEnvActor()
    if EvnActor then
      local System = self:GetEnvSubSystem()
      if System then
        System:SetNewEnvtEnvSystemFilterData(nil)
      end
      Log.Debug("PostProcess RemoveBlendable", self.FilterAsset:GetName(), "material:", self.FilterAsset.PostProcessMaterial and self.FilterAsset.PostProcessMaterial:GetName())
      if self.FilterAsset.PostProcessMaterial then
        UE.UNRCStatics.PostProcessRemoveBlendable(EvnActor.PostProcess, self.FilterAsset.PostProcessMaterial)
      end
    end
    UnLua.Unref(self.FilterAsset)
    self.FilterAsset = nil
    self.FilterAssetRef = nil
    self.FilterPath = nil
  end
end

return PostProcessFilter
