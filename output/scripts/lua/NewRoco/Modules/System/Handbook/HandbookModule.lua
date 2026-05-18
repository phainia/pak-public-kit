local RedPointModuleEvent = require("NewRoco.Modules.System.RedPoint.RedPointModuleEvent")
local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local NPCShopUIModuleCmd = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleCmd")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local ProtoEnum = require("Data.PB.ProtoEnum")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local HandbookModuleEnum = reload("NewRoco.Modules.System.Handbook.HandbookModuleEnum")
local NRCPanelDynamicData = require("Core.NRCPanel.NRCPanelDynamicData")
local HandbookModule = NRCModuleBase:Extend("HandbookModule")

function HandbookModule:OnConstruct()
  _G.HandbookModuleCmd = reload("NewRoco.Modules.System.Handbook.HandbookModuleCmd")
  self.data = self:SetData("HandbookModuleData", "NewRoco.Modules.System.Handbook.HandbookModuleData")
  self:RegisterCmd(HandbookModuleCmd.OpenHandbookCover, self.OnCmdOpenHandbookCoverPanel)
  self:RegisterCmd(HandbookModuleCmd.CloseHandbookCover, self.OnCmdCloseHandbookCoverPanel)
  self:RegisterCmd(HandbookModuleCmd.CloseHandbookCoverByPlayer, self.OnCmdCloseHandbookCoverByPlayer)
  self:RegisterCmd(HandbookModuleCmd.OpenHandbookPanel, self.OnCmdOpenHandbookPanel)
  self:RegisterCmd(HandbookModuleCmd.EnableHandbookPanel, self.EnableHandbookPanel)
  self:RegisterCmd(HandbookModuleCmd.PreLoadHandbookPanel, self.PreLoadHandbookPanel)
  self:RegisterCmd(HandbookModuleCmd.CloseHandbookPanel, self.OnCmdCloseHandbookPanel)
  self:RegisterCmd(HandbookModuleCmd.OpenHandbookByRewardItemId, self.OnCmdOpenHandbookByRewardItemId)
  self:RegisterCmd(HandbookModuleCmd.OpenHandbookTrophyPanel, self.OnOpenHandbookTrophyPanel)
  self:RegisterCmd(HandbookModuleCmd.SetSelectedItem, self.OnCmdSetSelectedItem)
  self:RegisterCmd(HandbookModuleCmd.ReversedSort, self.OnCmdReversedSort)
  self:RegisterCmd(HandbookModuleCmd.GetHandbookAward, self.OnCmdGetHandbookAward)
  self:RegisterCmd(HandbookModuleCmd.GetHandbookTopicAward, self.OnCmdGetHandbookTopicAward)
  self:RegisterCmd(HandbookModuleCmd.GetCurIndex, self.GetSelectedIndex)
  self:RegisterCmd(HandbookModuleCmd.SetStartState, self.OnCmdSetStartState)
  self:RegisterCmd(HandbookModuleCmd.OpenUpdatePrompt, self.OnCmdOpenUpdatePrompt)
  self:RegisterCmd(HandbookModuleCmd.OpenHandbookSubjectPanel, self.OnCmdOpenHandbookSubjectPanel)
  self:RegisterCmd(HandbookModuleCmd.SetSelectedItemIcon, self.OnChangSelectItemUIIcon)
  self:RegisterCmd(HandbookModuleCmd.CheckTopRedPoint, self.OnCmdCheckTopRedPoint)
  self:RegisterCmd(HandbookModuleCmd.OnOpenContentView, self.OnOpenContentView)
  self:RegisterCmd(HandbookModuleCmd.OpenHabitTips, self.OnCmdOpenHabitTips)
  self:RegisterCmd(HandbookModuleCmd.CloseHabitTips, self.OnCmdCloseHabitTips)
  self:RegisterCmd(HandbookModuleCmd.OpenHabitMap, self.OnCmdOpenHabitMap)
  self:RegisterCmd(HandbookModuleCmd.GetPetHandBookState, self.OnCmdGetPetHandBookState)
  self:RegisterCmd(HandbookModuleCmd.GetPetState, self.OnCmdGetPetState)
  self:RegisterCmd(HandbookModuleCmd.ShowHandBookTips, self.ShowHandBookTips)
  self:RegisterCmd(HandbookModuleCmd.OpenWorldHandbook, self.OnCmdOpenWorldHandbook)
  self:RegisterCmd(HandbookModuleCmd.IsShowWorldHandbook, self.OnCmdIsShowWorldHandbook)
  self:RegisterCmd(HandbookModuleCmd.GetHandbookLeftReversal, self.OnGetHandbookLeftReversal)
  self:RegisterCmd(HandbookModuleCmd.GetCurChangeAwardStateIndex, self.OnGetCurChangeAwardStateIndex)
  self:RegisterCmd(HandbookModuleCmd.SetCurChangeAwardStateIndex, self.OnSetCurChangeAwardStateIndex)
  self:RegisterCmd(HandbookModuleCmd.GetPetHandbookCurrentProgressTaskReward, self.OnCmdGetPetHandbookCurrentProgressTaskReward)
  self:RegisterCmd(HandbookModuleCmd.GetHandbookCoverInfos, self.OnCmdGetHandbookCoverInfos)
  self:RegisterCmd(HandbookModuleCmd.GetPetHandBookData, self.OnCmdGetPetHandBookData)
  self:RegisterCmd(HandbookModuleCmd.SetPetVisualParam, self.OnCmdSetPetVisualParam)
  self:RegisterCmd(HandbookModuleCmd.GetPetVisualParam, self.OnCmdGetPetVisualParam)
  self:RegisterCmd(HandbookModuleCmd.SetPetUIScaleAndOffsetAndImageRevert, self.OnSetPetUIScaleAndOffsetAndImageRevert)
  self:RegisterCmd(HandbookModuleCmd.GetDisableRewardAnimationState, self.OnGetDisableRewardAnimationState)
  self:RegisterCmd(HandbookModuleCmd.SetDisableRewardAnimationState, self.OnSetDisableRewardAnimationState)
  self:RegisterCmd(HandbookModuleCmd.SetClickTime, self.SetClickTime)
  self:RegisterCmd(HandbookModuleCmd.GetAccessHandbookData, self.OnCmdGetAccessHandbookData)
  self:RegisterCmd(HandbookModuleCmd.AreaHandbookChangePanel, self.OnCmdAreaHandbookChangePanel)
  self:RegisterCmd(HandbookModuleCmd.SelectAreaItem, self.OnCmdSelectAreaItem)
  self:RegisterCmd(HandbookModuleCmd.GetCurAreaHandbookEnum, self.OnCmdGetCurAreaHandbookEnum)
  self:RegisterCmd(HandbookModuleCmd.GetCurAreaHandbookId, self.OnCmdGetCurAreaHandbookId)
  self:RegisterCmd(HandbookModuleCmd.GetAreaHandbookInfo, self.OnCmdGetAreaHandbookInfo)
  self:RegisterCmd(HandbookModuleCmd.OnSearchHandbook, self.OnCmdSearchHandbook)
  self:RegisterCmd(HandbookModuleCmd.OnCmdOpenHandbookSearch, self.OnCmdOpenHandbookSearch)
  self:RegisterCmd(HandbookModuleCmd.OnCmdOpenDistrictMapGuide, self.OnCmdOpenDistrictMapGuide)
  self:RegisterCmd(HandbookModuleCmd.SetDistrictMapGuideRecordEnable, self.OnCmdSetDistrictMapGuideRecordEnable)
  self:RegisterCmd(HandbookModuleCmd.RecordDistrictMapGuideSelect, self.OnCmdRecordDistrictMapGuideSelect)
  self:RegisterCmd(HandbookModuleCmd.GetDistrictMapGuideSelectRecord, self.OnCmdGetDistrictMapGuideSelectRecord)
  self:RegisterCmd(HandbookModuleCmd.OnCmdOpenDazzlingPopUp, self.OnCmdOpenDazzlingPopUp)
  self:RegisterCmd(HandbookModuleCmd.OnCmdCloseDazzlingPopUp, self.OnCmdCloseDazzlingPopUp)
  self:RegisterCmd(HandbookModuleCmd.OnCmdGetCurAreaHandBookRedId, self.GetCurAreaHandBookRedId)
  self:RegisterCmd(HandbookModuleCmd.OnGetHandbookPetIds, self.OnGetHandbookPetIds)
  self:RegisterCmd(HandbookModuleCmd.IsContainHandbookPetId, self.IsContainHandbookPetId)
  self:RegisterCmd(HandbookModuleCmd.ResetComboBox, self.ResetComboBox)
  self:RegisterCmd(HandbookModuleCmd.OnCmdCheckItemInHandbook, self.OnCmdCheckItemInHandbook)
  self:RegisterCmd(HandbookModuleCmd.OnCmdZoneAddPetRecordReq, self.OnCmdZoneAddPetRecordReq)
  self:RegisterCmd(HandbookModuleCmd.GetPetHandbookRecordDataByPetBaseID, self.OnCmdGetPetHandbookRecordDataByPetBaseID)
  self:RegisterCmd(HandbookModuleCmd.SetUIParamByOperationType, self.OnCmdSetUIParamByOperationType)
  self:RegisterCmd(HandbookModuleCmd.UpdateProjectionIconInfo, self.OnCmdUpdateProjectionIconInfo)
  self:RegisterCmd(HandbookModuleCmd.GetAllPetHandbookConfs, self.OnCmdGetAllPetHandbookConfs)
  self:RegisterCmd(HandbookModuleCmd.GetHandbookCollectedPetsNum, self.OnCmdGetHandbookCollectedPetsNum)
  self:RegisterCmd(HandbookModuleCmd.OpenCollectionProgressTips, self.OnCmdOpenCollectionProgressTips)
  self:RegPanel("HandbookCover", "UMG_Handbook1", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN, nil, true, true, true)
  self:RegPanel("HandbookMain", "UMG_Handbook", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  self:RegPanel("HandbookTrophy", "UMG_Handbook_CollectRewards", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("HandBookUpdatePrompt", "UMG_Handbook_UpdatePrompt", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("HandbookSubject", "UMG_Handbook_Subject", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("HandbookHabitTips", "UMG_Handbook_HabitReminder", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("BookPrompt", "UMG_BookPrompt", _G.Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("HandBook_RegionalSelection", "UMG_HandBook_RegionalSelection", _G.Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("HandBookSearch", "UMG_Handbook_Search", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("DistrictMapGuide", "UMG_DistrictMapGuide", _G.Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("DazzlingPopUp", "UMG_Dazzling_PopUp", _G.Enum.UILayerType.UI_LAYER_POPUP, nil, nil, true)
  self:RegPanel("CollectionProgressTipsPanel", "UMG_CollectionProgressTips", _G.Enum.UILayerType.UI_LAYER_POPUP, nil, nil, true)
  NRCEventCenter:RegisterEvent("HandbookModule", self, SceneEvent.PlayerTeleportStart, self.OnPlayerTeleportStart)
  NRCEventCenter:RegisterEvent("RedPointModule", self, RedPointModuleEvent.RedPointChange, self.OnUpdateRedPointData)
  NRCEventCenter:RegisterEvent("HandbookModule", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
  NRCEventCenter:RegisterEvent("HandbookModule", self, LoadingUIModuleEvent.LOADING_UI_OPENED, self.OnLoadingUIOpened)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_HANDBOOK_CHANGE_NOTIFY, self.NewHandBook)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAY_ACTS_NOTIFY, self.OnSceneActionNotify)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_HANDBOOK_STAT_CHANGE_NOTIFY, self.OnStatChangeNotify)
  self.lastSelectedIndex = 0
  self.frameCount = 0
  self.SkipFrame = 3
  self.StateTime = 0
  self.EndTime = 600
  self.DataIsSucceed = true
  self.PetPos = nil
  self.curSelectCollectIdex = 0
  self.CurChangeAwardStateIndex = 0
  self.getAwardUnderWay = false
  self.PetStatVersion = nil
  self.LastPetStatReqTime = 0
  self.PetStatReqInterval = 30
end

function HandbookModule:OnActive()
end

function HandbookModule:OnDeactive()
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportStart, self.OnPlayerTeleportStart)
  NRCEventCenter:UnRegisterEvent(self, RedPointModuleEvent.RedPointChange, self.OnUpdateRedPointData)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_HANDBOOK_CHANGE_NOTIFY, self.NewHandBook)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAY_ACTS_NOTIFY, self.OnSceneActionNotify)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_HANDBOOK_STAT_CHANGE_NOTIFY, self.OnStatChangeNotify)
end

function HandbookModule:OnLogin(isRelogin)
  if isRelogin then
    self.data:InitData()
    self.data:CreatPetHandbookMainDataDic()
    self.getAwardUnderWay = false
    local curSelectData = self.data:GetSelectPetData()
    _G.NRCModuleManager:DoCmd(HandbookModuleCmd.SetDisableRewardAnimationState, false)
    if curSelectData then
      local selectHandbookId = self.data:GetSelectPetData().HandbookId
      local selectHandbookData = self.data:GetPetHandBookData(selectHandbookId)
      self.data:SetSelectPetData(selectHandbookData)
    end
    self.data.HandBookRewardStates = {}
    self.data:InitHandBookRewardStates()
  end
end

function HandbookModule:OnReconnect()
  self:CloseAllPanel()
end

function HandbookModule:OnLoadPanelRes()
  local ResListData = _G.NRCPanelResLoadData()
  ResListData.PreLoadResList = {}
  local areaHandbookCfgs = self.data.areaHandbookConfs
  for i, cfg in pairs(areaHandbookCfgs) do
    if 1 == cfg.id then
      table.insert(ResListData.PreLoadResList, cfg.cover_res)
      break
    end
  end
  return ResListData
end

function HandbookModule:OnCmdSetUIParamByOperationType(UIOperationType, Param)
  if self:HasPanel("HandbookMain") then
    local PanelInst = self:GetPanel("HandbookMain")
    if PanelInst and PanelInst.HandbookContent and PanelInst.HandbookContent.ProjectionIcon then
      PanelInst.HandbookContent:SetUIParamByOperationType(UIOperationType, Param)
    end
  end
end

function HandbookModule:OnCmdUpdateProjectionIconInfo(PetUIVisualParam)
  if self:HasPanel("HandbookMain") then
    local PanelInst = self:GetPanel("HandbookMain")
    if PanelInst and PanelInst.HandbookContent then
      PanelInst.HandbookContent:UpdateProjectionIconInfo(PetUIVisualParam)
    end
  end
end

function HandbookModule:OnGetCurChangeAwardStateIndex()
  return self.CurChangeAwardStateIndex
end

function HandbookModule:OnSetCurChangeAwardStateIndex(_index)
  if not self.getAwardUnderWay then
    self.CurChangeAwardStateIndex = _index
  end
end

function HandbookModule:OnChangeCoverInfo(_rsp)
end

function HandbookModule:OnSceneActionNotify(notify)
  local acts = notify.acts
  if #acts > 0 then
    for i = 1, #acts do
      local act = acts[i]
      if act.collect_handbook_records_change and act.collect_handbook_records_change.handbook_records then
        self.data:ChangeAccessHandbookData(act.collect_handbook_records_change.handbook_records)
      end
    end
  end
end

function HandbookModule:OnStatChangeNotify(notify)
  Log.Dump(notify, 6, "HandbookModule:OnStatChangeNotify")
  if notify and notify.hb_coll then
    for _, collection in ipairs(notify.hb_coll) do
      if collection.record then
        for _, record in pairs(collection.record) do
          self.data:SetHandbookStatDic(record.pet_base_id, record.statistics)
        end
      end
    end
  end
end

function HandbookModule:OnCmdZoneAddPetRecordReq(baseId, reason)
  local req = _G.ProtoMessage:newZoneAddPetRecordReq()
  req.base_id = baseId
  req.reason = reason or ProtoEnum.ZoneAddPetRecordReq.Reason.UNKOWN
  self.photoPetId = baseId
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_ADD_PET_RECORD_REQ, req, self, self.OnZoneAddPetRecordRsp)
end

function HandbookModule:OnZoneAddPetRecordRsp(rsp)
  if 0 == rsp.ret_info.ret_code and self.photoPetId then
    local petName = _G.DataConfigManager:GetPetbaseConf(self.photoPetId).name
    local des = string.format(LuaText.take_photo_hb_discover_tips, petName)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, des)
    self.photoPetId = nil
  end
end

function HandbookModule:ReqPetStat(petId)
  local curTime = UE4Helper.GetCurrentWorld():GetTimeSeconds()
  local cachedPetStat = self.data:GetHandbookStatData(petId)
  local isReqIntervalExceeded = curTime - self.LastPetStatReqTime > self.PetStatReqInterval
  local needReq = nil == cachedPetStat or isReqIntervalExceeded
  if needReq then
    self.LastPetStatReqTime = curTime
    local req = ProtoMessage:newZoneGetPetStatReq()
    req.version = self.PetStatVersion
    local petSet = nil == cachedPetStat and req.no_cached_pets or req.cached_pets
    if nil ~= petSet then
      petSet[1] = petId
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PET_STAT_REQ, req, self, self.OnZoneGetPetStatRsp)
    end
  end
