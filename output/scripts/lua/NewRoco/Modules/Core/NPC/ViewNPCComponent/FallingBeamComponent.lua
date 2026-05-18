local Class = _G.MakeSimpleClass
local SpawnEmitterAtLocation = UE4.UNiagaraFunctionLibrary.SpawnSystemAtLocation
local FallingBeamComponent = Class("FallingBeamComponent")
FallingBeamComponent:SetMemberCount(3)

function FallingBeamComponent:PreCtor(model)
  self.showing = false
  self.model = model
  self.hasLoaded = false
end

function FallingBeamComponent:Ctor(model)
end

function FallingBeamComponent:Create()
  if self.showing then
    return self.Comp
  end
  self.showing = true
  local model = self.model
  local config = model.sceneCharacter.config
  local quality = config.item_quality
  if not quality or 0 == quality then
    self:Destroy()
    return nil
  end
  self.hasLoaded = model.resourceLoaded
  local fx = _G.NRCBigWorldPreloader:Get(string.format("Quality%d", quality))
  if not fx then
    self:Destroy()
    return nil
  end
  local location = model:K2_GetRootComponent():GetSocketLocation("Fx_01")
  local rotation = _G.FRotatorZero
  local scale = _G.FVectorOne
  self.Comp = SpawnEmitterAtLocation(model, fx, location, rotation, scale, false, true, UE.EPSCPoolMethod.None, false)
  return self.Comp
end

function FallingBeamComponent:Toggle(Enable)
  if not UE4.UObject.IsValid(self.Comp) then
    return
  end
  self.Comp:SetVisibility(Enable)
  self.Comp:SetActive(Enable, false)
  if Enable and not self.hasLoaded and self.model.resourceLoaded and self.model then
    local location = self.model:K2_GetRootComponent():GetSocketLocation("Fx_01")
    self.Comp:K2_SetWorldLocation(location, false, nil, false)
    self.hasLoaded = self.model.resourceLoaded
  end
end

function FallingBeamComponent:Show()
  self:Toggle(true)
end

function FallingBeamComponent:Hide()
  self:Toggle(false)
end

function FallingBeamComponent:SetLocation(Pos)
  if not UE4.UObject.IsValid(self.Comp) then
    return
  end
  if not UE.UObject.IsValid(self.Comp) then
    return
  end
  self.Comp:Abs_K2_SetWorldLocation(Pos, false, nil, false)
end

function FallingBeamComponent:Destroy()
  if not UE4.UObject.IsValid(self.Comp) then
    return
  end
  if UE.UObject.IsValid(self.Comp) then
    self.Comp:K2_DestroyComponent(self.Comp)
  end
  self.Comp = nil
end

return FallingBeamComponent
