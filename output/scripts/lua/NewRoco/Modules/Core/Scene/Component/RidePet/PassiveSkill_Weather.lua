local Base = require("NewRoco.Modules.Core.Scene.Component.RidePet.PassiveSkill_EnvBase")
local EnvSystemModuleEvent = reload("NewRoco.Modules.System.EnvSystem.EnvSystemModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local PassiveSkill_Weather = Base:Extend("PassiveSkill_Weather")

function PassiveSkill_Weather:Ctor(owner, config)
  Base.Ctor(self, owner, config)
end

function PassiveSkill_Weather:Start()
  self.bStarted = true
  self.isLocal = self.owner.owner.isLocal
  local handle = self.isLocal and self.OnRideMoveMode or self.RemotePlayerRideMoveMode
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_RIDE_MOVE_MODE_CHANGE, handle)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_RIDEPET_TALENT_CHANGE_POST, handle)
  self.CurTickTime = 0
  _G.UpdateManager:Register(self)
end

function PassiveSkill_Weather:RemotePlayerRideMoveMode()
  self:Stop()
  self:Start()
  self:TryPlayEffect()
end

function PassiveSkill_Weather:TryPlayEffect()
  if self.bStarted then
    local ridePet = self.owner.viewObj
    if ridePet then
      local envSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")
      local curWeather = envSystem:OnCmdGetCurrentWeatherType()
      if self:CheckCondition() then
        Base.TryPlayEffect(self, curWeather)
      end
      envSystem:RegisterEvent(self, EnvSystemModuleEvent.WeatherChangeEvent, self.RemotePlayerOnWeatherChange)
    else
      self:Stop()
    end
  end
end

function PassiveSkill_Weather:RemotePlayerOnWeatherChange(weather)
  if not self.bStarted or not self:CheckCondition() then
    return
  end
  Base.TryPlayEffect(self, weather)
end

function PassiveSkill_Weather:AddEnvBuff(envType)
  if self:CheckCondition() then
    Base.AddEnvBuff(self, envType)
  end
end

function PassiveSkill_Weather:OnSetViewObj()
  if self.bStarted then
    if self.owner.viewObj then
      local envSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")
      local curWeather = envSystem:OnCmdGetCurrentWeatherType()
      self:AddEnvBuff(curWeather)
      envSystem:RegisterEvent(self, EnvSystemModuleEvent.WeatherChangeEvent, self.OnWeatherChange)
      self.CharacterMovement = self.owner.viewObj and self.owner.viewObj:GetComponentByClass(UE4.UCharacterMovementProxy)
    else
      self:Stop()
    end
  end
end

function PassiveSkill_Weather:OnRideMoveMode()
  self:Stop()
  self:Start()
  self:OnSetViewObj()
end

function PassiveSkill_Weather:OnWeatherChange(weather)
  if not self.bStarted then
    return
  end
  self:AddEnvBuff(weather)
end

function PassiveSkill_Weather:Stop()
  Base.Stop(self)
  self.bStarted = false
  local envSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")
  local handle = self.isLocal and self.OnWeatherChange or self.RemotePlayerOnWeatherChange
  envSystem:UnRegisterEvent(self, EnvSystemModuleEvent.WeatherChangeEvent, handle)
  self:RemoveEnvBuff()
  local moveHandle = self.isLocal and self.OnRideMoveMode or self.RemotePlayerRideMoveMode
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_RIDE_MOVE_MODE_CHANGE, moveHandle)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_RIDEPET_TALENT_CHANGE_POST, moveHandle)
  _G.UpdateManager:UnRegister(self)
end

function PassiveSkill_Weather:PlayCommonEffect()
  local RidePet = self.owner.viewObj
  if RidePet then
    if not self.WeatherFxs then
      self.WeatherFxs = UE4.TArray(UE4.AActor)
    end
    RidePet.RocoMoveFx:LuaPlayMoveFxByStatus("PassiveSkill_Weather", self.WeatherFxs)
    self.bFxVisual = true
  end
end

function PassiveSkill_Weather:StopCommonEffect()
  local RidePet = self.owner.viewObj
  if UE.UObject.IsValid(RidePet) and self.WeatherFxs then
    for i, fx in ipairs(self.WeatherFxs:ToTable()) do
      RidePet.RocoMoveFx:LuaStopMoveFx(fx, 0)
    end
    self.WeatherFxs:Clear()
    self.WeatherFxs = nil
  end
  Base.StopCommonEffect(self)
end

function PassiveSkill_Weather:OnTick(DeltaTime)
  self.CurTickTime = self.CurTickTime + DeltaTime
  if self.CurTickTime < 0.5 then
    return
  end
  self.CurTickTime = 0
  if self.WeatherFxs and self.CharacterMovement then
    local bFxVisual = not self.CharacterMovement.Velocity:IsNearlyZero(0)
    if bFxVisual ~= self.bFxVisual then
      for i, fx in ipairs(self.WeatherFxs:ToTable()) do
        fx:SetActorHiddenInGame(self.bFxVisual)
      end
      self.bFxVisual = bFxVisual
    end
  end
end

function PassiveSkill_Weather:CheckCondition()
  local RidePet = self.owner
  if RidePet.TalentEffectMap[Enum.PetTalentEffect.PTE_WEATHER] then
    return true
  end
  return false
end

return PassiveSkill_Weather