end

function HandbookModule:ReqPetsStat(petIds)
  local curTime = UE4Helper.GetCurrentWorld():GetTimeSeconds()
  local isReqIntervalExceeded = curTime - self.LastPetStatReqTime > self.PetStatReqInterval
  local req
  for _, petId in ipairs(petIds) do
    local cachedPetStat = self.data:GetHandbookStatData(petId)
    local needReq = nil == cachedPetStat or isReqIntervalExceeded
    if needReq then
      req = req or ProtoMessage:newZoneGetPetStatReq()
      local petSet = nil == cachedPetStat and req.no_cached_pets or req.cached_pets
      if nil ~= petSet then
        table.insert(petSet, petId)
      end
    end
  end
  if req then
    req.version = self.PetStatVersion
    self.LastPetStatReqTime = curTime
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PET_STAT_REQ, req, self, self.OnZoneGetPetStatRsp)
  end
end

function HandbookModule:OnGetAllHandbookStatReq()
  self:OnZoneGetHandbookStatReq(1)
end

function HandbookModule:OnZoneGetHandbookStatReq(page_index)
  local req = _G.ProtoMessage:newZoneGetHandbookStatReq()
  req.page = page_index
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_HANDBOOK_STAT_REQ, req, self, self.OnZoneGetHandbookstatRsp)
end

