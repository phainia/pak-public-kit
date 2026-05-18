local Delegate = require("Utils.Delegate")
local BP_Hide_XX_Yuan_C = Class("BP_Hide_XX_Yuan_C")

function BP_Hide_XX_Yuan_C:Ctor()
  self.PlayerDistanceCheckEvent = Delegate()
  self.activated = false
  self.playerInRange = false
end

function BP_Hide_XX_Yuan_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self.Effect:SetFloatParameter("DistanceFar", 7000)
  self.Effect:SetFloatParameter("DistanceNear", 6300.0)
end

function BP_Hide_XX_Yuan_C:ReceiveEndPlay()
  self.PlayerDistanceCheckEvent:Clear()
  self:UnShow()
  self.Overridden.ReceiveEndPlay(self)
end

function BP_Hide_XX_Yuan_C:Show(caller, callback)
  if callback then
    self.PlayerDistanceCheckEvent:Add(caller, callback)
  end
  if not self.activated then
    UpdateManager:Register(self, true)
    self.activated = true
  end
  self.Effect:SetActive(true)
end

function BP_Hide_XX_Yuan_C:UnShow()
  if self.activated then
    UpdateManager:UnRegister(self)
    self.activated = false
  end
end

function BP_Hide_XX_Yuan_C:OnTick()
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local PlayerInRange = player.cachePlayerTransform.Translation:Dist(self:Abs_K2_GetActorLocation()) < 7000
    if PlayerInRange ~= self.playerInRange then
      self.playerInRange = PlayerInRange
      self.PlayerDistanceCheckEvent:Invoke(PlayerInRange)
    end
  end
end

return BP_Hide_XX_Yuan_C
