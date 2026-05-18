local NRCPhaseManager = _G.Singleton:Extend("NRCPhaseManager")

function NRCPhaseManager:Ctor()
  Singleton.Ctor(self, self.name)
  Log.Debug("NRCPhaseManager ctor")
  self.phaseDict = {}
  self.linkDict = {}
  self.linkProcessDict = {}
end

function NRCPhaseManager:CreatePhase(mode, phaseName, phasePath, linkName, ...)
  if self:HasPhase(mode.modeName, phaseName) then
    Log.Error("\232\175\183\229\139\191\229\164\154\230\172\161\229\136\155\229\187\186Phase:", mode.modeName, phaseName)
    return
  end
  local phaseCla = require(phasePath)
  local phase = phaseCla()
  phase.mode = mode
  phase.phaseName = phaseName
  phase:Construct(...)
  if not self.phaseDict[mode.modeName] then
    self.phaseDict[mode.modeName] = {}
  end
  if linkName then
    NRCModeBase:PushLink(linkName, phase)
  end
  return phase
end

function NRCPhaseManager:DeletePhase(modeName, phaseName)
  local phase, i = self:GetPhase()
  if phase and i > 0 then
    self.phaseDict[modeName][i]:Shutdown()
    table.remove(self.phaseDict[modeName], i)
  end
end

function NRCPhaseManager:ExitPhase(modeName, phaseName)
  local phase, _ = self:GetPhase(modeName, phaseName)
  phase:Exit()
end

function NRCPhaseManager:HasPhase(modeName, phaseName)
  local phase, _ = self:GetPhase(modeName, phaseName)
  return nil ~= phase
end

function NRCPhaseManager:GetPhase(modeName, phaseName)
  if not self.phaseDict[modeName] then
    return nil, 0
  end
  local lst = self.phaseDict[modeName]
  for i = 1, #lst do
    if lst[i].phaseName == phaseName then
      return lst[i], i
    end
  end
  return nil, 0
end

function NRCPhaseManager:PushLink(linkName, phase)
  if not self.linkDict[linkName] then
    self.linkDict[linkName] = {}
  end
  table.insert(self.linkDict[linkName], phase)
end

function NRCPhaseManager:EnterNext(linkName)
  if not self.linkProcessDict[linkName] then
    self.linkProcessDict[linkName] = 1
  end
end

function NRCPhaseManager:ResetLinkProcess(linkName)
  if self.linkProcessDict[linkName] then
    self.linkProcessDict[linkName] = 1
  end
end

return NRCPhaseManager