function HandbookModule:OnZoneGetHandbookstatRsp(rsp)
  if rsp and rsp.hb_coll then
    for _, collection in ipairs(rsp.hb_coll) do
      if collection.record then
        for _, record in pairs(collection.record) do
          self.data:SetHandbookStatDic(record.pet_base_id, record.statistics)
        end
      end
    end
  end
  if rsp and rsp.total_page and rsp.req_page then
    if rsp.total_page <= rsp.req_page then
      Log.Warning("\229\155\190\233\137\180\231\187\159\232\174\161\230\149\176\230\141\174\232\175\183\230\177\130\231\187\147\230\157\159\229\133\177", rsp.total_page)
    else
      self:OnZoneGetHandbookStatReq(rsp.req_page + 1)
    end
  end
end

function HandbookModule:OnZoneGetPetStatRsp(rsp)
  if nil == rsp then
    return
  end
  local version = rsp.version
  if version ~= self.PetStatVersion then
    self.PetStatVersion = version
    self.data:ClearHandbookStatData()
  end
  if rsp.hb_coll then
    for _, collection in ipairs(rsp.hb_coll) do
      if collection.record then
        for _, record in pairs(collection.record) do
          self.data:SetHandbookStatDic(record.pet_base_id, record.statistics)
        end
      end
    end
    self:DispatchEvent(HandbookModuleEvent.OnPetStatUpdate)
  end
end

function HandbookModule:OnCmdGetAccessHandbookData()
  return self.data:GetAccessHandbookData()
end

function HandbookModule:OnCmdCheckItemInHandbook(itemId)
  return self.data:CheckItemInHandbook(itemId)
end

function HandbookModule:NewHandBook(_rsp)
  if _rsp.record_coll then
    local petInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
    if not petInfo then
      return false
    end
    self.data:UpdatePetHandBookMainDataDic(_rsp)
    if petInfo.handbook.record_collection == nil then
      petInfo.handbook.record_collection = {}
    end
    local old_collection
    local old_index = 0
    local PetHandbook = _G.DataConfigManager:GetPetHandbook(_rsp.record_coll.handbook_id)
    for i, collection in pairs(petInfo.handbook.record_collection) do
      if collection.handbook_id == _rsp.record_coll.handbook_id then
        old_collection = collection
        old_index = i
        break
      end
    end
    if not old_collection then
      table.insert(petInfo.handbook.record_collection, _rsp.record_coll)
      old_collection = {
        status = ProtoEnum.PetHandbookStatus.PHS_NOT_FOUND
      }
    else
      petInfo.handbook.record_collection[old_index] = _rsp.record_coll
    end
    if old_collection.status ~= _rsp.record_coll.status and _rsp.record_coll.status == ProtoEnum.PetHandbookStatus.PHS_FOUND and _G.BattleManager.isInBattle then
      _G.BattleManager.IsMeetNewPet = true
    else
    end
    if _rsp.record_coll and _rsp.record_coll.status == ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
      local changeDataArray = self.data:SetHandbookTopicData(_rsp.record_coll, _rsp.change_pet_base_id)
      if changeDataArray then
        for i, changeData in ipairs(changeDataArray) do
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.CreateHandbookTopicDataTip(changeData))
        end
      end
    end
    _G.NRCEventCenter:DispatchEvent(HandbookModuleEvent.OnHandbookPetStateChange, _rsp.change_pet_base_id)
    _G.NRCEventCenter:DispatchEvent(HandbookModuleEvent.OnHandBookChanged, _rsp.record_coll.handbook_id)
  end
