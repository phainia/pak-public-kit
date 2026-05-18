local Base = _G.NRCPanelBase
local UMG_Login_StrongPopUp_C = Base:Extend("UMG_Login_StrongPopUp_C")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")

function UMG_Login_StrongPopUp_C:OnConstruct()
  Base.OnConstruct(self)
  self:DynamicAddChildView(self.PopUp)
  if UE.UAsyncSaveGameHandle then
    if not UEPath.ANNOUNCEMENT_SAVE_GAME or UEPath.ANNOUNCEMENT_SAVE_GAME == "" then
      Log.Error("UMG_Login_StrongPopUp_C:OnConstruct ANNOUNCEMENT_SAVE_GAME is nil")
      return
    end
    if self.AsyncSaveGameHandle and self.AsyncSaveGameHandle:IsValid() then
      self.AsyncSaveGameHandle.Completed:Remove(self, self.OnAsyncLoadSaveGameSlotFinish)
      UnLua.Unref(self.AsyncSaveGameHandle)
      self.AsyncSaveGameHandle = nil
    end
    self.AsyncSaveGameHandle_Ref = nil
    self.AsyncSaveGameHandle = NewObject(UE.UAsyncSaveGameHandle, UE.UNRCPlatformGameInstance.GetInstance(), "AnnouncementRedPoint")
    if not self.AsyncSaveGameHandle or not self.AsyncSaveGameHandle:IsValid() then
      Log.Error("UMG_Login_StrongPopUp_C:OnActive Failed to create AsyncSaveGameHandle")
      return
    end
    self.AsyncSaveGameHandle_Ref = UnLua.Ref(self.AsyncSaveGameHandle)
    self.AsyncSaveGameHandle.Completed:Add(self, self.OnAsyncLoadSaveGameSlotFinish)
    self.AsyncSaveGameHandle:AsyncLoadByRawClassPath(UEPath.ANNOUNCEMENT_SAVE_GAME, "AnnouncementRedPoint")
  end
end

function UMG_Login_StrongPopUp_C:OnAsyncLoadSaveGameSlotFinish(saveData, bResult)
  Log.Info("UMG_Login_StrongPopUp_C:OnAsyncLoadSaveGameSlotFinish", bResult)
  if bResult then
    self.SaveData = saveData
    self.SaveData_Ref = UnLua.Ref(self.SaveData)
    self:OnLoadSaveDataSuccess()
  else
    Log.Warning("UMG_Login_StrongPopUp_C:OnAsyncLoadSaveGameSlotFinish failed")
  end
  self:CleanupAsyncSaveGameHandle()
end

function UMG_Login_StrongPopUp_C:CleanupAsyncSaveGameHandle()
  if self.AsyncSaveGameHandle and self.AsyncSaveGameHandle:IsValid() then
    self.AsyncSaveGameHandle.Completed:Remove(self, self.OnAsyncLoadSaveGameSlotFinish)
    UnLua.Unref(self.AsyncSaveGameHandle)
    self.AsyncSaveGameHandle = nil
  end
  self.AsyncSaveGameHandle_Ref = nil
end

function UMG_Login_StrongPopUp_C:OnActive(noticeInfo)
  if not noticeInfo then
    Log.Error("UMG_Login_StrongPopUp_C:OnActive noticeInfo is nil")
    return
  end
  self._isClosing = false
  self.CurNoticeInfo = noticeInfo
  self.Text1:SetText(noticeInfo.Content or "")
  _G.NRCAudioManager:PlaySound2DAuto(41400007, "UMG_Login_StrongPopUp_C:OnActive")
  local commonPopUpData = {}
  commonPopUpData.btnClose = true
  commonPopUpData.TitleText = noticeInfo.Title or ""
  commonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  commonPopUpData.Call = self
  commonPopUpData.BlackMask = true
  self.PopUp:SetPanelInfo(commonPopUpData)
  if self.SaveData and self.SaveData:IsValid() then
    self:SaveStrongPopUpData(self.SaveData)
  end
  self:LoadAnimation(0)
end

function UMG_Login_StrongPopUp_C:OnDeactive()
  Log.Info("UMG_Login_StrongPopUp_C:OnDeactive")
  self._isClosing = false
  if self.SaveData and self.SaveData:IsValid() then
    UnLua.Unref(self.SaveData)
    self.SaveData = nil
  end
  self.SaveData_Ref = nil
  self:CleanupAsyncSaveGameHandle()
end

function UMG_Login_StrongPopUp_C:OnDestruct()
end

function UMG_Login_StrongPopUp_C:OnPcClose()
  self:Log("UMG_Login_StrongPopUp_C:OnPcClose")
  if self._isClosing then
    return
  end
  self._isClosing = true
  self:LoadAnimation(2)
end

function UMG_Login_StrongPopUp_C:OnAnimationFinished(anim)
  if not anim then
    return
  end
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
    self._isClosing = false
    _G.NRCEventCenter:DispatchEvent(LoginModuleEvent.TriggerNextForcePopUpNotice)
  end
end

function UMG_Login_StrongPopUp_C:OnClickCloseBtn()
  if self._isClosing then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Login_StrongPopUp_C:OnActive")
  self._isClosing = true
  self:LoadAnimation(2)
end

function UMG_Login_StrongPopUp_C:SaveStrongPopUpData(SaveData)
  if not SaveData or not SaveData:IsValid() then
    Log.Warning("UMG_Login_StrongPopUp_C:SaveStrongPopUpData SaveData is invalid")
    return
  end
  if self.CurNoticeInfo then
    SaveData.OnlyOnceDic:Add(self.CurNoticeInfo.ID, true)
    SaveData.RedPointDic:Add(self.CurNoticeInfo.ID, true)
    UE4.UGameplayStatics.SaveGameToSlot(SaveData, "AnnouncementRedPoint", 0)
    self:Log("Save OnlyOnce PopUp ID:", self.CurNoticeInfo.ID)
  else
    Log.Warning("UMG_Login_StrongPopUp_C:SaveStrongPopUpData CurNoticeInfo is nil")
  end
end

function UMG_Login_StrongPopUp_C:OnLoadSaveDataSuccess()
  if self.SaveData and self.SaveData:IsValid() then
    self:SaveStrongPopUpData(self.SaveData)
  end
end

function UMG_Login_StrongPopUp_C:OnLoadFailed(Request, Message)
  _G.NRCResourceManager:UnLoadRes(Request)
end

return UMG_Login_StrongPopUp_C
