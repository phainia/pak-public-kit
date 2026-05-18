local SeasonIntegrationModuleEvent = require("NewRoco.Modules.System.SeasonIntegration.SeasonIntegrationModuleEvent")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local SeasonIntegrationModule = NRCModuleBase:Extend("SeasonIntegrationModule")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")

function SeasonIntegrationModule:OnConstruct()
  _G.SeasonIntegrationModuleCmd = reload("NewRoco.Modules.System.SeasonIntegration.SeasonIntegrationModuleCmd")
  self.data = self:SetData("SeasonIntegrationModuleData", "NewRoco.Modules.System.SeasonIntegration.SeasonIntegrationModuleData")
  _G.NRCEventCenter:RegisterEvent(self.name, self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinishNtyAckEnd)
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SEASON_INFO_RSP, self.OnSeasonInfoRsp)
  self.seasonInfo = nil
  self:RegPanel("SeasonIntegrationPopUp", "UMG_SeasonIntegrationPopUp", Enum.UILayerType.UI_LAYER_POPUP, true, nil, nil, true)
  self:RegPanel("SeasonalActivities", "UMG_SeasonalActivities", Enum.UILayerType.UI_LAYER_POPUP, nil, nil, nil, false)
end

function SeasonIntegrationModule:OnDestruct()
  if self.delayHandler then
    _G.DelayManager:CancelDelayById(self.delayHandler)
    self.delayHandler = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SEASON_INFO_RSP, self.OnSeasonInfoRsp)
end

function SeasonIntegrationModule:OpenSeasonIntegrationPanel()
  if self.seasonInfo then
    local seasonConf = _G.DataConfigManager:GetSeasonConf(self.seasonInfo.season_id)
    if seasonConf then
      local umgPath = string.format("/Game/NewRoco/Modules/System/SeasonIntegration/Res/%s", seasonConf.umg_part)
      local panelData = self:GetPanelData("SeasonIntegrationPanel")
      panelData.panelPath = NRCUtils.FormatBlueprintAssetPath(umgPath)
      self:OpenPanel("SeasonIntegrationPanel")
    end
  end
end

function SeasonIntegrationModule:GetSeasonInfo()
  return self.seasonInfo
end

function SeasonIntegrationModule:OnActive()
end

function SeasonIntegrationModule:OnRelogin()
end

function SeasonIntegrationModule:OnDeactive()
end

function SeasonIntegrationModule:OnEnterSceneFinishNtyAckEnd(notify, isReconnecting, isEnteringCell)
  Log.Info("SeasonIntegrationModule:OnEnterSceneFinishNtyAckEnd isEnteringCell", isEnteringCell)
  if isEnteringCell then
    local reqMsg = _G.ProtoMessage:newZoneSeasonInfoReq()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SEASON_INFO_REQ, reqMsg, self, self.OnSeasonInfoRsp, nil, false)
  end
end

function SeasonIntegrationModule:OnSeasonInfoRsp(rsp)
  Log.Info("SeasonIntegrationModule:OnSeasonInfoRsp ret_code season_id", rsp.ret_info.ret_code, rsp.season_id)
  if rsp and rsp.ret_info and 0 == rsp.ret_info.ret_code then
    if rsp.season_id and 0 ~= rsp.season_id then
      if not self.bRegPanel then
        self:RegPanel("SeasonIntegrationPanel", "", Enum.UILayerType.UI_LAYER_FULLSCREEN, nil, nil, nil, false)
        self:RegPanel("SeasonBeginsTips", "", Enum.UILayerType.UI_LAYER_POPUP)
        self.bRegPanel = true
      end
      self.seasonInfo = rsp
      if self.seasonInfo then
        _G.NRCEventCenter:DispatchEvent(SeasonIntegrationModuleEvent.OnSeasonInfoChange)
      end
    elseif self.seasonInfo then
      self.seasonInfo = nil
      _G.NRCEventCenter:DispatchEvent(SeasonIntegrationModuleEvent.OnSeasonInfoChange)
    end
  end
end

