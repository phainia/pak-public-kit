local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabFSM = Base:Extend("DebugTabFSM")

function DebugTabFSM:Ctor()
  Base.Ctor(self)
end

function DebugTabFSM:SetupTabs()
end

function DebugTabFSM:ExportFsm(Name, Panel, InputText)
  local FsmSerializeUtils = require("NewRoco.Modules.Core.Fsm.FsmSerializeUtils")
  local FsmPath
  if Panel then
    FsmPath = Panel.InputBox:GetText()
  else
    FsmPath = InputText
  end
  local Fsm = reload(string.IsNilOrEmpty(FsmPath) and "NewRoco.Modules.Core.Battle.Fsm.BattleFsm" or FsmPath)
  local Instance = Fsm()
  local DumpResult = FsmSerializeUtils:ToFlowchart(Instance, "LR")
  Log.Debug(DumpResult)
  UE4.UNRCStatics.ClipboardCopy(DumpResult)
end

function DebugTabFSM:ShowDialogueFsm(Name, Panel)
  local Module = self:GetModule("DialogueModule")
  self:Inspect(Module.DialogueFsm, "DialogueFsm")
end

function DebugTabFSM:ShowCinematicFsm(Name, Panel)
  local Module = self:GetModule("CinematicModule")
  self:Inspect(Module.CinemaFsm, "SceneLocalPlayer")
end

function DebugTabFSM:ShowBattleFsm(Name, Panel)
  self:Inspect(_G.BattleManager.stateFsm, "BattleFsm")
end

function DebugTabFSM:ShowLoginFsm(Name, Panel)
  local Module = self:GetModule("LoginModule")
  self:Inspect(Module.LoginFsm, "LoginFsm")
end

return DebugTabFSM
