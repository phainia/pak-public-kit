local TravelModule = NRCModuleBase:Extend("TravelModule")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")

function TravelModule:OnConstruct()
  _G.TravelModuleCmd = reload("NewRoco.Modules.System.Travel.TravelModuleCmd")
  self.data = self:SetData("TravelModuleData", "NewRoco.Modules.System.Travel.TravelModuleData")
  self:RegisterCmd(_G.TravelModuleCmd.GetCampLevelConf, self.GetCampLevelConf)
  self:RegisterCmd(_G.TravelModuleCmd.GetCampLevelConfs, self.GetCampLevelConfs)
  self:RegisterCmd(_G.TravelModuleCmd.OpenTravelPanel, self.OnCmdOpenTravelPanel)
  self:RegisterCmd(_G.TravelModuleCmd.OpenTravelMainPanel, self.OnCmdOpenTravelMainPanel)
  self:RegisterCmd(_G.TravelModuleCmd.OpenTravelBeginPanel, self.OnCmdOpenTravelBeginPanel)
  self:RegisterCmd(_G.TravelModuleCmd.OpenTravelLookBackPanel, self.OnCmdOpenTravelLookBackPanel)
  self:RegisterCmd(_G.TravelModuleCmd.OpenTravelPetDropDownListPanel, self.OnCmdOpenTravelPetDropDownListPanel)
  self:RegisterCmd(_G.TravelModuleCmd.OpenTravelMainMapPanel, self.OnCmdOpenTravelMainMapPanel)
  self:RegisterCmd(_G.TravelModuleCmd.IsTravel, self.IsTravel)
  self:RegisterCmd(_G.TravelModuleCmd.IsFinishTravel, self.IsFinishTravel)
  self:RegisterCmd(_G.TravelModuleCmd.GetSelectTimeTabIndex, self.OnCmdGetSelectTimeTabIndex)
  self:RegisterCmd(_G.TravelModuleCmd.SelectTimeTab, self.OnCmdSelectTimeTab)
  self:RegisterCmd(_G.TravelModuleCmd.GetTravelInfos, self.GetTravelInfos)
  self:RegisterCmd(_G.TravelModuleCmd.GetTravelInfo, self.GetTravelInfo)
  self:RegisterCmd(_G.TravelModuleCmd.SelectTravelPet, self.SelectTravelPet)
  self:RegisterCmd(_G.TravelModuleCmd.GetSelectTravelPet, self.GetSelectTravelPet)
  self:RegisterCmd(_G.TravelModuleCmd.GetSelectTravelPetIndex, self.GetSelectTravelPetIndex)
  self:RegisterCmd(_G.TravelModuleCmd.ClearSelectTravelPet, self.ClearSelectTravelPet)
  self:RegisterCmd(_G.TravelModuleCmd.GetPetIsTravel, self.OnCmdGetPetIsTravel)
  self:RegisterCmd(_G.TravelModuleCmd.UpdateTravelInfos, self.OnCmdUpdateTravelInfos)
  self:RegisterCmd(_G.TravelModuleCmd.ZoneStartPetTravelReq, self.OnCmdZoneStartPetTravelReq)
  self:RegisterCmd(_G.TravelModuleCmd.ZoneRecallPetTravelReq, self.OnCmdZoneRecallPetTravelReq)
  self:RegisterCmd(_G.TravelModuleCmd.ZoneCompletePetTravelReq, self.OnCmdZoneCompletePetTravelReq)
  self:RegisterCmd(_G.TravelModuleCmd.OnGetSelectPetSkillTipsItem, self.OnGetSelectPetSkillTipsItem)
  self:RegisterCmd(_G.TravelModuleCmd.OnSetSelectPetSkillTipsItem, self.OnSetSelectPetSkillTipsItem)
  self:RegisterCmd(_G.TravelModuleCmd.SetTravelItemClickAble, self.OnCmdSetTravelItemClickAble)
  self:RegisterCmd(_G.TravelModuleCmd.ZoneGmSetPetTravelCompleteReq, self.ZoneGmSetPetTravelCompleteReq)
  self:RegisterCmd(_G.TravelModuleCmd.OnCmdZoneCompleteAllPetTravelReq, self.OnCmdZoneCompleteAllPetTravelReq)
  self:RegisterCmd(_G.TravelModuleCmd.OnCmdZoneStartAllPetTravelAgainReq, self.OnCmdZoneStartAllPetTravelAgainReq)
  self:RegPanel("TravelPanel", "UMG_Travel", _G.Enum.UILayerType.UI_LAYER_POPUP, true, nil, nil, true)
  self:RegPanel("TravelMainPanel", "UMG_Travel_Main", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN, nil, nil, nil, nil, true)
  self:RegPanel("TravelBeginPanel", "UMG_Travel_Begin", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("TravelLookBackPanel", "UMG_Travel_LookBack", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("TravelPetDropDownListPanel", "UMG_Travel_PetDropDownList", _G.Enum.UILayerType.UI_LAYER_POPUP, nil, nil, nil, nil, true)
  self:RegPanel("TravelMainMapPanel", "UMG_Travel_MainMap", _G.Enum.UILayerType.UI_LAYER_POPUP, nil, "open", "close", nil, true)
  self:RegPanel("TravelAllBegin", "UMG_Travel_LookBack2", _G.Enum.UILayerType.UI_LAYER_POPUP, nil, nil, "close")
  _G.NRCEventCenter:RegisterEvent("TravelModule", self, SceneEvent.OnRelogin, self.OnRest)
end

function TravelModule:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnRelogin, self.OnRest)
end

function TravelModule:GetCampLevelConf(contentId, travelLv)
  return self.data:GetCampLevelConf(contentId, travelLv)
end

function TravelModule:IsTravel()
  local infos = self.data:GetTravelInfos()
  if infos and #infos > 0 then
    return true
  end
  return false
end

function TravelModule:IsFinishTravel()
  local infos = self.data:GetTravelInfos()
  if infos and #infos > 0 then
    for i, info in pairs(infos) do
      if info.travel_complete then
        return true
      end
    end
  end
  local playerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo()
  if playerInfo.red_point_info and playerInfo.red_point_info.group_info then
    for i, red in pairs(playerInfo.red_point_info.group_info) do
      if red.reason_type == _G.Enum.RedPointReason.RPR_PET_TRAVEL_COMPLETE and red.point_data then
        return true
      end
    end
  end
  return false
end

function TravelModule:GetCampLevelConfs(contentId)
  return self.data:GetCampLevelConfs(contentId)
end

function TravelModule:OnCmdOpenTravelPanel(info, downTime, isMax)
  local isVisitState = _G.DataModelMgr.PlayerDataModel:IsVisitState()
  local isVisitOwner = _G.DataModelMgr.PlayerDataModel:IsVisitOwner()
  if isVisitState and not isVisitOwner then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Track_ban_online)
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "MainBigMap").TELEPORT
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BigMapModule", "MainBigMap", touchReasonType)
    return
  end
  self:OpenPanel("TravelPanel", info, downTime, isMax)