function SeasonIntegrationModule:ShowSeasonBeginsTips(tipObject)
  if not self.seasonInfo then
    Log.Warning("SeasonIntegrationModule:ShowSeasonBeginsTips season info is nil")
    return
  end
  local seasonConf = _G.DataConfigManager:GetSeasonConf(self.seasonInfo.season_id)
  if seasonConf and seasonConf.popup_path then
    local umgPath = string.format("/Game/NewRoco/Modules/System/SeasonIntegration/Res/%s", seasonConf.popup_path)
    local panelData = self:GetPanelData("SeasonBeginsTips")
    panelData.panelPath = NRCUtils.FormatBlueprintAssetPath(umgPath)
    local delaySec = _G.DataConfigManager:GetSeasonGlobalConfig(9).num / 1000
    self.delayHandler = _G.DelayManager:DelaySeconds(delaySec, function()
      self:OpenPanel("SeasonBeginsTips", tipObject)
      local req = _G.ProtoMessage:newZoneSetSeasonPopupReq()
      req.season_id = self.seasonInfo.season_id
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SET_SEASON_POPUP_REQ, req, self, self.OnSetSeasonPopupRsp, false, false)
    end)
  end
end

function SeasonIntegrationModule:SendZoneSetSeasonFirstPopReq(seasonPagePlayType)
  if not self.seasonInfo then
    Log.Error("SeasonIntegrationModule:SendZoneSetSeasonFirstPopReq seasonInfo is nil")
    return
  end
  Log.Info("SeasonIntegrationModule:SendZoneSetSeasonFirstPopReq", self.seasonInfo.season_id, seasonPagePlayType)
  local req = _G.ProtoMessage.newZoneSetSeasonFirstPopReq()
  req.season_id = self.seasonInfo.season_id
  req.pop_type = seasonPagePlayType
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SET_SEASON_FIRST_POP_REQ, req, self, self.OnZoneSetSeasonFirstPopRsp, false, false)
end

function SeasonIntegrationModule:OpenSeasonPopup(seasonId)
  if not self.seasonInfo then
    Log.Error("SeasonIntegrationModule:OpenSeasonPopup seasonInfo is nil")
    return
  end
  seasonId = seasonId or self.seasonInfo.season_id
  local seasonConf = _G.DataConfigManager:GetSeasonConf(seasonId)
  if not seasonConf then
    Log.Error("SeasonIntegrationModule:OpenSeasonPopup seasonConf is nil season_id = ", seasonId)
    return
  end
  self:OpenPanel("SeasonalActivities", seasonId)
end

function SeasonIntegrationModule:OpenSeasonIntegrationPopUp(tipsID)
  self:OpenPanel("SeasonIntegrationPopUp", tipsID)
end

function SeasonIntegrationModule:OnZoneSetSeasonFirstPopRsp(rsp)
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    Log.Info("SeasonIntegrationModule:OnZoneSetSeasonFirstPopRsp", rsp.season_id, rsp.pop_type, rsp.pop_time)
    if self.seasonInfo ~= nil and self.seasonInfo.season_id == rsp.season_id then
      if rsp.pop_type == ProtoEnum.SeasonPagePlayType.SPPT_PV then
        self.seasonInfo.season_pv_time = rsp.pop_time
      elseif rsp.pop_type == ProtoEnum.SeasonPagePlayType.SPPT_POP_WINDOWS then
        self.seasonInfo.season_pop_windows_time = rsp.pop_time
      end
      _G.NRCEventCenter:DispatchEvent(SeasonIntegrationModuleEvent.OnSeasonInfoChange)
    end
  else
    Log.Error("SeasonIntegrationModule:OnZoneSetSeasonFirstPopRsp", rsp.ret_info.ret_code)
  end
end

function SeasonIntegrationModule:OnSetSeasonPopupRsp(rsp)
  if rsp.ret_info and 0 == rsp.ret_info.ret_code and self.seasonInfo then
    self.seasonInfo.popup_time = 1
  end
end

function SeasonIntegrationModule:UpdateSeasonInfo(seasonInfo)
  self.seasonInfo = seasonInfo
end

function SeasonIntegrationModule:RegPanel(name, path, layer, customDisableRendering, touchCount, isSingleTouchPanel, enablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/SeasonIntegration/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = customDisableRendering or false
  registerData.touchCount = touchCount
  registerData.isSingleTouchPanel = isSingleTouchPanel
  registerData.enablePcEsc = enablePcEsc and enablePcEsc or false
  self:RegisterPanel(registerData)
end

return SeasonIntegrationModule
