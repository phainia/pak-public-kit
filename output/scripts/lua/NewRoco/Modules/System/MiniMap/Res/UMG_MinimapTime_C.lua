require("UnLuaEx")
local LoadingUIModuleEvent = reload("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local UMG_MinimapTime_C = NRCClass()

function UMG_MinimapTime_C:Construct()
  self.DeltaTime = 0
  self.UpdateTime = true
  self:GetGameTime()
  self.Interval = _G.DataConfigManager:GetGlobalConfigNumByKeyType("ui_time_refresh_gap", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG)
  if self.Interval == nil then
    self.Interval = 300
  end
  _G.NRCEventCenter:RegisterEvent("UMG_MinimapTime_C", self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.GetGameTime)
  _G.NRCEventCenter:RegisterEvent("UMG_MinimapTime_C", self, _G.NRCGlobalEvent.OnPingUpdate, self.OnUpdateRtt)
  _G.NRCEventCenter:RegisterEvent("UMG_MinimapTime_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.VISIT_OWNER_CHANGED, self.SetCanUpdateTime)
  self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local curRTT = _G.ZoneServer:GetTConndRTT()
  self:OnUpdateRtt(curRTT)
end

function UMG_MinimapTime_C:Destruct()
  _G.NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.GetGameTime)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnPingUpdate, self.OnUpdateRtt)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.VISIT_OWNER_CHANGED, self.SetCanUpdateTime)
  self:CancelDelayFunc()
end

function UMG_MinimapTime_C:DelayRefreshTime()
  self.delayFuncID = DelayManager:DelaySeconds(self.Interval, self.RefreshUI, self)
end

function UMG_MinimapTime_C:RefreshUI()
  self:GetGameTime()
  self:CancelDelayFunc()
  self:DelayRefreshTime()
end

function UMG_MinimapTime_C:CancelDelayFunc()
  if self.delayFuncID then
    DelayManager:CancelDelayById(self.delayFuncID)
    self.delayFuncID = nil
  end
end

function UMG_MinimapTime_C:SetReconnect(isReconnecting, Rtt)
  if isReconnecting then
    self.NRCImagesignal_CD:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.CD_loop, 0, 0)
    self.NRCImagesignal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Signal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FullSignal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NRCImagesignal_CD:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:StopAnimation(self.CD_loop)
    self.NRCImagesignal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Signal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FullSignal:SetVisibility(UE4.ESlateVisibility.Visible)
    if Rtt <= 100 then
      self.NRCSignalImage_1:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCSignalImage_2:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCSignalImage_3:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif Rtt <= 200 then
      self.NRCSignalImage_1:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCSignalImage_2:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCSignalImage_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.NRCSignalImage_1:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCSignalImage_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NRCSignalImage_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.CurColorMap ~= nil then
    self.NRCImagesignal_CD:SetColorAndOpacity(self.CurColorMap[2])
    self.NRCText_117:SetColorAndOpacity(self.CurColorMap[1])
    self.NRCSignalImage_1:SetColorAndOpacity(self.CurColorMap[2])
    self.NRCSignalImage_2:SetColorAndOpacity(self.CurColorMap[2])
    self.NRCSignalImage_3:SetColorAndOpacity(self.CurColorMap[2])
  end
end

function UMG_MinimapTime_C:OnDisconnect()
  if _G.ZoneServer.ZoneServerKickOut:IsKickOutNeedReconnect() then
    self:OnUpdateRtt(888)
  else
    self:OnUpdateRtt(999)
  end
end

function UMG_MinimapTime_C:OnUpdateRtt(NewPingInMs)
  if not self.Level1ColorMap then
    self.Level1ColorMap = {
      UE4.UNRCStatics.HexToSlateColor("#73C615FF"),
      UE4.UNRCStatics.HexToLinearColor("#73C615FF")
    }
    self.Level2ColorMap = {
      UE4.UNRCStatics.HexToSlateColor("#FFC65FFF"),
      UE4.UNRCStatics.HexToLinearColor("#FFC65FFF")
    }
    self.Level3ColorMap = {
      UE4.UNRCStatics.HexToSlateColor("#C84949FF"),
      UE4.UNRCStatics.HexToLinearColor("#C84949FF")
    }
  end
  local Rtt = NewPingInMs or 999
  Rtt = math.min(999, math.max(1, Rtt))
  self.CurColorMap = nil
  if Rtt <= 100 then
    self.CurColorMap = self.Level1ColorMap
  elseif Rtt <= 200 then
    self.CurColorMap = self.Level2ColorMap
  else
    self.CurColorMap = self.Level3ColorMap
  end
  self.NRCText_117:SetText(tostring(Rtt) .. "ms")
  self:SetReconnect(_G.ZoneServer.ZoneServerGCloud:IsReconnecting(), Rtt)
end

function UMG_MinimapTime_C:SetCanUpdateTime()
  if _G.DataModelMgr.PlayerDataModel:IsVisitState() then
    self.UpdateTime = false
  else
    self.UpdateTime = true
  end
end

function UMG_MinimapTime_C:GetGameTime()
  local time = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
  if time and type(time) == "number" then
    self:SetGameTime(time)
  end
end

function UMG_MinimapTime_C:SetGameTime(Time)
  local time = Time
  local hour = math.floor(time / 3600)
  local min = math.floor((time - hour * 3600) / 60)
  if min < 10 then
    min = "0" .. min
  end
  if hour < 10 then
    hour = "0" .. hour
  end
  local timetext = hour .. ":" .. min
  self.Time:SetText(timetext)
end

function UMG_MinimapTime_C:SetWeatherIcon()
end

return UMG_MinimapTime_C
