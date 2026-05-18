local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabVideoRecord = Base:Extend("DebugTabVideoRecord")

function DebugTabVideoRecord:Ctor()
  local persistentDir = UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir()
  Log.Debug("persistentDir is: ", persistentDir)
  Base.Ctor(self)
end

function DebugTabVideoRecord:SetupTabs()
  self:Add("\230\137\147\229\188\128\229\176\143\229\186\148\231\148\168", self.OpenGamelet, self)
  self:Add("\229\138\160\232\189\189\230\181\139\232\175\149\229\189\149\229\177\143\233\157\162\230\157\191", self.LoadTestPanel, self)
  self:Add("\229\133\179\233\151\173\230\151\165\229\191\151", self.OpenAllLog, self)
  self:Add("\230\181\139\232\175\149\229\156\186\230\153\175\229\134\133\231\153\187\229\189\149", self.TestLogin, self)
  self:Add("\230\181\139\232\175\149\230\150\135\228\187\182\228\184\138\228\188\160", self.TestUpload, self)
  self:Add("\230\181\139\232\175\149\233\148\153\232\175\175token", self.UpdatePayInfo, self)
  self:Add("\229\136\134\228\186\171\229\176\143\231\168\139\229\186\143", self.ShareTest, self)
end

function DebugTabVideoRecord:ShareTest()
  local way = self:GetInputString()
  _G.NRCModuleManager:DoCmd(_G.ShareModuleCmd.ShareMiniApp, way, "", "", "eb8251fd3cfd8015e21f7844606c0491")
end

function DebugTabVideoRecord:UpdatePayInfo()
  local payInfo = {
    openId = "sherylTest",
    token = "sherylTest",
    channel = "QQ",
    channelInfo = "{\"extend\":\"\",\"pay_token\":\"sherylTest\"}",
    pf = "sherylTest",
    pfKey = "sherylTest"
  }
  NRCModuleManager:DoCmd(PayModuleCmd.SetPayInfo, payInfo)
end

function DebugTabVideoRecord:TestUpload()
  local persistentDir = UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir()
  Log.Debug("persistentDir is: ", persistentDir)
  local videPath = UE.UBlueprintPathsLibrary.Combine({persistentDir, "Temp.mp4"})
  local coverPath = UE.UBlueprintPathsLibrary.Combine({
    UE.UBlueprintPathsLibrary.Combine({persistentDir, "TempPhotos"}),
    "1.png"
  })
  NRCModuleManager:DoCmd(ShareModuleCmd.StartUploadFile, UE.UNRCStatics.ConvertToAbsolutePath(videPath, true), UE.UNRCStatics.ConvertToAbsolutePath(coverPath, true))
end

function DebugTabVideoRecord:TestLogin()
  UE.ULoginStatics.Login("QQ", "", "", "")
end

function DebugTabVideoRecord:OpenAllLog()
  UE4.UNRCStatics.SetLogLevel(0)
  Log.SetLogLevel(Log.LOG_LEVEL.ELogFatal)
end

function DebugTabVideoRecord:ShowReadMe(name, panel)
  UE4.UKismetSystemLibrary.LaunchURL("https://iwiki.woa.com/pages/viewpage.action?pageId=827460344")
end

function DebugTabVideoRecord:LoadTestPanel(name, panel)
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenGameVideoPlayer)
end

function DebugTabVideoRecord:CloseTestPanel()
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.CloseGameVidePlayer)
end

function DebugTabVideoRecord:OnTestPanelLoaded(resRequest, asset)
  self.testPanel = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), asset)
  self.testPanelRef = UnLua.Ref(self.testPanel)
  self.testPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self.testPanel:AddToViewPort(_G.UILayerCtrlCenter.ENUM_LAYER.DEBUG, false)
end

function DebugTabVideoRecord:OpenGamelet()
  local gameletAppID = self:GetInputString()
  local whiteAppIdTable = _G.NRCSDKManager.whiteListAppId
  Log.Error("OpenGamelet with appid:%s", gameletAppID)
  if table.contains(whiteAppIdTable, gameletAppID) then
    UE.UGamelet.Get():OpenApp(gameletAppID, "")
  else
    Log.Error("App not prepared %s", tostring(gameletAppID))
  end
end

return DebugTabVideoRecord
