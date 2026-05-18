local EnvLightProxy = Class("EnvLightProxy")

function EnvLightProxy:Ctor(Actor, RoomId)
  self.Actor = Actor
  self.RoomId = RoomId
  self:CollectDefault()
end

function EnvLightProxy:CollectDefault()
  HomeIndoorSandbox:LogWarn("EnvLightProxy", self, self.Actor)
  if not HomeIndoorSandbox:Ensure(self.Actor and UE.UObject.IsValid(self.Actor), "logical error", self.Actor) then
    return
  end
  local Location = self.Actor:Abs_K2_GetActorLocation()
  local Rotation = self.Actor:K2_GetActorRotation()
  local LightColor = self.Actor:GetLightColor()
  self._LightComponent = self.Actor:GetComponentByClass(UE.ULightComponentBase)
  self.DefaultConfig = {
    Location = UE.FVector(Location.X, Location.Y, Location.Z),
    Rotation = UE.FRotator(Rotation.Pitch, Rotation.Yaw, Rotation.Roll),
    LightColor = UE.FColor(LightColor.R, LightColor.G, LightColor.B, LightColor.A),
    Intensity = self.Actor:GetIntensity(),
    AttenuationRadius = self.Actor:GetAttenuationRadius(),
    InnerConeAngle = self.Actor:GetInnerConeAngle(),
    OuterConeAngle = self.Actor:GetOuterConeAngle()
  }
end

function EnvLightProxy:SetActorHiddenInGame(bHidden)
  self.bHidden = bHidden
  if HomeIndoorSandbox:Ensure(self.Actor and UE.UObject.IsValid(self.Actor), "logical error", self.Actor) then
    self:UpdateVisibility()
  end
end

function EnvLightProxy:UpdateVisibility()
  local bVisible = not self.bHidden and (not self:IsThemeLight() or self:IsThemeActivated())
  self.Actor:SetActorHiddenInGame(not bVisible)
  self.Actor.Config.bActive = bVisible
  if self._LightComponent then
    self._LightComponent:SetVisibility(bVisible)
  end
end

function EnvLightProxy:ApplyLightSetting(LightParam)
  if HomeIndoorSandbox:Ensure(self.Actor and UE.UObject.IsValid(self.Actor), "logical error", self.Actor) then
    self.Actor:Abs_K2_SetActorLocation(LightParam and LightParam.Location or self.DefaultConfig.Location, false, nil, false)
    self.Actor:K2_SetActorRotation(LightParam and LightParam.Rotation or self.DefaultConfig.Rotation, false)
    self.Actor:SetLightColor(LightParam and LightParam.LightColor or self.DefaultConfig.LightColor)
    self.Actor:SetIntensity(LightParam and LightParam.Intensity or self.DefaultConfig.Intensity)
    self.Actor:SetAttenuationRadius(LightParam and LightParam.AttenuationRadius or self.DefaultConfig.AttenuationRadius)
    self.Actor:SetInnerConeAngle(LightParam and LightParam.InnerConeAngle or self.DefaultConfig.InnerConeAngle)
    self.Actor:SetOuterConeAngle(LightParam and LightParam.OuterConeAngle or self.DefaultConfig.OuterConeAngle)
    self:UpdateVisibility()
  end
end

function EnvLightProxy:InternalTryParseThemeLightIndex()
  if not self._bThemeLightInfoParsed then
    for _, Tag in tpairs(self.Actor.Tags) do
      local num = Tag:lower():match("^space_(%d+)$")
      if num then
        self._ThemeLightId = tonumber(num)
      end
    end
    self._bThemeLightInfoParsed = true
  end
end

function EnvLightProxy:IsThemeActivated()
  return self._ThemeActivated
end

function EnvLightProxy:SetThemeActivated(bActivated)
  self._ThemeActivated = bActivated
  self:UpdateVisibility()
end

function EnvLightProxy:IsThemeLight()
  self:InternalTryParseThemeLightIndex()
  return (self._ThemeLightId or 0) > 5
end

function EnvLightProxy:GetThemeLightUniqueVisualRoomId()
  self:InternalTryParseThemeLightIndex()
  return self._ThemeLightId or 0
end

return EnvLightProxy
