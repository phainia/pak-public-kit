require("UnLuaEx")
local BP_TaskTrackBeam_C = NRCClass()

function BP_TaskTrackBeam_C:Initialize(Initializer)
  if Initializer then
    self.min = Initializer.min
    self.max = Initializer.max
    self.mult = Initializer.mult
  else
    Log.Warning("Need a initializer...")
  end
end

function BP_TaskTrackBeam_C:ReceiveBeginPlay()
  self:SetActorTickEnabled(true)
  self.needTick = true
  self.OriginalScale = self:GetActorScale3D()
end

function BP_TaskTrackBeam_C:ReceiveTick(DeltaSeconds)
  if not UE.UObject.IsValid(self) then
    return
  end
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  local View = player and player.viewObj
  if not View then
    return
  end
  local distance = self:GetDistanceTo(View)
  local range = self.max - self.min
  local coefficient = self.mult / 100 - 1
  local Calc = math.min(self.max, distance)
  Calc = math.max(self.min, Calc)
  Calc = (Calc - self.min) / range
  Calc = 1 + Calc * coefficient
  self:SetActorScale3D(UE4.FVector(Calc, Calc, Calc))
  self.Overridden.ReceiveTick(self, DeltaSeconds)
end

return BP_TaskTrackBeam_C