end

function TravelModule:OnCmdOpenTravelMainPanel(arg)
  self:OpenPanel("TravelMainPanel", arg)
end

function TravelModule:OnCmdOpenTravelBeginPanel(petDatas, conf)
  self:OpenPanel("TravelBeginPanel", petDatas, conf)
end

function TravelModule:OnCmdOpenTravelLookBackPanel(contentId, travelLv, petDatas, rewards)
  self:OpenPanel("TravelLookBackPanel", contentId, travelLv, petDatas, rewards)
end

function TravelModule:OnCmdOpenTravelPetDropDownListPanel(arg)
  self:OpenPanel("TravelPetDropDownListPanel", arg)
end

function TravelModule:OpenTravelMainMapPanel(arg)
  self:OpenPanel("TravelMainMapPanel", arg)
end

function TravelModule:OpenTravelAllRewardPanel(arg)
  local type = 1
  if self:HasPanel("TravelAllBegin") then
    local panel = self:GetPanel("TravelAllBegin")
    panel:OnUpdatePanel(type, arg)
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "MainBigMap").GETALL
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BigMapModule", "MainBigMap", touchReasonType)
  else
    self:OpenPanel("TravelAllBegin", type, arg)
  end
end

function TravelModule:OpenTravelAllStartPanel(arg)
  local type = 2
  if self:HasPanel("TravelAllBegin") then
    local panel = self:GetPanel("TravelAllBegin")
    panel:OnUpdatePanel(type, arg)
  else
    self:OpenPanel("TravelAllBegin", type, arg)
  end
