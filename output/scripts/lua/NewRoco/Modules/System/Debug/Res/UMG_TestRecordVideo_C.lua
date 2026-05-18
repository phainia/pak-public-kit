local UMG_TestRecordVideo_C = _G.NRCPanelBase:Extend("UMG_TestRecordVideo_C")
local NRCSDKManagerEvent = require("Core.Service.SDKManager.NRCSDKManagerEvent")

function UMG_TestRecordVideo_C:OnActive()
  self.whiteListAppId = {}
  Log.Debug("UMG_TestRecordVideo_C OnActive")
  self:AddButtonListener(self.PlayBtn1.btnLevelUp, self.PlayVideo)
  self:AddButtonListener(self.CloseBtn1.btnLevelUp, self.CloseVideo)
  self:AddButtonListener(self.ClosePanel1.btnLevelUp, self.ClosePanel)
  self:AddButtonListener(self.StartRecordBtn.btnLevelUp, self.StartRecord)
  self:AddButtonListener(self.StopRecordBtn.btnLevelUp, self.StopRecord)
  self:AddButtonListener(self.GenerateVideoBtn.btnLevelUp, self.GenerateVideo)
  _G.NRCEventCenter:RegisterEvent("UMG_TestRecordVideo_C", self, NRCSDKManagerEvent.OnGameletViewCreated, self.OnNewWidgetCreated)
  _G.NRCEventCenter:RegisterEvent("UMG_TestRecordVideo_C", self, NRCSDKManagerEvent.OnGameletViewDestroyed, self.OnNewWidgetDestroyed)
  _G.NRCEventCenter:RegisterEvent("UMG_TestRecordVideo_C", self, NRCSDKManagerEvent.OnNewGameletAppReady, self.AddNewWhiteAppId)
end

function UMG_TestRecordVideo_C:OnDeactive()
end

function UMG_TestRecordVideo_C:OnAddEventListener()
end

function UMG_TestRecordVideo_C:PlayVideo()
  local ret = 2
  self.VideoPlayerWidget:Play("https://image.smoba.qq.com/Video/playonline/Nobe_Video.mp4", true, ret)
end

function UMG_TestRecordVideo_C:CloseVideo()
  self.VideoPlayerWidget:Close()
end

function UMG_TestRecordVideo_C:ClosePanel()
  self:OnClose()
end

function UMG_TestRecordVideo_C:StartRecord()
  NRCModuleManager:DoCmd(ShareModuleCmd.StartRecordVideo, "test")
end

function UMG_TestRecordVideo_C:StopRecord()
  Log.PrintScreenMsg("StopRecord invoked")
  NRCModuleManager:DoCmd(ShareModuleCmd.EndRecordVideo, "test")
end

function UMG_TestRecordVideo_C:GenerateVideo()
  Log.PrintScreenMsg("StartRecordVideo invoked")
end

function UMG_TestRecordVideo_C:OnNewWidgetCreated(widget, appInfo)
  if widget then
    local childWidget = self.NRCCanvasPanel_43:AddChild(widget)
    local viewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
    childWidget:SetPosition(UE4.FVector2D(0, 0))
    childWidget:SetSize(UE4.FVector2D(viewportSize.X, viewportSize.Y))
    childWidget:SetAnchors(UE4.FAnchors(0.5))
  end
end

function UMG_TestRecordVideo_C:OnNewWidgetDestroyed(widget, appInfo)
  if widget and self.NRCCanvasPanel_43:HasChild(widget) then
    self.NRCCanvasPanel_43:RemoveChild(widget)
  end
end

function UMG_TestRecordVideo_C:AddNewWhiteAppId(appId, appName)
  table.insert(self.whiteListAppId, appId)
end

function UMG_TestRecordVideo_C:CloseGameletPanel()
  if self.NRCCanvasPanel_43 then
    self.NRCCanvasPanel_43:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_TestRecordVideo_C
