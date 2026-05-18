local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabSceneTest = Base:Extend("DebugTabSceneTest")

function DebugTabSceneTest:Ctor()
  Base.Ctor(self)
end

function DebugTabSceneTest:SetupTabs()
  self:Add("\230\129\162\229\164\141\229\156\186\230\153\175", self.RecoverScene, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\233\170\140\232\175\129\231\178\190\231\187\134\231\137\169\231\144\134", self.AccuratePhysicsTest, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\233\170\140\232\175\129\231\174\128\230\152\147\231\137\169\231\144\134", self.SimplePhysicsTest, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\229\133\179\231\137\169\231\144\134\231\189\145\230\160\188--\233\153\132\232\191\14510\231\177\179", self.ShowPhysics, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\229\133\179\229\175\188\232\136\170\231\189\145\230\160\188", self.ShowNavigation, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\231\164\186SDOC\231\189\145\230\160\188", self.ShowSDOCMesh, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\231\164\186PVS\231\189\145\230\160\188", self.ShowPVSCell, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\233\170\140\232\175\129HLOD\231\131\152\229\159\185", self.HLODTest, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173CLV\229\133\137\231\133\167\230\149\136\230\158\156", self.CloseCLV, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
end

function DebugTabSceneTest:RecoverScene(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.RetainLayers None")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeLayers None")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "LevelLOD.ForceLOD -1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "ShowSDOCOccluder 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.ShowPrecomputedVisibilityCells 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.clv 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCBlockTill.Load")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:AccuratePhysicsTest(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.RetainLayers Global;Landscape;POI;Physics")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCBlockTill.Load")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:SimplePhysicsTest(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "LevelLOD.ForceLOD 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCBlockTill.Load")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:ShowPhysics(name, panel)
  local command = "pxvis collision 1000"
  self:GetController():SendToConsole(command)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:ShowNavigation(name, panel)
  local command = "Show Navigation"
  self:GetController():SendToConsole(command)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:ShowSDOCMesh(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "ShowSDOCOccluder 1")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:ShowPVSCell(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.ShowPrecomputedVisibilityCells 1")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:HLODTest(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "WorldTileTool.FreezeLayers BuildingsA;BuildingsB;BuildingsC;EnvRock")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCBlockTill.Load")
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneTest:CloseCLV(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "r.clv 0")
  if panel then
    panel:DoClose()
  end
end

return DebugTabSceneTest
