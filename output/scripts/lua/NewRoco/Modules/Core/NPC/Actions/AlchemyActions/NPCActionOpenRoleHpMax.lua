local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenRoleHpMax = Base:Extend("NPCActionOpenRoleHpMax")

function NPCActionOpenRoleHpMax:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenRoleHpMax:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PauseRoleHpShow)
  local IronPan = self:GetOwnerNPCView()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RegisterIronPan, IronPan)
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 103, self, self.BeginShowEnd)
end

function NPCActionOpenRoleHpMax:BeginShowEnd()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenArdourPanel, self)
end

function NPCActionOpenRoleHpMax:EndAction()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 112, self, self.EndShowEnd)
end

function NPCActionOpenRoleHpMax:EndShowEnd()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.ResumeRoleHpShow)
  self:Finish()
end

return NPCActionOpenRoleHpMax