end

function TravelModule:OnCmdOpenTravelMainMapPanel(action)
  local req = _G.ProtoMessage:newZoneGetPetTravelInfoReq()
  self.CacheAction = action
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PET_TRAVEL_INFO_REQ, req, self, self.OnZoneGetPetTravelInfoRsp)
end

function TravelModule:OnZoneGetPetTravelInfoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.data:SetTravelInfo(rsp.travel_info)
    self:OpenTravelMainMapPanel(self.data:GetTravelInfos())
  end
end

function TravelModule:ZoneGmSetPetTravelCompleteReq(petGids)
  local req = _G.ProtoMessage:newZoneGmSetPetTravelCompleteReq()
  req.pet_gid = petGids
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PET_TRAVEL_COMPLETE_REQ, req, self, self.ZoneGmSetPetTravelCompleteRsp)
end

function TravelModule:ZoneGmSetPetTravelCompleteRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    Log.Error("travel complete!\239\188\129")
    self:OnCmdUpdateTravelInfos()
  end
end

function TravelModule:OnCmdZoneCompleteAllPetTravelReq()
  local req = _G.ProtoMessage:newZoneCompleteAllPetTravelReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_COMPLETE_ALL_PET_TRAVEL_REQ, req, self, self.OnZoneCompleteAllPetTravelRsp)
end

function TravelModule:OnZoneCompleteAllPetTravelRsp(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.travel_info and #rsp.travel_info > 0 then
    self:OpenTravelAllRewardPanel(rsp.travel_info)
  end
  self:OnCmdUpdateTravelInfos()
end

function TravelModule:OnCmdZoneStartAllPetTravelAgainReq(travelInfos)
  local req = _G.ProtoMessage:newZoneStartAllPetTravelAgainReq()
  req.travel_info = travelInfos
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_START_ALL_PET_TRAVEL_AGAIN_REQ, req, self, self.OnZoneStartAllPetTravelAgainRsp)
end

function TravelModule:OnZoneStartAllPetTravelAgainRsp(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.travel_info and #rsp.travel_info > 0 then
    self:OpenTravelAllStartPanel(rsp.travel_info)
  end
  self:OnCmdUpdateTravelInfos()
end

function TravelModule:OnCmdZoneCompleteAllPetTravelReq()
  local req = _G.ProtoMessage:newZoneCompleteAllPetTravelReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_COMPLETE_ALL_PET_TRAVEL_REQ, req, self, self.OnZoneCompleteAllPetTravelRsp)
end

function TravelModule:OnCmdUpdateTravelInfos()
  local req = _G.ProtoMessage:newZoneGetPetTravelInfoReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PET_TRAVEL_INFO_REQ, req, self, self.OnUpdateTravelInfos)
end

function TravelModule:OnUpdateTravelInfos(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.data:SetTravelInfo(rsp.travel_info)
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OnUpdateTravelInfos, rsp.travel_info)
    _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnUpdateTravelInfos, rsp.travel_info)
  end
end

function TravelModule:OnCmdSelectTimeTab(index, data)
  self.data:SetSelectTimeTabIndex(index)
  _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnSelectTimeTab, index, data)
end

function TravelModule:OnCmdGetSelectTimeTabIndex()
  return self.data:GetSelectTimeTabIndex()
end

function TravelModule:GetTravelInfos()
  return self.data:GetTravelInfos()
end

function TravelModule:GetTravelInfo(npc_refresh_id)
  local infos = self.data:GetTravelInfos()
  for key, info in pairs(infos) do
    if npc_refresh_id == info.camp_content_id then
      return info
    end
  end
  return nil
end

function TravelModule:SelectTravelPet(key, gid, baseId, level)
  self.data:SelectTravelPet(key, gid, baseId, level)
  _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnUpdateSelectTravelPet)
end

function TravelModule:GetSelectTravelPet()
  return self.data:GetSelectTravelPet()
end

function TravelModule:GetSelectTravelPetIndex()
  return self.data:GetSelectTravelPetIndex()
end

function TravelModule:OnCmdGetPetIsTravel(gid)
  local infos = self:GetTravelInfos()
  if infos then
    for i = 1, #infos do
      local info = infos[i]
      for j = 1, #info.pet_gid do
        local traveGid = info.pet_gid[j]
        if traveGid == gid then
          return true
        end
      end
    end
  else
    return false
  end
  return false
