local UMG_HUD_Base = _G.NRCClass:Extend("UMG_HUD_Base")

function UMG_HUD_Base:Construct()
  self.isDestruct = false
  self:OnConstruct()
end

function UMG_HUD_Base:Destruct()
  local isDestruct = self.isDestruct
  self.isDestruct = true
  if not isDestruct then
    self:OnDestruct()
  end
end

function UMG_HUD_Base:OnConstruct()
end

function UMG_HUD_Base:OnDestruct()
end

function UMG_HUD_Base:OnEnable(...)
end

function UMG_HUD_Base:OnDisable(...)
end

function UMG_HUD_Base:ReturnToPool()
end

function UMG_HUD_Base:AwakeFromPool()
end

return UMG_HUD_Base
