local UMG_HomeVisitPanel_C = _G.NRCPanelBase:Extend("UMG_HomeVisitPanel_C")

function UMG_HomeVisitPanel_C:OnConstruct()
  self.Explanation:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:OnAddEventListener()
  self:InitHomeRoomNames()
end

function UMG_HomeVisitPanel_C:InitHomeRoomNames()
  local Fields = {
    self.NRCText_2,
    self.NRCText_3,
    self.NRCText_4,
    self.NRCText_5,
    self.NRCText_6
  }
  for i, v in ipairs(Fields) do
    local RoomConf = DataConfigManager:GetRoomConf(i)
    v:SetText(RoomConf.name)
  end
end

function UMG_HomeVisitPanel_C:OnActive()
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_HomeVisitPanel_C:OnActive")
  self:Init()
end

function UMG_HomeVisitPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
    return
  end
end

function UMG_HomeVisitPanel_C:OnAddEventListener()
  self:AddButtonListener(self.Explanation.btnLevelUp, self.OnShowComfortTips)
  self:AddButtonListener(self.Button_Close, self.OnReqClose)
end

function UMG_HomeVisitPanel_C:OnPcClose()
  self:OnReqClose()
end

function UMG_HomeVisitPanel_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  _G.NRCAudioManager:PlaySound2DAuto(41400007, "UMG_HomeVisitPanel_C:OnReqClose")
  self:PlayAnimation(self.Out)
end

function UMG_HomeVisitPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:OnClose()
  end
end

function UMG_HomeVisitPanel_C:OnShowComfortTips()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeComfortLevelTips)
end

function UMG_HomeVisitPanel_C:Init()
  local Curr = DataConfigManager:GetRoomConf(HomeIndoorSandbox.Server.WorldData.RoomLevel)
  self.HomePhotos:SetPath(Curr and Curr.look or "")
  self.NRCText_2:SetText(Curr and Curr.name or "")
  self.Text_ComfortLevel:SetText(HomeIndoorSandbox.Server.WorldData.HomeComfortLevel)
  local InformationList = HomeIndoorSandbox.Server:GetHomeInformation()
  self.NRCGridView_62:InitGridView(InformationList)
  self.Text_HomeName:SetText(HomeIndoorSandbox.Server.WorldData.HomeName)
  self.HomeName:SetActiveWidgetIndex(Curr.id - 1)
  self:Refresh()
end

function UMG_HomeVisitPanel_C:Refresh()
  local RecordList = HomeIndoorSandbox.Server.VisitData:GetRecordList()
  self.NRCScrollView_173:InitList(RecordList)
end

return UMG_HomeVisitPanel_C