end

function TravelModule:ClearSelectTravelPet()
  self.data:ClearSelectTravelPet()
  _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnUpdateSelectTravelPet)
end

function TravelModule:OnCmdZoneStartPetTravelReq(contentId, travelLv)
  local req = _G.ProtoMessage:newZoneStartPetTravelReq()
  req.camp_content_id = contentId
  req.pet_gid = {}
  local dic = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetSelectTravelPet)
  if #dic < 2 then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.travelmodule_1)
    return
  end
  self.CachePetDatas = {}
  self.CacheCampLevelConf = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, contentId, travelLv)
  for key, value in pairs(dic) do
    table.insert(self.CachePetDatas, value)
    table.insert(req.pet_gid, value.gid)
  end
  req.travel_lv = travelLv
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_START_PET_TRAVEL_REQ, req, self, self.OnZoneStartPetTravelRsp, true)
end

function TravelModule:OnZoneStartPetTravelRsp(rsp)
  if 0 == rsp.ret_info.ret_code and self.CachePetDatas then
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.OpenTravelBeginPanel, self.CachePetDatas, self.CacheCampLevelConf)
  end
  self.CachePetDatas = nil
  self.CacheCampLevelConf = nil
end

function TravelModule:OnCmdZoneRecallPetTravelReq(contentId)
  self.CacheContentId = contentId
  local IsFinishTravel = false
  local travelInfos = self.data:GetTravelInfos()
  for i, info in pairs(travelInfos) do
    for i, info in pairs(travelInfos) do
      if info.camp_content_id == contentId then
        IsFinishTravel = info.travel_complete
      end
    end
  end
  if IsFinishTravel then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.travelmodule_2)
    return
  end
  local req = _G.ProtoMessage:newZoneRecallPetTravelReq()
  req.camp_content_id = contentId
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECALL_PET_TRAVEL_REQ, req, self, self.OnZoneRecallPetTravelRsp)
end

function TravelModule:OnZoneRecallPetTravelRsp(rsp)
  if 0 == rsp.ret_info.ret_code and self.CacheContentId then
    _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnOutTravel, self.CacheContentId)
  end
  self.CacheContentId = nil
end

function TravelModule:OnCmdZoneCompletePetTravelReq(contentId, petInfos)
  local req = _G.ProtoMessage:newZoneCompletePetTravelReq()
  req.camp_content_id = contentId
  self.CacheContentId = contentId
  self.CachePetInfos = petInfos
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_COMPLETE_PET_TRAVEL_REQ, req, self, self.OnZoneCompletePetTravelRsp, true, true)
end

function TravelModule:OnZoneCompletePetTravelRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    if self.CacheContentId then
      local rewards = rsp.ret_info.goods_reward.rewards
      local petDatas = self.CachePetInfos
      local level = 1
      local content_id = self.CacheContentId
      local travelInfos = self.data:GetTravelInfos()
      for i, v in pairs(travelInfos) do
        if v.camp_content_id == content_id then
          level = v.camp_lv
        end
      end
      self:OnCmdOpenTravelLookBackPanel(content_id, level, petDatas, rewards)
    end
  else
    local key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
  self.CacheContentId = nil
  self.CachePetInfos = nil
end

function TravelModule:OnRest()
  if self:HasPanel("UMG_Travel") then
  end
end

function TravelModule:OnSetSelectPetSkillTipsItem(iconItem)
  self.PetListItem = iconItem
end

function TravelModule:OnGetSelectPetSkillTipsItem()
  return self.PetListItem
end

function TravelModule:RegPanel(name, path, layer, customDisableRendering, openAnimName, closeAnimName, isSingleTouchPanel, disablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/Travel/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = customDisableRendering or false
  registerData.openAnimName = openAnimName
  registerData.closeAnimName = closeAnimName
  registerData.isSingleTouchPanel = isSingleTouchPanel
  registerData.enablePcEsc = not disablePcEsc
  self:RegisterPanel(registerData)
end

function TravelModule:OnCmdSetTravelItemClickAble(panelName, clickable)
  local panel = self:GetPanel(panelName)
  if panel then
    panel:SetTravelItemClickAble(clickable)
  end
end

return TravelModule
