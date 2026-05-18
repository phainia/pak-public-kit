local Base = require("NewRoco.Modules.Core.Scene.Component.RidePet.PassiveSkill_EnvBase")
local RidePetEvent = require("NewRoco.Modules.Core.Scene.Component.RidePet.RidePetEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local PassiveSkill_Terrain = Base:Extend("PassiveSkill_Terrain")

function PassiveSkill_Terrain:Ctor(owner, config)
  Base.Ctor(self, owner, config)
end

function PassiveSkill_Terrain:Start()
  self.bStarted = true
  self.isLocal = self.owner.owner.isLocal
  local handle = self.isLocal and self.OnRideMoveMode or self.RemotePlayerRideMoveMode
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_RIDE_MOVE_MODE_CHANGE, handle)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_RIDEPET_TALENT_CHANGE_POST, handle)
  self.CurTickTime = 0
  _G.UpdateManager:Register(self)
end

function PassiveSkill_Terrain:RemotePlayerRideMoveMode()
  if not self:CheckCondition() then
    self:StopCommonEffect()
  end
end

function PassiveSkill_Terrain:TryPlayEffect()
  if self.bStarted then
    local ridePet = self.owner.viewObj
    if ridePet then
      local surface = ridePet:GetSurface()
      if self:CheckCondition() then
        Base.TryPlayEffect(self, surface)
      end
      ridePet:AddEventListener(self, RidePetEvent.ON_SURFACE_CHANGE, self.RemotePlayerOnSurfaceChane)
    else
      self:Stop()
    end
  end
end

function PassiveSkill_Terrain:RemotePlayerOnSurfaceChane(newSurface, oldSurface)
  if not self.bStarted then
    return
  end
  if self:CheckCondition() then
    Base.TryPlayEffect(self, newSurface)
  end
end

function PassiveSkill_Terrain:OnSetViewObj()
  if self.bStarted then
    local ridePet = self.owner.viewObj
    if ridePet then
      local surface = ridePet:GetSurface()
      self:AddEnvBuff(surface)
      ridePet:AddEventListener(self, RidePetEvent.ON_SURFACE_CHANGE, self.OnSurfaceChane)
      self.CharacterMovement = self.owner.viewObj and self.owner.viewObj:GetComponentByClass(UE4.UCharacterMovementProxy)
    else
      self:Stop()
    end
  end
end

function PassiveSkill_Terrain:OnSurfaceChane(newSurface, oldSurface)
  if not self.bStarted then
    return
  end
  self:AddEnvBuff(newSurface)
end

function PassiveSkill_Terrain:AddEnvBuff(envType)
  if self:CheckCondition() then
    Base.AddEnvBuff(self, envType)
  else
    self:RemoveEnvBuff()
  end
end

function PassiveSkill_Terrain:OnRideMoveMode()
  if not self:CheckCondition() then
    self:RemoveEnvBuff()
  else
    self._delayId = _G.DelayManager:DelayFrames(1, function()
      self._delayId = nil
      if self.owner and table.isEmpty(self._stat_ids) and UE.UObject.IsValid(self.owner.viewObj) then
        local surface = self.owner.viewObj:GetSurface()
        Base.AddEnvBuff(self, surface)
      end
    end)
  end
end

function PassiveSkill_Terrain:Stop()
  if self._delayId then
    _G.DelayManager:CancelDelayById(self._delayId)
    self._delayId = nil
  end
  self.bStarted = false
  self:RemoveEnvBuff()
  local ridePet = self.owner.viewObj
  if ridePet then
    local handle = self.isLocal and self.OnSurfaceChane or self.RemotePlayerOnSurfaceChane
    ridePet:RemoveEventListener(self, RidePetEvent.ON_SURFACE_CHANGE, handle)
  end
  local moveHandle = self.isLocal and self.OnRideMoveMode or self.RemotePlayerRideMoveMode
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_RIDE_MOVE_MODE_CHANGE, moveHandle)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_RIDEPET_TALENT_CHANGE_POST, moveHandle)
  _G.UpdateManager:UnRegister(self)
end

function PassiveSkill_Terrain:PlayCommonEffect()
  local RidePet = self.owner.viewObj
  if RidePet then
    if not self.TerrainFxs then
      self.TerrainFxs = UE4.TArray(UE4.AActor)
    end
    RidePet.RocoMoveFx:LuaPlayMoveFxByStatus("PassiveSkill_Terrain", self.TerrainFxs)
    self.bFxVisual = true
  end
end

function PassiveSkill_Terrain:StopCommonEffect()
  local RidePet = self.owner.viewObj
  if UE.UObject.IsValid(RidePet) and self.TerrainFxs then
    for i, fx in ipairs(self.TerrainFxs:ToTable()) do
      RidePet.RocoMoveFx:LuaStopMoveFx(fx, 0)
    end
    self.TerrainFxs:Clear()
    self.TerrainFxs = nil
  end
  Base.StopCommonEffect(self)
end

function PassiveSkill_Terrain:OnTick(DeltaTime)
  self.CurTickTime = self.CurTickTime + DeltaTime
  if self.CurTickTime < 0.5 then
    return
  end
  self.CurTickTime = 0
  if self.TerrainFxs and self.CharacterMovement then
    local bFxVisual = not self.CharacterMovement.Velocity:IsNearlyZero(0)
    if bFxVisual ~= self.bFxVisual then
      for i, fx in ipairs(self.TerrainFxs:ToTable()) do
        fx:SetActorHiddenInGame(self.bFxVisual)
      end
      self.bFxVisual = bFxVisual
    end
  end
end

function PassiveSkill_Terrain:CheckCondition()
  local RidePet = self.owner
  if RidePet.TalentEffectMap[Enum.PetTalentEffect.PTE_TERRAIN] and RidePet.viewObj and RidePet.viewObj.CharacterMovement:IsMovingOnGround() then
    return true
  end
  return false
end

return PassiveSkill_Terrain
