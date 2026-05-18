local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenBottleVolume = Base:Extend("NPCActionOpenBottleVolume")

function NPCActionOpenBottleVolume:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenBottleVolume:ExecuteWithModel()
  local IronPan = self:GetOwnerNPCView()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RegisterIronPan, IronPan)
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 103, self, self.BeginShowEnd)
end

function NPCActionOpenBottleVolume:BeginShowEnd()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenRecoverUpPanel, self)
end

function NPCActionOpenBottleVolume:EndAction()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 112, self, self.EndShowEnd)
end

function NPCActionOpenBottleVolume:EndShowEnd()
  self:Finish()
end

return NPCActionOpenBottleVolume
