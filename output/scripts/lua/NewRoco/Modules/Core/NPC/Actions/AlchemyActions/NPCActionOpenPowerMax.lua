local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenPowerMax = Base:Extend("NPCActionOpenPowerMax")

function NPCActionOpenPowerMax:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenPowerMax:ExecuteWithModel()
  local IronPan = self:GetOwnerNPCView()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RegisterIronPan, IronPan)
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 103, self, self.BeginShowEnd)
end

function NPCActionOpenPowerMax:BeginShowEnd()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenVitalityPanel, self)
end

function NPCActionOpenPowerMax:EndAction()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 112, self, self.EndShowEnd)
end

function NPCActionOpenPowerMax:EndShowEnd()
  self:Finish()
end

return NPCActionOpenPowerMax