end

function HandbookModule:RandomChooseFromTable(data, excludeFunc)
  local keys = {}
  for _key, _conf in pairs(data) do
    if not excludeFunc or not excludeFunc(_conf) then
      table.insert(keys, _key)
    end
  end
  local randomKey = keys[math.random(1, #keys)]
  return data[randomKey]
end

function HandbookModule:ShowHandBookTips(petData, CmdID)
  if nil == petData then
    return
  end
  local config = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  if petData.is_first_catch then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_ShowPropTips, TipObject.FormPetHandBook(petData, config), CmdID)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_ShowPropTips, TipObject.FormPetHandBook(petData, config), CmdID)
  end
end

function HandbookModule:OnCmdOpenWorldHandbook(tip)
  local HasPanel = self:HasPanel("BookPrompt")
  if not HasPanel then
    self:OpenPanel("BookPrompt", tip)
  else
    local Panel = self:GetPanel("BookPrompt")
    Panel:UpdateHandbook(tip)
  end
end

function HandbookModule:OnCmdIsShowWorldHandbook(_IsShow)
  local HasPanel = self:HasPanel("BookPrompt")
  if HasPanel then
    local Panel = self:GetPanel("BookPrompt")
    Panel:SetIsShow(_IsShow)
  end
end

function HandbookModule:OnCmdAreaHandbookChangePanel(arg)
  self:OpenPanel("HandBook_RegionalSelection", arg)
end

function HandbookModule:IsCollectHandBook(collect)
  if not collect or not collect.record then
    return false
  end
  for _, record in pairs(collect.record) do
    if record.status == ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
      return record
    end
  end
  return false
end

function HandbookModule:OnPlayerTeleportStart()
  self:OnCmdCloseHandbookPanel()
end

function HandbookModule:OnChangSelectItemUIIcon(_petId, _state, _mutation, _glass_info)
  local selectItemUI = self.data:GetSelectLefListItemUI()
  if nil ~= selectItemUI then
    selectItemUI:SetPetHeadIcon(_petId, _state, _mutation, _glass_info)
  end
end

function HandbookModule:OnCmdCheckTopRedPoint()
  local showRedPoint = false
  local showAwardRedPoint = false
  showRedPoint = self.data:CheckTopicAllRedPoint()
  showAwardRedPoint = self.data:CheckAwardRedPoint()
  return showRedPoint or showAwardRedPoint
end

function HandbookModule:OnReverStelectItemUIIcon()
  local selectItemUI = self.data:GetSelectLefListItemUI()
  if nil ~= selectItemUI then
    selectItemUI:RevertDefaultIcon()
  end
end

function HandbookModule:OnCmdOpenHandbookCoverPanel(arg)
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_HANDBOOK)
  if isBan then
    if _G.DataModelMgr.PlayerDataModel:GetIsTraceByBag() then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.item_source_worng_tip5)
    end
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUISubPanelClosed, false, false)
    return
  end
  if self:HasPanel("HandbookCover") or self:HasPanel("HandbookMain") then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_CloseItemTips)
    return
  end
  self.data:ReverseCurBookId()
  if arg and type(arg) == "number" then
    local conf = _G.DataConfigManager:GetAreaHandbook(arg)
    local banId = conf.enter_ban_id
    local banConf = _G.DataConfigManager:GetUiEnterBanConf(banId)
    local isBanBook = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, banConf.function_entrance, true)
    if isBanBook then
      return
    else
      self.data.CurHandbookAreaId = arg
    end
  end
  if not self:HasPanel("HandbookCover") then
    local ResListData = self:OnLoadPanelRes()
    self:PreAssignedPanelDepth("HandbookMain")
    local panelDynamicData = NRCPanelDynamicData()
    panelDynamicData:SetCloseCallback(self, self.OnHandbookCoverClosed)
    self:OpenPanel("HandbookCover", arg, ResListData, panelDynamicData)
    local cacheTime = 10
    self:PreLoadPanel("HandbookMain", cacheTime)
  else
    local panel = self:GetPanel("HandbookCover")
    panel:ReverseAnimation()
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "LobbyMain").BOOK
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "MainUIModule", "LobbyMain", touchReasonType)
  end
end

function HandbookModule:OnCmdCloseHandbookCoverPanel()
  if self:HasPanel("HandbookMain") then
    self:ClosePanel("HandbookMain")
  else
  end
  if self:HasPanel("HandbookCover") then
    self:ClosePanel("HandbookCover")
  end
end

function HandbookModule:OnHandbookCoverClosed()
  self:UndoPreAssignedPanelDepth("HandbookMain")
end

function HandbookModule:OnCmdCloseHandbookCoverByPlayer()
  if self:HasPanel("HandbookCover") then
    local panel = self:GetPanel("HandbookCover")
    if panel then
      panel:OnClosePanel()
    end
  end
end

function HandbookModule:OnCmdOpenHandbookPanel(arg)
  self.data:SetHandbookInfo()
  if self:HasPanel("HandbookMain") then
    local Panel = self:GetPanel("HandbookMain")
    Panel:OnActive(arg)
  else
    self:OpenPanel("HandbookMain", arg)
  end
end

function HandbookModule:EnableHandbookPanel()
  if self:HasPanel("HandbookCover") then
    local Panel = self:GetPanel("HandbookCover")
    Panel:EnableAndShouldBanWorldRendering()
  end
  if self:HasPanel("HandbookMain") then
    local Panel = self:GetPanel("HandbookMain")
    Panel:EnableAndShouldBanWorldRendering()
  end
end

function HandbookModule:PreLoadHandbookPanel()
  self:PreLoadPanel("HandbookCover", 10)
end

function HandbookModule:OnCmdCloseHandbookPanel()
  if self:HasPanel("HandbookCover") then
    local Panel = self:GetPanel("HandbookCover")
    Panel:ReverseAnimation()
  else
  end
  if self:HasPanel("DazzlingPopUp") then
    self:ClosePanel("DazzlingPopUp")
  end
  self.lastSelectedIndex = 0
  self.data:SetSelectPetData(nil)
  self.data:ClearCacheSortList()
end

function HandbookModule:IsHaveCover()
  return self:HasPanel("HandbookCover")
end

