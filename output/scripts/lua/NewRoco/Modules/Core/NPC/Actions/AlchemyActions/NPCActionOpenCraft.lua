local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenCraft = Base:Extend("NPCActionOpenCraft")

function NPCActionOpenCraft:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenCraft:ExecuteWithModel()
  local IronPan = self:GetOwnerNPCView()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RegisterIronPan, IronPan)
  _G.NRCProfilerLog:NRCPanelRequireRes(true, "UMG_AlchemyPanel_C")
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 103, self, self.BeginShowEnd)
end

function NPCActionOpenCraft:BeginShowEnd()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_ALCHEMY_PANEL, true)
  if isBan then
    self:EndAction()
    return
  end
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OpenAlchemyPanel, self)
end

function NPCActionOpenCraft:EndAction()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 112, self, self.EndShowEnd)
end

function NPCActionOpenCraft:EndShowEnd()
  self:Finish()
end

return NPCActionOpenCraft
