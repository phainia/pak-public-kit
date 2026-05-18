local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabResource = Base:Extend("DebugTabResource")

function DebugTabResource:Ctor()
  Base.Ctor(self)
end

function DebugTabResource:SetupTabs()
end

function DebugTabResource:Test1(name, panel)
  local path = "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugPanel.UMG_DebugPanel_C"
  self:LoadRes(path)
  self:LoadRes(path)
  self:LoadRes(path)
  self:LoadRes(path)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\229\138\159\232\131\189\229\188\128\229\143\145\228\184\173\230\149\172\232\175\183\230\156\159\229\190\133")
end

function DebugTabResource:Test2(name, panel)
  Log.Debug("DebugTabResource:Test2")
  local title = "title"
  local content = "content"
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Ctx = DialogContext()
  Ctx:SetTitle(title):SetContent(content):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(listener, boo)
    if boo then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "11111111")
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "22222222")
    end
  end):SetCloseOnCancel(false):SetButtonText("111111", "222222")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabResource:Test3(name, panel)
  Log.Debug("DebugTabResource:Test3")
  local url = "Blueprint'/Game/NewRoco/Modules/Core/Battle/NPC/Human/NPC_01801/BP_Battle_NPC_01801.BP_Battle_NPC_01801_C"
  NRCResourceManager:LoadResAsync(self, url, -1, -1, function(call, resRequest, errMsg)
    Log.Error("\229\138\160\232\189\189\230\136\144\229\138\159 ", url)
  end, function(call, resRequest, errMsg)
    Log.Error("\229\138\160\232\189\189\229\164\177\232\180\165 ", url)
  end, function(caller, resRequest, asset)
  end)
end

function DebugTabResource:LoadRes(path)
  local index = 0
  index = NRCResourceManager:LoadResAsync(self, path, -1, -1, function(caller, resRequest, asset)
    Log.Debug("DebugTabResource:LoadRes succ:", resRequest.sessionId, resRequest.assetPath)
  end, function(caller, resRequest, errMsg)
    Log.Error("DebugTabResource:LoadRes fail:", resRequest.sessionId, resRequest.assetPath, errMsg)
  end, function(caller, resRequest, progress)
  end)
  return index
end

function DebugTabResource:UnLoadRes(index)
  NRCResourceManager:UnLoadRes(index)
end

return DebugTabResource
