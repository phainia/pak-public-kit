local TUIModuleCmd = reload("NewRoco.Modules.System.TUI.TUIModuleCmd")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabPerformance = Base:Extend("DebugTabPerformance")

function DebugTabPerformance:Ctor()
  Base.Ctor(self)
end

function DebugTabPerformance:SetupTabs()
end

function DebugTabPerformance:StartNRCDrawChart()
  UE4.UNRCStatics.ExecConsoleCommand("STARTNRCPERFCAKECHART")
end

function DebugTabPerformance:StopNRCDrawChart()
  UE4.UNRCStatics.ExecConsoleCommand("STOPNRCPERFCAKECHART")
end

function DebugTabPerformance:StartCSMCache()
  UE4.UNRCStatics.ExecConsoleCommand("r.Shadow.CSMCaching 1")
end

function DebugTabPerformance:SetHISMCollapse(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if "" == value then
    return
  end
  local cmd = string.format("g.GHISMCollapseNum %s", value)
  UE4Helper.PrintScreenMsg(cmd)
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
end

function DebugTabPerformance:LockPlayerInput()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.inputComponent:SetInputEnable(self, false)
  player.inputComponent:SetCameraControlEnable(self, false)
end

function DebugTabPerformance:UnLockPlayerInput()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.inputComponent:SetInputEnable(self, true)
  player.inputComponent:SetCameraControlEnable(self, true)
end

function DebugTabPerformance:GpuCapture(name, panel)
  if panel then
    local World = panel:GetWorld()
    panel:DoClose()
    UE4.UNRCStatics.GpuCapture(World)
  end
end

function DebugTabPerformance:IsAsyncLoadThreadOpen()
  local bOpen = UE4.UNRCStatics.IsAsyncLoadThreadOpen()
  Log.Error("\229\188\130\230\173\165\231\186\191\231\168\139\231\138\182\230\128\129", bOpen)
end

function DebugTabPerformance:MoveToTestActor(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if "" == value then
    return
  end
  local cmd = string.format("AutoTestTool.MoveToTestActor %s", value)
  UE4Helper.PrintScreenMsg(cmd)
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
end

function DebugTabPerformance:PrintRdgStackTrace(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if "" == value then
    value = 1
  end
  local cmd = string.format("r.RDG.stacktrace %s", value)
  UE4Helper.PrintScreenMsg(cmd)
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
end

function DebugTabPerformance:testMeshMemory(assetName)
  local assetPath = "/Game/ArtRes/Temp/cloudcheng/test_mesh_size.test_mesh_size"
  local asset = LoadObject(assetPath)
  UE4.UNRCStatics.GetUObjectBytes(asset)
end

function DebugTabPerformance:testMesh1Memory(assetName)
  local assetPath = "/Game/ArtRes/Temp/cloudcheng/test_mesh_size1.test_mesh_size1"
  local asset = LoadObject(assetPath)
  UE4.UNRCStatics.GetUObjectBytes(asset)
end

function DebugTabPerformance:testMesh2Memory(assetName)
  local assetPath = "/Game/ArtRes/Temp/cloudcheng/test_mesh_size2.test_mesh_size2"
  local asset = LoadObject(assetPath)
  UE4.UNRCStatics.GetUObjectBytes(asset)
end

function DebugTabPerformance:testMesh3Memory(assetName)
  local assetPath = "/Game/ArtRes/Temp/cloudcheng/test_mesh_size3.test_mesh_size3"
  local asset = LoadObject(assetPath)
  UE4.UNRCStatics.GetUObjectBytes(asset)
end

function DebugTabPerformance:TestMarkLevelLoad()
  self.testMarkCount = (self.testMarkCount or 0) + 1
  UE4.UGPMStatics.MarkLevelLoad("TestMark" .. self.testMarkCount)
end

function DebugTabPerformance:TestMarkLevelFin()
  UE4.UGPMStatics.MarkLevelFin()
end

function DebugTabPerformance:TestStartStutter(name, panel)
  if panel then
    panel:DoClose()
  end
  _G.NRCSDKManager:StartCustomStutter()
end

function DebugTabPerformance:TestStopStutter(name, panel)
  if panel then
    panel:DoClose()
  end
  local stutter = _G.NRCSDKManager:StopCustomStutter()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowPerfStutter, stutter)
end

function DebugTabPerformance:DebugApmQuality()
  if _G.NRCSDKManager then
    local qualityValue = _G.NRCSDKManager:SetQualityToApm()
    if type(qualityValue) ~= "string" or string.IsNilOrEmpty(qualityValue) then
      return
    end
    local ApmDataConf = {
      [1] = {
        name = "\232\174\190\229\164\135\229\136\134\230\161\163",
        [0] = "0\230\161\163",
        [1] = "1\230\161\163",
        [2] = "2\230\161\163",
        [3] = "3\230\161\163",
        [4] = "4\230\161\163",
        [5] = "5\230\161\163",
        [6] = "6\230\161\163"
      },
      [2] = {
        name = "\229\184\167\231\142\135",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\230\158\129\233\171\152",
        [4] = "\232\182\133\233\171\152"
      },
      [3] = {
        name = "\230\152\190\231\164\186\230\168\161\229\188\143",
        [0] = "\228\189\142",
        [2] = "\228\184\173",
        [3] = "\233\171\152"
      },
      [4] = {
        name = "\231\148\187\233\157\162\229\147\129\232\180\168",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152",
        [4] = "\232\135\170\229\174\154\228\185\137"
      },
      [5] = {
        name = "\233\152\180\229\189\177\232\180\168\233\135\143",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [6] = {
        name = "\229\144\142\230\156\159\230\149\136\230\158\156",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [7] = {
        name = "\229\135\160\228\189\149\231\187\134\232\138\130",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [8] = {
        name = "\230\157\144\232\180\168\231\178\190\229\186\166",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [9] = {
        name = "\229\138\160\232\189\189\232\183\157\231\166\187",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [10] = {
        name = "\229\133\137\231\133\167\232\180\168\233\135\143",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [11] = {
        name = "\231\137\185\230\149\136\232\180\168\233\135\143",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152"
      },
      [12] = {
        name = "\229\143\141\229\176\132\232\180\168\233\135\143",
        [0] = "\229\133\179\233\151\173",
        [2] = "\229\188\128\229\144\175"
      },
      [13] = {
        name = "\230\179\155\229\133\137\230\149\136\230\158\156",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      },
      [14] = {
        name = "\230\138\151\233\148\175\233\189\191",
        [0] = "\228\189\142",
        [1] = "\228\184\173",
        [2] = "\233\171\152",
        [3] = "\232\182\133\233\171\152"
      }
    }
    if RocoEnv.PLATFORM == "PLATFORM_WINDOWS" then
      ApmDataConf[3] = {
        name = "\230\152\190\231\164\186\230\168\161\229\188\143",
        [0] = "\230\156\170\229\174\154\228\185\137",
        [1] = "3840*2160",
        [2] = "2560*1600",
        [3] = "2560*1440",
        [4] = "2560*1080",
        [5] = "2048*1536",
        [6] = "2048*1152",
        [7] = "1920*1440",
        [8] = "1920*1200",
        [9] = "1920*1080"
      }
    end
    local reportData = {}
    for i = 1, #qualityValue do
      local char = qualityValue:sub(i, i)
      local value = tonumber(char)
      local confItem = ApmDataConf[i]
      if confItem then
        local itemName = confItem.name or "index" .. i
        local itemDesc = confItem[value] or "\233\148\153\232\175\175\229\128\188" .. value
        reportData[itemName] = itemDesc
      else
        break
      end
    end
    self:Inspect(reportData, "Apm\228\184\138\230\138\165\232\135\170\229\174\154\228\185\137\231\148\187\232\180\168")
  end
end

function DebugTabPerformance:ClearDebugTabDataCache()
  self.module.data:ClearTabDataFromCache()
end

function DebugTabPerformance:EnableDebugTabDataCache()
  _G.GlobalConfig.bUseDebugTabCache = true
end

function DebugTabPerformance:DisableDebugTabDataCache()
  _G.GlobalConfig.bUseDebugTabCache = false
  self.module.data:ClearTabDataFromCache()
end

return DebugTabPerformance
