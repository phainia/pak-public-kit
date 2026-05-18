local UMG_ScreenshotSharing_C = _G.NRCPanelBase:Extend("UMG_ScreenshotSharing_C")
local ShareUIModuleEvent = reload("NewRoco.Modules.System.ShareUI.ShareUIModuleEvent")

function UMG_ScreenshotSharing_C:OnActive()
  self.IsClose = false
  self.CanShare = false
  self.ScreenShotPath = nil
  self.ShareCallBack = nil
  self:OnAddEventListener()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:InitPanelInfo()
  self.shareBaseId = _G.Enum.ShareButtonType.SBT_SCREENSHOT
  _G.NRCModuleManager:DoCmd(_G.ShareUIModuleCmd.CheckRewardStateEntrance, self.shareBaseId)
end

function UMG_ScreenshotSharing_C:OnDeactive()
  self:RemoveButtonListener(self.SharingBtn.btnLevelUp, self.OnShare)
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self.CloseBtn_1.OnClicked:Remove(self, self.OnCloseBtnClick)
  _G.NRCEventCenter:UnRegisterEvent(self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
  self:CancelShareDelayId()
  self.ShareUIReward:CancelShareDelayId()
end

function UMG_ScreenshotSharing_C:OnAddEventListener()
  self:AddButtonListener(self.SharingBtn.btnLevelUp, self.OnShare)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self.CloseBtn_1.OnClicked:Add(self, self.OnCloseBtnClick)
  _G.NRCEventCenter:RegisterEvent(self.name, self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
end

function UMG_ScreenshotSharing_C:InitPanelInfo()
  self.SharingBtn.ItemName:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SharingBtn.Text_PCKey:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnScreenshot()
end

function UMG_ScreenshotSharing_C:OnShare()
  if self.CanShare then
    local function cb()
      local sharePartId = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.GetSharePartIdByShareBaseId, self.shareBaseId)
      
      if sharePartId then
        local data = {
          shareBaseId = self.shareBaseId,
          sharePartId = sharePartId,
          photoPath = self.ScreenShotPath
        }
        _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.OpenShareUIPanel, data)
      end
    end
    
    self.ShareCallBack = cb
    self:OnCloseBtnClick()
  else
    Log.Error("\230\136\170\229\177\143\229\136\134\228\186\171\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129\239\188\129")
  end
end

function UMG_ScreenshotSharing_C:OnScreenshot()
  self.GMPlatformKits = UE4.UMoreFunPlatformKits
  self.ScreenShotService = self.GMPlatformKits.CreateScreenShotService()
  self.ScreenShotServiceRef = UnLua.Ref(self.ScreenShotService)
  self.HttpService = self.GMPlatformKits.CreateSimpleHttpService()
  self.HttpServiceRef = UnLua.Ref(self.HttpService)
  local fileName = "ScreenShot" .. tostring(os.time())
  self:_DoReqScreenShot(fileName, function(bIsSuccess, SavePath, Service)
    if bIsSuccess then
      self:ScreenShotFinishSuccess(SavePath)
    else
      self.CanShare = false
      Log.Error("\230\136\170\229\177\143\229\136\134\228\186\171\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129\239\188\129")
    end
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.In)
  end, true)
end

function UMG_ScreenshotSharing_C:_DoReqScreenShot(FileName, Callback, bShowUI)
  self.ScreenShotService:RequestScreenshot({
    self.ScreenShotService,
    function(Service, Status)
      Callback(Status == UE4.EHttpServiceStatus.RspSuccess, Service:GetSavedFilePath(), Service)
    end
  }, FileName, bShowUI or false)
end

function UMG_ScreenshotSharing_C:ScreenShotFinishSuccess(SavePath)
  self.ScreenShotPath = SavePath
  self.CanShare = true
end

function UMG_ScreenshotSharing_C:OnCloseBtnClick()
  if self.IsClose then
    return
  end
  self.IsClose = true
  self:PlayAnimation(self.Out)
end

function UMG_ScreenshotSharing_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    if self.ShareCallBack then
      self.ShareCallBack()
      self.ShareCallBack = nil
    end
    self:OnClose()
  end
end

function UMG_ScreenshotSharing_C:CheckShowShareReward(data)
  if data.shareBaseId == self.shareBaseId and 0 == data.rewardGetState then
    local function cb()
      self.ShareUIReward:Init({
        shareBaseId = data.shareBaseId,
        
        isUpAnim = false
      })
    end
    
    self.shareDelayId = _G.DelayManager:DelayFrames(1, cb, self)
  end
end

function UMG_ScreenshotSharing_C:CancelShareDelayId()
  if self.shareDelayId then
    _G.DelayManager:CancelDelayById(self.shareDelayId)
    self.shareDelayId = nil
  end
end

return UMG_ScreenshotSharing_C