function HandbookModule:OnOpenContentView(_handbookId, _petBaseId, _showBookAim)
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_HANDBOOK)
  if isBan and _G.DataModelMgr.PlayerDataModel:GetIsTraceByBag() then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.item_source_worng_tip5)
    return
  end
  if self:HasPanel("HandbookCover") then
    local panel = self:GetPanel("HandbookCover")
    panel:OnOpenAimMainPanel()
  end
  self:OnCmdOpenHandbookPanel({
    handbookId = _handbookId,
    petbaseId = _petBaseId,
    isShowBookAim = _showBookAim
  })
end

function HandbookModule:OnOpenHandbookTrophyPanel(arg)
  self.data:SetHandbookInfo()
  self:OpenPanel("HandbookTrophy", arg)
end

function HandbookModule:OnCmdOpenHandbookSubjectPanel(petBookInfo, pet_base_id)
  if self:HasPanel("HandbookSubject") then
    local panel = self:GetPanel("HandbookSubject")
    if panel then
      panel:OnUpdateData(petBookInfo, pet_base_id)
    end
  else
    self:OpenPanel("HandbookSubject", petBookInfo, pet_base_id)
  end
end

function HandbookModule:OnCmdOpenHabitTips(parms)
  self:OpenPanel("HandbookHabitTips", parms)
end

function HandbookModule:OnCmdCloseHabitTips()
  if self:HasPanel("HandbookHabitTips") then
    local panel = self:GetPanel("HandbookHabitTips")
    panel:DoStartClosing()
  end
end

local _habitParams

function HandbookModule:OnCmdOpenHabitMap(parms)
  if not parms then
    return
  end
  _habitParams = parms
  local req = _G.ProtoMessage:newZoneGetPetHabitatReq()
  req.pet_base_id = parms.pet_base_id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PET_HABITAT_REQ, req, self, self.GetPetHabitatRsp)
end

function HandbookModule:OnCmdOpenDazzlingPopUp(arg, mutationType)
  if self:HasPanel("DazzlingPopUp") then
    local Panel = self:GetPanel("DazzlingPopUp")
    Panel:EnablePanel(arg, mutationType)
  else
    self:OpenPanel("DazzlingPopUp", arg, mutationType)
  end
end

function HandbookModule:OnCmdCloseDazzlingPopUp()
  if self:HasPanel("DazzlingPopUp") then
    local Panel = self:GetPanel("DazzlingPopUp")
    Panel:DisablePanel()
  end
end

function HandbookModule:GetPetHabitatRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    _habitParams.area_info = rsp.area_info
    Log.Dump(rsp, 9, "PetHabitatRsp")
    _habitParams.isPetHabitat = true
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OpenWorldMap, _habitParams)
    _habitParams = nil
  end
end

function HandbookModule:OnCmdSetStartState(IsStart, StartIndex)
  self.data:SetIsStart(IsStart)
  self.data:SetStartIndex(StartIndex)
end

function HandbookModule:GetSelectedIndex()
  return self.lastSelectedIndex
end

function HandbookModule:OnCmdOpenUpdatePrompt(arg)
  if self:HasPanel("HandBookUpdatePrompt") then
    local updatePrompt = self:GetPanel("HandBookUpdatePrompt")
  else
    self:OpenPanel("HandBookUpdatePrompt", arg)
  end
end

function HandbookModule:OnGetHandbookPetIds(bookId)
  local handbookConf = _G.DataConfigManager:GetPetHandbook(bookId)
  local ids = {}
  for i = 1, #handbookConf.include_petbase_id do
    if handbookConf.include_petbase_id[i].petbase_id then
      local petbase_id = handbookConf.include_petbase_id[i].petbase_id[1]
      table.insert(ids, petbase_id)
    end
  end
  return ids
end

function HandbookModule:IsContainHandbookPetId(bookId, petId)
  local ids = self:OnGetHandbookPetIds(bookId)
  for i = 1, #ids do
    if ids[i] == petId then
      return true, i
    end
  end
  return false, nil
end

function HandbookModule:ResetComboBox()
  if self:HasPanel("HandbookMain") then
    local panel = self:GetPanel("HandbookMain")
    panel:ResetComboBox()
  end
end

function HandbookModule:OnCmdOpenHandbookSearch(arg)
  self:OpenPanel("HandBookSearch", arg)
end

function HandbookModule:OnCloseHandbookSearch(arg)
  self:ClosePanel("HandBookSearch")
end

function HandbookModule:OnCmdOpenDistrictMapGuide(pet, iconType, teamType)
  if not pet then
    Log.Error("[OnCmdOpenDistrictMapGuide] pet nil!")
    return
  end
  local districtMapGuideConf = {}
  districtMapGuideConf.selectIconType = iconType
  districtMapGuideConf.selectTeamType = teamType
  if type(pet) == "number" then
    districtMapGuideConf.petData = {}
    districtMapGuideConf.petData.base_conf_id = pet
  else
    districtMapGuideConf.petData = pet
  end
  local petBaseId
  if districtMapGuideConf.petData then
    petBaseId = districtMapGuideConf.petData.base_conf_id
    self:ReqPetStat(petBaseId)
  end
  self:OpenPanel("DistrictMapGuide", petBaseId, districtMapGuideConf)
end

function HandbookModule:CheckDistrictMapGuideRecordEnable()
  if self.DistrictMapGuideRecordEnable and next(self.DistrictMapGuideRecordEnable) then
    return true
  end
  return false
end

function HandbookModule:OnCmdSetDistrictMapGuideRecordEnable(enable, source)
  if enable then
    self.DistrictMapGuideRecordEnable = self.DistrictMapGuideRecordEnable or {}
    self.DistrictMapGuideRecordEnable[source] = true
  else
    if self.DistrictMapGuideRecordEnable then
      self.DistrictMapGuideRecordEnable[source] = nil
    end
    if not self:CheckDistrictMapGuideRecordEnable() then
      self.DistrictMapGuideSelectTeam = nil
    end
  end
end

function HandbookModule:OnCmdRecordDistrictMapGuideSelect(selectTeamType)
  if self:CheckDistrictMapGuideRecordEnable() then
    self.DistrictMapGuideSelectTeam = selectTeamType
  end
end

function HandbookModule:OnCmdGetDistrictMapGuideSelectRecord()
  if self:CheckDistrictMapGuideRecordEnable() then
    return self.DistrictMapGuideSelectTeam
  end
end

