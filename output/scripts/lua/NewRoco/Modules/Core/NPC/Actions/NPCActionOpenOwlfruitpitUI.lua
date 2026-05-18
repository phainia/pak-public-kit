local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenOwlfruitpitUI = Base:Extend("NPCActionOpenOwlfruitpitUI")

function NPCActionOpenOwlfruitpitUI:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenOwlfruitpitUI:ExecuteWithModel()
  local ownerNpc = self:GetOwnerNPCView()
  if ownerNpc then
    ownerNpc:OnPanelOpened()
  end
  _G.NRCProfilerLog:NRCClickBtn(true, "SleepingOwlPanel")
  _G.NRCProfilerLog:NRCClickBtn(true, "SleepingOwlFruit")
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlPanel, self, ownerNpc)
end

function NPCActionOpenOwlfruitpitUI:OnPreload()
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.PreLoadSleepingOwlPanel)
end

function NPCActionOpenOwlfruitpitUI:EndAction()
  self:Finish()
end

function NPCActionOpenOwlfruitpitUI:OnCommit(rsp)
  Base.OnCommit(self, rsp)
  local ownerNpc = self:GetOwnerNPCView()
  if ownerNpc then
    ownerNpc:OnPanelClosed()
  end
end

return NPCActionOpenOwlfruitpitUI
