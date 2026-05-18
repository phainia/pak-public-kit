local EventDispatcher = require("Common.EventDispatcher")
local RidePetEvent = require("NewRoco.Modules.Core.Scene.Component.RidePet.RidePetEvent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BP_RideAllBase_C = NRCClass()

function BP_RideAllBase_C:Ctor()
  EventDispatcher():Attach(self)
end

function BP_RideAllBase_C:OnSurfaceChanged(CurSurface, LastSurface)
  self:SendEvent(RidePetEvent.ON_SURFACE_CHANGE, CurSurface, LastSurface)
end

function BP_RideAllBase_C:GetSurface()
  return self.CharacterEnvInfo:GetCurSurface()
end

function BP_RideAllBase_C:StopFlyAudio()
  if self.HasFlyAudio then
    local id = self.FlyAudioSessionId
    _G.DelayManager:DelaySeconds(0.1, function()
      _G.NRCAudioManager:ReleaseSession(id, true, "BP_RideAllBase_C")
    end)
    self.HasFlyAudio = false
  end
end

function BP_RideAllBase_C:HandleImpact(Hit)
  self:SendEvent(RidePetEvent.HANDLE_IMPACT, Hit)
end

function BP_RideAllBase_C:OnDestroyedByEngine()
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.EnterBattle, self.OnEnterBattle)
  Base.OnDestroyedByEngine(self)
end

function BP_RideAllBase_C:OnResolvePenetrationFinished()
  Log.Debug("[DebugMove1P]BP_RideAllBase_C:OnResolvePenetrationFinished")
  local player = self.sceneCharacter
  if player then
    player:ForceSendMoveReq(true, nil)
  end
end

function BP_RideAllBase_C:CanEnterMovementMode(MovementMode)
  if MovementMode == UE4.EMovementMode.MOVE_Falling then
    return true
  end
  local RideComp = self.Rider and self.Rider.BP_RideComponent
  if not RideComp then
    return false
  end
  local ScenePet = RideComp.ScenePet
  if not ScenePet or not ScenePet.config then
    return false
  end
  local PetConf = _G.DataConfigManager:GetAllRidePet(ScenePet.config.id)
  if not PetConf then
    return false
  end
  local MovementConf = _G.DataConfigManager:GetAllByTableID(_G.DataConfigManager.ConfigTableId.RIDE_BASIC_MOVEMENT)
  if not MovementConf then
    return false
  end
  for j, _MovementID in ipairs(PetConf.basic_movement_list) do
    local Conf = MovementConf[_MovementID]
    if Conf and Conf.move_type == MovementMode then
      return true
    end
  end
  return false
end

return BP_RideAllBase_C
