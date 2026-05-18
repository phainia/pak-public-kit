local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenBottleTimes = Base:Extend("NPCActionOpenBottleTimes")

function NPCActionOpenBottleTimes:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenBottleTimes:ExecuteWithModel()
  local IronPan = self:GetOwnerNPCView()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RegisterIronPan, IronPan)
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 103, self, self.BeginShowEnd)
end

function NPCActionOpenBottleTimes:BeginShowEnd()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_ALCHEMY_MAGIC, true)
  if isBan then
    self:EndAction()
    return
  end
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenMagicStudyPanel, self)
end

function NPCActionOpenBottleTimes:EndAction()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 112, self, self.EndShowEnd)
end

function NPCActionOpenBottleTimes:EndShowEnd()
  self:Finish()
end

return NPCActionOpenBottleTimes