function HandbookModule:OnCmdSetSelectedItem(PetData, Index, _ChildSize_Y, ItemUI)
  if not self.data:GetSelectSubForce() then
    self.data:SetSubSelectIndex(1)
  else
    self.data:SetSelectSubForce(false)
  end
  if nil == PetData or nil == Index then
    self.data:SetSelectLeftListItemUI(nil)
    return
  end
  local isRepeatSelect = true
  if self.lastSelectedIndex ~= Index then
    self:OnReverStelectItemUIIcon()
    isRepeatSelect = false
  else
    local oldSelectBookInfo = self.data:GetSelectPetData()
    if oldSelectBookInfo and PetData.HandbookId ~= oldSelectBookInfo.HandbookId then
      isRepeatSelect = false
    end
  end
  self.data:SetSelectPetData(PetData)
  self.data:SetSelectLeftListItemUI(ItemUI)
  if not isRepeatSelect then
    local selectInfo = self.data:GetSelectPetData()
    self:DispatchEvent(HandbookModuleEvent.SetSelectedItemUpdatePanel, selectInfo, true)
  end
  self.data:SetSelectIndex(Index - 1)
  self.data:SetChildSize_Y(_ChildSize_Y)
  self:DispatchEvent(HandbookModuleEvent.SelecteStateChange)
  if Index > self.lastSelectedIndex then
    self:DispatchEvent(HandbookModuleEvent.SelecteStateChange, true)
  elseif Index < self.lastSelectedIndex then
    self:DispatchEvent(HandbookModuleEvent.SelecteStateChange, false)
  end
  self.lastSelectedIndex = Index
end

function HandbookModule:OnCmdGetHandbookAward(_award_pt, _index)
  if self.getAwardUnderWay == true then
    return
  end
  local areaConf = _G.DataConfigManager:GetAreaHandbook(self.data.CurHandbookAreaId)
  local req = _G.ProtoMessage:newZoneGetHandbookAwardReq()
  self.CurChangeAwardStateIndex = _index
  self.getAwardUnderWay = true
  req.award_pt = _award_pt
  req.hb_area_type = areaConf.area_handbook_type
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_HANDBOOK_AWARD_REQ, req, self, self.GetHandbookAwardRsp)
end

function HandbookModule:GetHandbookAwardRsp(_rsp)
  local rsp = _rsp
  if 0 == rsp.ret_info.ret_code then
    if 0 ~= self.CurChangeAwardStateIndex then
      if #self.data:GetHandBookRewardStates() >= self.CurChangeAwardStateIndex then
        self.data:SetHandBookRewardStates(self.CurChangeAwardStateIndex, true)
        _G.NRCEventCenter:DispatchEvent(HandbookModuleEvent.OnHandBookChanged)
      end
      self.CurChangeAwardStateIndex = 0
      self:DispatchEvent(HandbookModuleEvent.OnUpdateRewardPanel, self.data:GetHandBookRewardStates())
    end
    if #rsp.ret_info.goods_reward.rewards > 0 then
      local rewardDic = {}
      for i = 1, #rsp.ret_info.goods_reward.rewards do
        local reward = rsp.ret_info.goods_reward.rewards[i]
        if rewardDic[reward.id] then
          rewardDic[reward.id].num = rewardDic[reward.id].num + reward.num
        else
          rewardDic[reward.id] = reward
        end
      end
      local rewardList = {}
      for key, value in pairs(rewardDic) do
        table.insert(rewardList, value)
      end
      _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, rewardList, "")
    end
  end
  self.getAwardUnderWay = false
end

function HandbookModule:OnCmdGetHandbookTopicAward(hb_id, id)
  local req = _G.ProtoMessage:newZoneGetHandbookTopicAwardReq()
  req.hb_id = hb_id
  if nil == id then
    local areaConf = _G.DataConfigManager:GetAreaHandbook(self.data.CurHandbookAreaId)
    req.area_type = areaConf.area_handbook_type
  end
  req.topic_id = id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_HANDBOOK_TOPIC_AWARD_REQ, req, self, self.GetHandbookTopicAwardRsp, true)
end

function HandbookModule:GetHandbookTopicAwardRsp(_rsp)
  if 0 == _rsp.ret_info.ret_code then
    local petInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
    if not petInfo then
      return
    end
    local id = _rsp.topic_id
    if _rsp.hb_id and id then
      self:SetHandbookTopicAward(_rsp.hb_id, id)
    end
    if _rsp.award_items then
      local awardDic = {}
      local award = {}
      for _, item in pairs(_rsp.award_items) do
        if item.hb_id and item.topic_ids and #item.topic_ids > 0 then
          for j = 1, #item.topic_ids do
            local hb_id = item.hb_id
            local topic_id = item.topic_ids[j]
            for _, collection in pairs(petInfo.handbook.record_collection) do
              if collection.handbook_id == hb_id then
                self.data:SetHandbookTopicAwardState(hb_id, topic_id, true)
                break
              end
            end
            local reward_id
            for _, topic in pairs(_G.DataConfigManager:GetPetHandbook(hb_id).pet_topic) do
              if topic.topic_id == topic_id then
                reward_id = topic.topic_reward
                break
              end
            end
            if reward_id then
              local rewardConf = _G.DataConfigManager:GetRewardConf(reward_id)
              local handbook_rewards = nil == rewardConf and {} or rewardConf.RewardItem
              for i, v in pairs(handbook_rewards) do
                if nil == awardDic[v.Type] then
                  awardDic[v.Type] = {}
                end
                if nil == awardDic[v.Type][v.Id] then
                  awardDic[v.Type][v.Id] = {
                    type = v.Type,
                    id = v.Id,
                    num = v.Count,
                    reward_reason = _G.ProtoEnum.FlowReason.FLOW_REASON_HANDBOOK_REWARD
                  }
                else
                  awardDic[v.Type][v.Id].num = awardDic[v.Type][v.Id].num + v.Count
                end
              end
            end
          end
        end
      end
      for _, typeItems in pairs(awardDic) do
        for _, v in pairs(typeItems) do
          table.insert(award, v)
        end
      end
      _G.NRCEventCenter:DispatchEvent(HandbookModuleEvent.OnHandBookChanged)
      _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, award, "")
    end
  end
end

function HandbookModule:SetHandbookTopicAward(hb_id, id)
  local petInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  if not petInfo then
    return
  end
  for _, collection in pairs(petInfo.handbook.record_collection) do
    if collection.handbook_id == hb_id then
      self.data:SetHandbookTopicAwardState(hb_id, id, true)
      break
    end
  end
  _G.NRCEventCenter:DispatchEvent(HandbookModuleEvent.OnHandBookChanged, hb_id)
  local award = {}
  local reward_id
  for i, pet_topic in pairs(_G.DataConfigManager:GetPetHandbook(hb_id).pet_topic) do
    if pet_topic.topic_id == id then
      reward_id = pet_topic.topic_reward
      break
    end
  end
  if reward_id then
    local rewardConf = _G.DataConfigManager:GetRewardConf(reward_id)
    local handbook_rewards = nil == rewardConf and {} or rewardConf.RewardItem
    for i, v in pairs(handbook_rewards) do
      table.insert(award, {
        type = v.Type,
        id = v.Id,
        num = v.Count,
        reward_reason = _G.ProtoEnum.FlowReason.FLOW_REASON_HANDBOOK_REWARD
      })
    end
  end
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, award, "")
end

function HandbookModule:OnCmdReversedSort()
  self:DispatchEvent(HandbookModuleEvent.SetReversedSort)
end

function HandbookModule:OnCmdGetPetHandBookState(_petBaseId)
  return self.data:GetPetHandBookState(_petBaseId)
end

function HandbookModule:OnCmdGetPetState(_petBaseId)
  return self.data:GetPetState(_petBaseId)
end

function HandbookModule:OnGetHandbookLeftReversal()
  return self.data.HandbookLeftReversal
