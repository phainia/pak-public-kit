local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local TUIModuleCmd = reload("NewRoco.Modules.System.TUI.TUIModuleCmd")
local Base = DebugTabBase
local DebugTabRec = Base:Extend("DebugTabRec")

function DebugTabRec:Ctor()
  Base.Ctor(self)
end

function DebugTabRec:SetupTabs()
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\229\153\169\230\162\166\231\149\140\233\157\162", self.SendLegendaryTaskUnlockNotify, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\232\191\156\229\143\164\233\173\148\230\179\149\230\137\139\229\134\140", self.SendLegendaryTaskUnlockNotify1, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\230\137\139\232\180\166\231\179\187\231\187\159", self.SendLegendaryTaskUnlockNotify3, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\231\187\169\231\130\185\230\142\146\232\161\140\230\166\156", self.TestOpenGradePointPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\233\159\179\228\185\144\232\174\190\231\189\174\231\149\140\233\157\162tips", self.SendLegendaryTaskUnlockNotify2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\230\181\139\232\175\149\229\137\141\231\171\175\228\189\191\231\148\168\230\150\176\231\154\132\230\148\190\231\148\159\230\157\144\230\150\153\232\167\132\229\136\153", self.TestUseNewPetFree, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\136\170\229\177\143\229\143\170\230\136\170\228\184\128\229\184\167", self.EnableNRCCaptureAutoStop, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\136\170\229\177\143\228\184\128\231\155\180\232\191\144\232\161\140", self.DisableNRCCaptureAutoStop, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\181\139\232\175\149\230\136\170\229\177\143", self.TestNRCSceneCapture, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabRec:TestUseNewPetFree()
  _G.GlobalConfig.UseNewPetFree = not _G.GlobalConfig.UseNewPetFree
end

function DebugTabRec:OpenTestPanelBNew()
  self.HasTestB = true
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.OpenTestPanelB, false)
end

function DebugTabRec:ShowTestPanelBNew()
  if not self.HasTestB then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.TUIModuleCmd.ShowTestPanelB, self.bBugTestBOpen)
  self.bBugTestBOpen = not self.bBugTestBOpen
end

function DebugTabRec:OpenTestPanelC()
  _G.NRCModuleManager:DoCmd(_G.TUIModuleCmd.OpenTestPanelC, false)
end

function DebugTabRec:CloseTestPanelC()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.CloseTestPanelC, true)
end

function DebugTabRec:SendLegendaryTaskUnlockNotify()
  local taskModule = _G.NRCModuleManager:GetModule("TaskModule")
  if taskModule then
    local notify = {
      itemId = 290003,
      type = 1,
      PageId = 1
    }
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenLegendaryPanel, 1)
  end
end

function DebugTabRec:SendLegendaryTaskUnlockNotify1()
  local taskModule = _G.NRCModuleManager:GetModule("TaskModule")
  if taskModule then
    local notify = {
      itemId = 290003,
      type = 1,
      PageId = 1
    }
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenLegendaryPanel, 2)
  end
end

function DebugTabRec:SendLegendaryTaskUnlockNotify3(name, panel)
  local taskModule = _G.NRCModuleManager:GetModule("TaskModule")
  if taskModule then
    local notify = {
      itemId = 290003,
      type = 1,
      PageId = 1
    }
    _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenLegendaryPanel, 3)
  end
  if panel then
    panel:DoClose()
  end
end

function DebugTabRec:TestOpenGradePointPanel(name, panel)
  local bagModule = _G.NRCModuleManager:GetModule("BagModule")
  if bagModule then
    _G.NRCModuleManager:DoCmd(BagModuleCmd.OpenGradePointPanel)
  end
  if panel then
    panel:DoClose()
  end
end

function DebugTabRec:SendLegendaryTaskUnlockNotify2()
  local MusicCollectionModule = _G.NRCModuleManager:GetModule("MusicCollectionModule")
  if MusicCollectionModule then
    MusicCollectionModule:OnMusicUnlockNotify()
  end
end

function DebugTabRec:EnableNRCCaptureAutoStop(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCapture.AutoDistroy 1")
end

function DebugTabRec:DisableNRCCaptureAutoStop(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "NRCCapture.AutoDistroy 0")
end

function DebugTabRec:TestNRCSceneCapture(name, panel)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraManager = player:GetUEController().playerCameraManager
  cameraManager:StartCaptureBlurScene2D(4, 4)
end

return DebugTabRec
