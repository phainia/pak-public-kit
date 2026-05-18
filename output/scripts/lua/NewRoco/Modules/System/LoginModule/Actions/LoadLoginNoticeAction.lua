local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local Base = NRCModeAction
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoadLoginNoticeAction = Base:Extend("LoadLoginNoticeAction")

function LoadLoginNoticeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.noticeList = nil
  self.curOnlyOnceNoticeIndex = nil
end

function LoadLoginNoticeAction:OnEnter()
  self:Log("OnEnter")
  _G.NRCEventCenter:RegisterEvent("LoadLoginNoticeAction", self, LoginModuleEvent.TriggerNextForcePopUpNotice, self.TriggerNextOnlyForceNoticeNextFrame)
  _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.LoadLoginNoticeData, self, self.OnLoadLoginNoticeDataCallback)
end

function LoadLoginNoticeAction:OnExit()
  self:Log("Exit")
  self.noticeList = nil
  self.curOnlyOnceNoticeIndex = nil
  self.SaveData = nil
  _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.CancelLoadLoginNoticeCallback)
  _G.NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.TriggerNextForcePopUpNotice, self.TriggerNextOnlyForceNotice)
end

function LoadLoginNoticeAction:OnLoadLoginNoticeDataCallback(noticeList)
  self:Log("OnLoadLoginNoticeDataCallback")
  self.noticeList = noticeList
  if UE4.UNoticeStatics.IsLoginNotice() then
    self:TriggerNextOnlyForceNotice()
  end
end

function LoadLoginNoticeAction:TriggerNextOnlyForceNoticeNextFrame()
  self.bTrigger = true
end

function LoadLoginNoticeAction:OnTick(DeltaTime)
  if self.bTrigger then
    self:TriggerNextOnlyForceNotice()
    self.bTrigger = false
  end
end

function LoadLoginNoticeAction:TriggerNextOnlyForceNotice()
  local SaveData = UE4.UGameplayStatics.LoadGameFromSlot("AnnouncementRedPoint", 0)
  Log.Info("TriggerNextOnlyForceNotice ", self.curOnlyOnceNoticeIndex, "self.SaveData ", self.SaveData and "True" or "False", "self.noticeList ", self.noticeList and "True" or "False")
  if not self.noticeList then
    return
  end
  local index = (self.curOnlyOnceNoticeIndex or 0) + 1
  self:Log("total notice count: ", #self.noticeList, "current index: ", index)
  while index <= #self.noticeList do
    local noticeInfo = self.noticeList[index]
    if noticeInfo and noticeInfo.OnlyOnce then
      local found = nil ~= SaveData and SaveData.OnlyOnceDic:Find(noticeInfo.ID)
      if not found then
        self.curOnlyOnceNoticeIndex = index
        self:Log("trying to show ", index)
        _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.OpenStrongPopUpPanel, noticeInfo)
        return
      end
    end
    index = index + 1
  end
end

function LoadLoginNoticeAction:OnLoadSaveDataSuccess()
  if UE4.UNoticeStatics.IsLoginNotice() then
    self:TriggerNextOnlyForceNotice()
  end
end

function LoadLoginNoticeAction:OnLoadFailed(Request, Message)
  _G.NRCResourceManager:UnLoadRes(Request)
end

return LoadLoginNoticeAction