end

function HandbookModule:OnCmdGetPetHandbookCurrentProgressTaskReward(petBaseId)
  return self.data:GetPetHandbookCurrentProgressTaskReward(petBaseId)
end

function HandbookModule:GetHandBookInfoByRewardItemId(ItemType, ItemId)
  local petHandbookList = {}
  local sortType = self.data.HandbookLeftSortIndex
  if sortType == _G.Enum.HandbookSequenceDefault.HSD_SEQUENCE_NUMBER_UP then
    petHandbookList = self.data:GetLeftNumberSortList(false)
  else
    petHandbookList = self.data:GetLeftTaskSortList(false)
  end
  for i, v in pairs(petHandbookList) do
    if v.State == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED and v.HandbookId then
      local BookInfo = self.data and self.data.HandBookMainDataDic and self.data.HandBookMainDataDic[v.HandbookId]
      if BookInfo.Collection ~= nil then
        local petBookCfg = _G.DataConfigManager:GetPetHandbook(v.HandbookId)
        if petBookCfg and petBookCfg.pet_topic then
          for _, j in ipairs(petBookCfg.pet_topic) do
            local reward_id = j.topic_reward
            if reward_id and reward_id > 0 then
              local rewardConf = _G.DataConfigManager:GetRewardConf(reward_id)
              if rewardConf then
                local rewards = rewardConf.RewardItem
                for index = 1, #rewards do
                  if rewards[index].Type == ItemType and rewards[index].Id == ItemId then
                    return v.HandbookId, v.PetBaseId
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

function HandbookModule:OnCmdOpenHandbookByRewardItemId(ItemType, ItemId)
  if self:HasPanel("HandbookCover") or self:HasPanel("HandbookMain") then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_CloseItemTips)
    return
  end
  if ItemType and ItemId then
    local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_HANDBOOK)
    if isBan and _G.DataModelMgr.PlayerDataModel:GetIsTraceByBag() then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.item_source_worng_tip5)
      return
    end
    local HandbookId, PetBaseId = self:GetHandBookInfoByRewardItemId(ItemType, ItemId)
    if HandbookId and PetBaseId then
      self:OnCmdOpenHandbookPanel({
        handbookId = HandbookId,
        petbaseId = PetBaseId,
        NeedOpenSubject = true
      })
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.cannot_jump_to_handbook_award_tips)
    end
  else
    Log.Error("ItemType1,ItemId1 Is Nil")
  end
end

function HandbookModule:OnCmdGetHandbookCoverInfos()
  return self.data:GetHandbookCoverInfos()
end

function HandbookModule:OnCmdGetPetHandBookData(handbookId)
  return self.data:GetPetHandBookData(handbookId)
end

function HandbookModule:RegPanel(name, path, layer, customDisableRendering, fullSpeedDesired, disablePcEsc, autoSetDesiredCursor)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/Handbook/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = customDisableRendering or false
  registerData.fullSpeedDesired = fullSpeedDesired
  registerData.enablePcEsc = not disablePcEsc
  registerData.autoSetDesiredCursor = autoSetDesiredCursor
  self:RegisterPanel(registerData)
end

function HandbookModule:OnCmdSetPetVisualParam(_PetVisualParam)
  self.data:SetPetVisualParam(_PetVisualParam)
  if _G.AppMain:HasDebug() then
    _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.UpdateVisualToolParam, _PetVisualParam, true)
  end
end

function HandbookModule:OnCmdGetPetVisualParam(_IsOpen)
  if self:HasPanel("HandbookMain") then
    local PanelInst = self:GetPanel("HandbookMain")
    PanelInst.HandbookContent:ControlShowUIRedLine(_IsOpen)
  end
  return self.data:GetPetVisualParam()
end

function HandbookModule:OnSetPetUIScaleAndOffsetAndImageRevert(_IsRevert, _flip, _Scale, _Offset, _CurModifyAxis)
  if self:HasPanel("HandbookMain") then
    local PanelInst = self:GetPanel("HandbookMain")
    if PanelInst and PanelInst.HandbookContent and PanelInst.HandbookContent.Icon then
      if _IsRevert then
        PanelInst.HandbookContent:SetPetUIImageRevert(_flip, _Scale)
      else
        PanelInst.HandbookContent:UpdateUIScaleAndOffset(_flip, _Scale, _Offset, _CurModifyAxis)
      end
    end
  end
end

function HandbookModule:OnGetDisableRewardAnimationState()
  if self.playingTime then
    local curtime = os.time()
    if curtime - self.playingTime > 3 then
      self.playingTime = nil
      return false
    end
  end
  return self.isDisableRewardReceiveAnim
end

function HandbookModule:OnSetDisableRewardAnimationState(isPlayingAnim)
  if isPlayingAnim then
    self.playingTime = os.time()
  end
  self.isDisableRewardReceiveAnim = isPlayingAnim
end

function HandbookModule:SetClickTime()
  if self.ClickTimer == nil then
    return true
  elseif os.time() - self.ClickTimer > 2 then
    self.ClickTimer = nil
    return true
  else
    return false
  end
end

function HandbookModule:OnCmdSelectAreaItem(areaItemData)
  self.data.CurHandbookAreaId = areaItemData.conf.id
  self.data.CurHandbookAreaType = areaItemData.conf.area_handbook_type
  self.data:ChangeAreaHandbookInfo()
  self:UpdateSelectPageRedPoint()
  self:DispatchEvent(HandbookModuleEvent.OnChangeAreaData, areaItemData)
end

function HandbookModule:OnCmdGetCurAreaHandbookEnum()
  return self.data:GetCurAreaHandbookEnum()
end

function HandbookModule:OnCmdGetCurAreaHandbookId()
  return self.data.CurHandbookAreaId
end

function HandbookModule:OnCmdGetAreaHandbookInfo(type)
  return self.data:GetAreaHandbookInfo(type)
end

function HandbookModule:OnCmdSearchHandbook(text, listDatas)
  self.data:SearchHandbook(text, listDatas, self.lastSelectedIndex)
end

function HandbookModule:OnCmdGetAllPetHandbookConfs()
  if self.data.petHandbook then
    return self.data.petHandbook
  end
  local HandBookConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_HANDBOOK)
  if HandBookConf then
    self.data.petHandbook = HandBookConf:GetAllDatas()
  else
    self.data.petHandbook = {}
  end
  return self.data.petHandbook
end

function HandbookModule:OnLoadingUIOpened()
  if self:HasPanel("HandbookCover") or self:HasPanel("HandbookMain") then
    self:CloseAllPanel()
  end
end

function HandbookModule:GetAllAreaHandbookConfs()
  if self.areaConfs == nil then
    self.areaConfs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.AREA_HANDBOOK):GetAllDatas()
  end
  return self.areaConfs
end

