local NRCPhaseBase = NRCClass()

function NRCPhaseBase:Ctor()
  Log.Debug("NRCPhaseBase ctor")
  self.phaseName = nil
  self.linkName = nil
  self.mode = nil
end

function NRCPhaseBase:Construct(...)
  self:OnConstruct(...)
end

function NRCPhaseBase:OnConstruct(...)
end

function NRCPhaseBase:Enter(...)
  self:OnEnter(...)
end

function NRCPhaseBase:OnEnter(...)
end

function NRCPhaseBase:Exit()
  self:OnExit()
  if self.linkName then
    NRCPhaseManager:EnterNext(self.linkName)
  end
end

function NRCPhaseBase:OnExit()
end

function NRCPhaseBase:Shutdown()
end

return NRCPhaseBase
