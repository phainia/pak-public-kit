local SkillPerformModuleCmd = require("NewRoco.Modules.System.SkillPerform.SkillPerformModuleCmd")
local SkillPerformModule = NRCModuleBase:Extend("SkillPerformModule")

function SkillPerformModule:OnConstruct()
end

function SkillPerformModule:OnActive()
  self:RegisterCmd(SkillPerformModuleCmd.CompassEnter, self.CompassEnter)
  self:RegisterCmd(SkillPerformModuleCmd.CompassIdle, self.CompassIdle)
  self:RegisterCmd(SkillPerformModuleCmd.CompassEnd, self.CompassEnd)
end

function SkillPerformModule:CompassEnter(Compass)
end

function SkillPerformModule:CompassIdle(Compass)
  if UE4.UObject.IsValid(Compass) and UE4.UObject.IsValid(Compass.NRCNiagaraHalo) then
    Compass.NRCNiagaraHalo:SetComponentActive(true)
  end
end

function SkillPerformModule:CompassEnd(Compass)
end

return SkillPerformModule