function HandbookModule:GetCurAreaHandBookRedId(typeEnum, index)
  local curAreaConf = _G.DataConfigManager:GetAreaHandbook(self.data.CurHandbookAreaId)
  if curAreaConf then
    if typeEnum == HandbookModuleEnum.RedPointType.CollectedRed then
      if curAreaConf.collected_red_point_id == nil or 0 == #curAreaConf.collected_red_point_id then
        return 0
      end
      return curAreaConf.collected_red_point_id[index]
    elseif typeEnum == HandbookModuleEnum.RedPointType.TopicRed then
      if nil == curAreaConf.topic_red_point_id or 0 == #curAreaConf.topic_red_point_id then
        return 0
      end
      return curAreaConf.topic_red_point_id[index]
    elseif typeEnum == HandbookModuleEnum.RedPointType.NumberRed then
      if nil == curAreaConf.count_reward_handbook_red_point_id or 0 == #curAreaConf.count_reward_handbook_red_point_id then
        return 0
      end
      return curAreaConf.count_reward_handbook_red_point_id[index]
    end
  end
  return 0
end

function HandbookModule:GetRedPointModuleData()
  if self.redPointData == nil then
    self.redPointData = _G.NRCModuleManager:GetModule("RedPointModule"):GetData("RedPointModuleData")
  end
  return self.redPointData
end

function HandbookModule:GetRedPointReasonState(areaId)
  local redCollectedId = _G.DataConfigManager:GetAreaHandbook(areaId).collected_red_point_id[1]
  local redCollectedReason = _G.DataConfigManager:GetRedPointConf(redCollectedId).change_reason[1] or 0
  local redTopicId = _G.DataConfigManager:GetAreaHandbook(areaId).topic_red_point_id[4]
  local redTopicReason = _G.DataConfigManager:GetRedPointConf(redTopicId).change_reason[1] or 0
  local redPointData = self:GetRedPointModuleData()
  local isCollectePointUp = false
  local isTopicPointUp = false
  local TopicPointDatas = {}
  if nil == redPointData or nil == redPointData.RedPointNodeDic then
    return isCollectePointUp, isTopicPointUp, TopicPointDatas
  end
  local redPointCollecteNode = redPointData.RedPointNodeDic[redCollectedId]
  if redPointCollecteNode and redPointCollecteNode.litUpReasonDic[redCollectedReason] and redPointCollecteNode.litUpReasonDic[redCollectedReason].oriPointData then
    local listDatas = {}
    if redPointCollecteNode.litUpReasonDic[redCollectedReason].splitPointData then
      listDatas = redPointCollecteNode.litUpReasonDic[redCollectedReason].splitPointData
    else
      listDatas = self:SplitOriPointData(redPointCollecteNode.litUpReasonDic[redCollectedReason].oriPointData)
    end
    isCollectePointUp = #listDatas > 0
  end
  local redPointTopicNode = redPointData.RedPointNodeDic[redTopicId]
  if redPointTopicNode and redPointTopicNode.litUpReasonDic[redTopicReason] and redPointTopicNode.litUpReasonDic[redTopicReason].oriPointData then
    local listDatas = {}
    if redPointTopicNode.litUpReasonDic[redTopicReason].splitPointData then
      listDatas = redPointTopicNode.litUpReasonDic[redTopicReason].splitPointData
    else
      listDatas = self:SplitOriPointData(redPointTopicNode.litUpReasonDic[redTopicReason].oriPointData)
    end
    isTopicPointUp = #listDatas > 0
    TopicPointDatas = listDatas
  end
  return isCollectePointUp, isTopicPointUp, TopicPointDatas
end

function HandbookModule:UpdateSelectPageRedPoint()
  local redPointData = self:GetRedPointModuleData()
  if nil == redPointData or nil == redPointData.RedPointNodeDic then
    return
  end
  local allAreaConfs = self:GetAllAreaHandbookConfs()
  local curSelectAreaId = self.data.CurHandbookAreaId
  if allAreaConfs then
    local redPointData = {}
    local entranData = {}
    local isSelectCollectionRed, isSelectTopicRed, selectTopicPointDatas = self:GetRedPointReasonState(curSelectAreaId)
    for i, areaConf in pairs(allAreaConfs) do
      local isCollectionRed, isTopicRed, topicPointDatas = self:GetRedPointReasonState(areaConf.id)
      if areaConf.id == curSelectAreaId then
      elseif 1 == areaConf.id then
        local isEqual = self:RedPointAreArraysEqual(selectTopicPointDatas, topicPointDatas)
        if isEqual then
          if isCollectionRed then
            table.insert(redPointData, string.format("%d.%d", areaConf.area_handbook_type, areaConf.id))
          end
        elseif isCollectionRed or isTopicRed then
          table.insert(redPointData, string.format("%d.%d", areaConf.area_handbook_type, areaConf.id))
        end
      elseif isCollectionRed then
        table.insert(redPointData, string.format("%d.%d", areaConf.area_handbook_type, areaConf.id))
      end
    end
    if #redPointData > 0 then
      table.insert(entranData, string.format("%d.%d", self.data.CurHandbookAreaType, self.data.CurHandbookAreaId))
    end
    _G.NRCModuleManager:DoCmd(RedPointModuleCmd.UpdateWithReasonPointData, _G.Enum.RedPointReason.RPR_AREA_HB_SELECT_PAGE, redPointData)
    _G.NRCModuleManager:DoCmd(RedPointModuleCmd.UpdateWithReasonPointData, _G.Enum.RedPointReason.RPR_AREA_HB_SELECT_ENTRANCE, entranData)
  end
end

function HandbookModule:OnUpdateRedPointData(notify)
  if notify.rp_group then
    for _, group in pairs(notify.rp_group) do
      if group.reason_type == _G.Enum.RedPointReason.RPR_HB_TOPIC_FINISH or group.reason_type == _G.Enum.RedPointReason.RPR_COLLECTED_HB_NUM then
        self:UpdateSelectPageRedPoint()
      end
    end
  end
end

function HandbookModule:RedPointAreArraysEqual(arr1, arr2)
  if #arr1 ~= #arr2 then
    return false
  end
  local isEqual = true
  local a = {}
  local b = {}
  for key, v in pairs(arr2) do
    a[v[1]] = true
  end
  for key, v in pairs(arr1) do
    b[v[1]] = true
  end
  for key, v in pairs(b) do
    if not a[key] then
      isEqual = false
    end
  end
  return isEqual
end

function HandbookModule:SplitOriPointData(oriPointData)
  local splitList = {}
  for key, oriData in pairs(oriPointData) do
    local list = {}
    for num in string.gmatch(oriData, "[^%.]+") do
      table.insert(list, num)
    end
    table.insert(splitList, list)
  end
  return splitList
end

function HandbookModule:OnCmdGetPetHandbookRecordDataByPetBaseID(petBaseID)
  if self.data then
    return self.data:GetPetHandbookRecordDataByPetBaseID(petBaseID)
  end
end

function HandbookModule:OnCmdGetHandbookCollectedPetsNum()
  if self.data then
    return self.data:GetHandbookCollectedPetsNum()
  end
end

function HandbookModule:OnCmdOpenCollectionProgressTips()
  local curAreaConf = _G.DataConfigManager:GetAreaHandbook(self.data.CurHandbookAreaId)
  local curCount = self.data.CollectedCount
  self:OpenPanel("CollectionProgressTipsPanel", curAreaConf, curCount)
end

return HandbookModule
