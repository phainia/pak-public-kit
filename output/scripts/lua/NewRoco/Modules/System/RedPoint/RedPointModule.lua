local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local RedPointModuleEvent = require("NewRoco.Modules.System.RedPoint.RedPointModuleEvent")
local RedPointModule = NRCModuleBase:Extend("RedPointModule")

function RedPointModule:OnConstruct()
  _G.RedPointModuleCmd = reload("NewRoco.Modules.System.RedPoint.RedPointModuleCmd")
  self.data = self:SetData("RedPointModuleData", "NewRoco.Modules.System.RedPoint.RedPointModuleData")
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_RED_POINT_NOTIFY, self.OnZoneRedPointNotify)
  self.CachedNotify = {}
  self.StatusChecker = StatusCheckerGroup({
    StatusCheckerEnum.Catch
  }, Log.LOG_LEVEL.ELogDebug)
end

function RedPointModule:OnActive()
  self:RegisterCmd(RedPointModuleCmd.RegRedPointUI, self.OnCmdRegRedPointUI)
  self:RegisterCmd(RedPointModuleCmd.UnRegRedPointUI, self.OnCmdUnRegRedPointUI)
  self:RegisterCmd(RedPointModuleCmd.EraseRedPoint, self.OnCmdEraseRedPoint)
  self:RegisterCmd(RedPointModuleCmd.EraseRedPointWithExtraKeyList, self.OnCmdEraseRedPointWithExtraKeyList)
  self:RegisterCmd(RedPointModuleCmd.EraseRedPointWithReason, self.EraseRedPointWithReason)
  self:RegisterCmd(RedPointModuleCmd.UpdateWithReasonPointData, self.UpdateWithReasonPointData)
  self:RegisterCmd(RedPointModuleCmd.UpdateWithReasonPointDataWithoutRefreshUI, self.UpdateWithReasonPointDataWithoutRefreshUI)
  self:RegisterCmd(RedPointModuleCmd.GetReasonPointData, self.GetReasonPointData)
  self:RegisterCmd(RedPointModuleCmd.ShowDebugInfo, self.OnCmdShowDebugInfo)
  self:RegisterCmd(RedPointModuleCmd.ChangeDebugInfoPostion, self.OnCmdChangeDebugInfoPostion)
  self:RegisterCmd(RedPointModuleCmd.ChangeDebugInfoColor, self.OnCmdChangeDebugInfoColor)
  self:RegisterCmd(RedPointModuleCmd.GmUpdateRedPoint, self.OnCmdGmUpdateRedPoint)
  self:RegisterCmd(RedPointModuleCmd.UseRedPointDataInit, self.Init)
  self:RegisterCmd(RedPointModuleCmd.GetRedPointSplitPointDataByKeyAndReason, self.OnCmdGetRedPointSplitPointDataByKeyAndReason)
  self:RegisterCmd(RedPointModuleCmd.InvalidPointData, self.InvalidPointData)
  self:RegisterCmd(RedPointModuleCmd.RecoverPointData, self.RecoverPointData)
  self:RegisterCmd(RedPointModuleCmd.GetRedPointCfgs, self.GetRedPointCfgs)
  self:RegisterCmd(RedPointModuleCmd.IsRedPointLightUp, self.IsRedPointLightUp)
  self:RegisterCmd(RedPointModuleCmd.CheckRpNodeIsLeaf, self.CheckRpNodeIsLeaf)
end

function RedPointModule:OnRelogin()
end

function RedPointModule:OnDeactive()
end

function RedPointModule:OnDestruct()
end

function RedPointModule:Init()
  local function error_handler(err)
    Log.Error("\231\186\162\231\130\185\231\179\187\231\187\159\229\136\157\229\167\139\229\140\150\229\164\177\232\180\165: ", err)
  end
  
  xpcall(self.data.InitFromPlayerData, error_handler, self.data)
  self.data:ReInvalidPointData()
  self:RefreshAllRedPointUI()
end

function RedPointModule:RefreshUis(uis, rpNode)
  if uis and next(uis) then
    for index, ui in pairs(uis) do
      if ui:IsValid() then
        ui.rpNode = rpNode
        ui:Refresh()
      else
        uis[index] = nil
      end
    end
  end
end

function RedPointModule:RefreshAllRedPointUI()
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpUIDic = self.data:GetRedPointUIDic()
  for key, rpNode in pairs(rpNodeDic) do
    local uis = rpUIDic[key]
    self:RefreshUis(uis, rpNode)
  end
end

function RedPointModule:RefreshRedPointUIByReason(reason)
  if nil == reason then
    return
  end
  if not self.rpUIDic then
    self.rpUIDic = self.data:GetRedPointUIDic()
  end
  self.reasonsToNodeDic = self.data:GetReasonToRpNodesDic()
  if not self.reasonsToNodeDic then
    Log.Error("\231\186\162\231\130\185\229\173\151\229\133\184\230\149\176\230\141\174\229\136\157\229\167\139\229\140\150\229\164\177\232\180\165\239\188\140\232\175\183\232\129\148\231\179\187jobhuang\229\145\138\231\159\165\230\152\175\230\128\142\228\185\136\229\135\186\231\142\176\231\154\132")
  end
  local rpNodes = self.reasonsToNodeDic[reason]
  if nil == rpNodes then
    return
  end
  for _, rpNode in ipairs(rpNodes) do
    self:UpdateParentNodeUI(rpNode)
  end
end

function RedPointModule:UpdateParentNodeUI(rpNode)
  local uis = self.rpUIDic[rpNode.key]
  self:RefreshUis(uis, rpNode)
  if rpNode.parent and #rpNode.parent > 0 then
    for _, parent in ipairs(rpNode.parent) do
      self:UpdateParentNodeUI(parent)
    end
  end
end

local function _isTableEqual(A, B, firstMatchFlag)
  if not B then
    Log.Error("\228\188\160\229\133\165\231\154\132splitData\230\156\137\232\175\175\239\188\140\232\175\183\233\128\154\231\159\165jobhuang\230\152\175\230\128\142\228\185\136\229\143\145\231\148\159\231\154\132")
    return
  end
  if #A ~= #B and true ~= firstMatchFlag then
    return false
  end
  for i = 1, #A do
    if firstMatchFlag and tostring(A[i]) == tostring(B[i]) then
      return true
    end
    if tostring(A[i]) ~= tostring(B[i]) then
      return false
    end
  end
  return true
end

function RedPointModule:OnCmdEraseRedPointWithExtraKeyList(key, ExtraKeyList, firstMatchFlag)
  if not ExtraKeyList then
    Log.Error("ExtraKeyList \228\184\186\231\169\186\239\188\140\232\175\183\230\163\128\230\159\165\228\188\160\229\133\165\231\154\132\230\152\175\229\144\166\230\173\163\231\161\174\239\188\140\229\186\148\228\184\186ExtraKey\231\154\132List\232\161\168")
    return
  end
  local req = _G.ProtoMessage:newZoneEraseRedPointReq()
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpNode = rpNodeDic[key]
  local litUpReasonDic = rpNode.litUpReasonDic
  local groupList = {}
  for j, extraKey in pairs(ExtraKeyList) do
    if type(extraKey) ~= "table" then
      extraKey = {extraKey}
    end
    for reason, p in pairs(litUpReasonDic) do
      if extraKey and #extraKey > 0 and type(extraKey) == "table" then
        local splitPointDataList = p.splitPointData
        local splitFunc = p.splitFunc
        if nil == splitPointDataList then
          p.splitPointData = {}
          for i, v in pairs(p.oriPointData) do
            p.splitPointData[i] = splitFunc(v)
          end
          splitPointDataList = p.splitPointData
        end
        local oriPointData = p.oriPointData
        for i, value in pairs(oriPointData) do
          local splitPointData = splitPointDataList[i]
          splitPointData = splitPointData or splitFunc(value)
          if _isTableEqual(extraKey, splitPointData, firstMatchFlag) then
            local group = _G.ProtoMessage:newRedPointGroup()
            group.reason_type = reason
            table.insert(group.point_data, value)
            table.insert(groupList, group)
          end
        end
      end
    end
  end
  req.point_group = self:_MergeRedPointGroupList(groupList)
  if 0 == #req.point_group then
    return
  end
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_ERASE_RED_POINT_REQ, req)
end

function RedPointModule:_MergeRedPointGroupList(RedPointGroupList)
  local merged = {}
  local result = {}
  for _, item in ipairs(RedPointGroupList) do
    local reason_type = item.reason_type
    local point_data = item.point_data
    if not merged[reason_type] then
      merged[reason_type] = {}
      merged[reason_type].point_set = {}
    end
    for _, point in ipairs(point_data) do
      merged[reason_type].point_set[point] = true
    end
  end
  for reason_type, data in pairs(merged) do
    local point_data_array = {}
    for point, _ in pairs(data.point_set) do
      table.insert(point_data_array, point)
    end
    table.insert(result, {reason_type = reason_type, point_data = point_data_array})
  end
  return result
end

function RedPointModule:OnCmdEraseRedPoint(key, extraKey, firstMatchFlag)
  local req = _G.ProtoMessage:newZoneEraseRedPointReq()
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpNode = rpNodeDic[key]
  local litUpReasonDic = rpNode.litUpReasonDic
  if type(extraKey) ~= "table" then
    extraKey = {extraKey}
  end
  for reason, p in pairs(litUpReasonDic) do
    if extraKey and #extraKey > 0 then
      if type(extraKey) == "table" then
        local splitPointDataList = p.splitPointData
        local splitFunc = p.splitFunc
        if nil == splitPointDataList then
          p.splitPointData = {}
          for i, v in pairs(p.oriPointData) do
            p.splitPointData[i] = splitFunc(v)
          end
          splitPointDataList = p.splitPointData
        end
        local oriPointData = p.oriPointData
        for i, value in pairs(oriPointData) do
          local splitPointData = splitPointDataList[i]
          splitPointData = splitPointData or splitFunc(value)
          if _isTableEqual(extraKey, splitPointData, firstMatchFlag) then
            local group = _G.ProtoMessage:newRedPointGroup()
            group.reason_type = reason
            table.insert(group.point_data, value)
            table.insert(req.point_group, group)
            if true ~= firstMatchFlag then
              break
            end
          end
        end
      else
        for _, value in pairs(p.oriPointData) do
          if extraKey == value then
            local group = _G.ProtoMessage:newRedPointGroup()
            group.reason_type = reason
            table.insert(group.point_data, value)
            table.insert(req.point_group, group)
          end
        end
      end
    else
      local group = _G.ProtoMessage:newRedPointGroup()
      group.reason_type = reason
      for _, value in pairs(p.oriPointData) do
        table.insert(group.point_data, value)
      end
      table.insert(req.point_group, group)
    end
  end
  if 0 == #req.point_group then
    return
  end
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_ERASE_RED_POINT_REQ, req)
end

function RedPointModule:OnCmdGetRedPointSplitPointDataByKeyAndReason(key, reason)
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpNode = rpNodeDic[key]
  local litUpReasonDic = rpNode.litUpReasonDic
  local oriPointData
  if litUpReasonDic[reason] then
    oriPointData = litUpReasonDic[reason].oriPointData
    if nil == oriPointData then
      return nil
    end
  else
    return nil
  end
  local splitPointData = {}
  for i, v in pairs(oriPointData) do
    splitPointData[i] = litUpReasonDic[reason].splitFunc(v)
  end
  return splitPointData
end

function RedPointModule:EraseRedPointWithReason(reason, extraKey)
  local req = _G.ProtoMessage:newZoneEraseRedPointReq()
  local group = _G.ProtoMessage:newRedPointGroup()
  group.reason_type = reason
  table.insert(group.point_data, extraKey)
  table.insert(req.point_group, group)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_ERASE_RED_POINT_REQ, req, self, self.OnZoneEraseRedPointRsp)
end

function RedPointModule:OnZoneEraseRedPointRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("ZoneEraseRedPointRsp ret_code", rsp.ret_info.ret_code)
    return
  end
end

function RedPointModule:OnCmdRegRedPointUI(redPointUI)
  if nil == redPointUI then
    return
  end
  self.data:RegRedPointUI(redPointUI)
  redPointUI:Refresh()
end

function RedPointModule:OnCmdUnRegRedPointUI(redPointUI)
  if nil == redPointUI then
    return
  end
  self.data:UnRegRedPointUI(redPointUI)
end

function RedPointModule:OnCmdShowDebugInfo(bShow)
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpUIDic = self.data:GetRedPointUIDic()
  for key, _ in pairs(rpNodeDic) do
    local uis = rpUIDic[key]
    if uis and next(uis) then
      for _, ui in pairs(uis) do
        ui:ShowDebugInfo(bShow)
      end
    end
  end
  local playerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo()
  Log.Dump(playerInfo.red_point_info, 9, "#red_point_info#")
end

function RedPointModule:OnCmdChangeDebugInfoPostion(positinIdx)
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpUIDic = self.data:GetRedPointUIDic()
  for key, _ in pairs(rpNodeDic) do
    local uis = rpUIDic[key]
    if uis and next(uis) then
      for _, ui in pairs(uis) do
        ui:ChangeDebugInfoPostion(positinIdx)
      end
    end
  end
end

function RedPointModule:OnCmdChangeDebugInfoColor(colorIdx)
  local rpNodeDic = self.data:GetRedPointNodeDic()
  local rpUIDic = self.data:GetRedPointUIDic()
  for key, _ in pairs(rpNodeDic) do
    local uis = rpUIDic[key]
    if uis and next(uis) then
      for _, ui in pairs(uis) do
        ui:ChangeDebugInfoColor(colorIdx)
      end
    end
  end
end

function RedPointModule:OnCmdGmUpdateRedPoint(opType, reason, pointData)
  local req = _G.ProtoMessage:newZoneGmUpdatePlayerRedPointReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.op_type = opType
  local group = _G.ProtoMessage:newRedPointGroup()
  group.reason_type = reason
  table.insert(group.point_data, pointData)
  table.insert(req.rp_group, group)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UPDATE_PLAYER_RED_POINT_REQ, req, self, self.OnZoneGmUpdatePlayerRedPointRsp)
end

function RedPointModule:OnZoneGmUpdatePlayerRedPointRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("ZoneGmUpdatePlayerRedPointRsp ret_code", rsp.ret_info.ret_code)
    return
  end
end

function RedPointModule:OnZoneRedPointNotify(notify)
  Log.Dump(notify, 9, "RedPointModule:OnZoneRedPointNotify")
  table.insert(self.CachedNotify, notify)
  if _G.PlayerModuleCmd and _G.PlayerModuleCmd.GET_LOCAL_PLAYER then
    self.StatusChecker:Check(self, self.UpdateWithCachedNotify)
  else
    self:UpdateWithCachedNotify()
  end
  _G.NRCEventCenter:DispatchEvent(RedPointModuleEvent.RedPointChange, notify)
end

function RedPointModule:UpdateWithCachedNotify()
  for _, notify in ipairs(self.CachedNotify) do
    if notify.rp_group then
      for _, group in ipairs(notify.rp_group) do
        self:UpdateWithReasonPointData(group.reason_type, group.point_data)
      end
    end
    if notify.reason then
      local reason = notify.reason
      local point_data = notify.point_data
      self:UpdateWithReasonPointData(reason, point_data)
    end
  end
  table.clear(self.CachedNotify)
end

function RedPointModule:UpdateWithReasonPointData(reason, point_data, DataIsNewest)
  local shouldUpdateFlag = self:CheckRedPointDataShouldUpdate(reason, point_data)
  if shouldUpdateFlag then
    if nil == DataIsNewest then
      DataIsNewest = true
    end
    self.data:UpdateRedPointData(reason, point_data, DataIsNewest)
    self.data:UpdatePlayerRedPointInfo(reason, point_data)
    if DataIsNewest then
      self.data:ReInvalidPointData(reason)
    end
    self:RefreshRedPointUIByReason(reason)
  end
end

function RedPointModule:UpdateWithReasonPointDataWithoutRefreshUI(reason, point_data, DataIsNewest)
  self.data:UpdateRedPointData(reason, point_data, DataIsNewest)
  self.data:UpdatePlayerRedPointInfo(reason, point_data)
end

function RedPointModule:CheckRpNodeIsLeaf(rpNode)
  return self.data:CheckRPNodeIsLeaf(rpNode)
end

function RedPointModule:CheckRedPointDataShouldUpdate(reason, point_data)
  local rpNodes = self.data.ReasonToRpNodesDic[reason]
  if not rpNodes then
    Log.Error("rpNodes \228\184\186\231\169\186\239\188\140reason\230\152\175" .. reason)
    return false
  end
  if rpNodes[1] and rpNodes[1].litUpReasonDic[reason] then
    local oriPointData = rpNodes[1].litUpReasonDic[reason].oriPointData
    if point_data and 0 == #point_data then
      return true
    end
    if nil == point_data or nil == oriPointData then
      return true
    end
    if #point_data ~= #oriPointData then
      return true
    end
    for i = 1, #oriPointData do
      if nil == point_data[i] or nil == oriPointData[i] then
        return true
      end
      if point_data[i] ~= oriPointData[i] then
        return true
      end
    end
    return false
  end
  return true
end

function RedPointModule:GetReasonPointData(reason)
  return self.data:GetReasonPointData(reason)
end

function RedPointModule:InvalidPointData(key, extraKey)
  self.data:InvalidPointData(key, extraKey)
end

function RedPointModule:RecoverPointData(key, extraKey)
  self.data:RecoverPointData(key, extraKey)
end

function RedPointModule:GetRedPointCfgs()
  if not self.data.rpCfgs then
    self.data.rpCfgs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.RED_POINT_CONF):GetAllDatas()
  end
  return self.data.rpCfgs
end

function RedPointModule:IsRedPointLightUp(key, extraKey)
  local rpNodeDic = self.data:GetRedPointNodeDic()
  if not rpNodeDic or not key then
    return nil
  end
  local rpNode = rpNodeDic[key]
  if not rpNode then
    return
  end
  if extraKey then
    local ReasonDic = {}
    if self:CheckRpNodeIsLeaf(rpNode) then
      ReasonDic = rpNode.litUpReasonDic
    else
      ReasonDic = rpNode.popReasonDic
    end
    for reason, pointdata in pairs(ReasonDic) do
      if pointdata.oriPointData and self.data:CalcuTableLength(pointdata.oriPointData) > 0 then
        for i, pointDataStr in pairs(pointdata.oriPointData) do
          if self.data:CheckExtraKeyIsMatchPointDataStr(extraKey, pointDataStr) then
            return true
          end
        end
      end
    end
    return false
  else
    return rpNode.redCount and rpNode.redCount > 0
  end
end

function RedPointModule:DebugProcessSvrRedPointData()
  local allDatas = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.RED_POINT_CONF):GetAllDatas()
  local key2ParentKeys = {}
  for _, _data in pairs(allDatas) do
    local childId = _data.child_id
    if childId and #childId > 0 then
      for _, _id in ipairs(childId) do
        local parents = key2ParentKeys[_id]
        if not parents then
          parents = {}
          key2ParentKeys[_id] = parents
        end
        if not table.contains(parents, _data.id) then
          table.insert(parents, _data.id)
        end
      end
    end
  end
  local reason2Key = {}
  local reason2Type = {}
  for _, _data in pairs(allDatas) do
    local changeReasons = _data.change_reason
    if changeReasons and #changeReasons > 0 then
      local _reason = changeReasons[1]
      reason2Key[_reason] = _data.id
      local redPointType = _data.redpoint_type
      if redPointType and #redPointType > 0 then
        reason2Type[_reason] = _data.redpoint_type[1]
      end
    end
  end
  local svrRedPointData = {}
  do
    local redPointInfo = _G.DataModelMgr.PlayerDataModel:GetRedPointInfo()
    if redPointInfo then
      for _, group in ipairs(redPointInfo) do
        svrRedPointData[group.reason_type] = group.point_data
      end
    end
    if self.CachedNotify then
      for _, notify in ipairs(self.CachedNotify) do
        if notify.rp_group then
          for _, group in ipairs(notify.rp_group) do
            svrRedPointData[group.reason_type] = group.point_data
          end
        end
      end
    end
  end
  local DebugData = {}
  for _reason, _pointDataT in pairs(svrRedPointData) do
    local debugDataItem = {}
    debugDataItem.reason = _reason
    debugDataItem.type = reason2Type[_reason]
    debugDataItem.key = reason2Key[_reason]
    debugDataItem.parentKeys = key2ParentKeys[debugDataItem.key]
    debugDataItem.pointData = _pointDataT
    DebugData[_reason] = debugDataItem
  end
  return DebugData
end

function RedPointModule:DumpSvrRedPointData()
  local svrRedPointData = self:DebugProcessSvrRedPointData()
  local DebugData = {
    ["\230\156\141\229\138\161\229\153\168\231\186\162\231\130\185\230\149\176\230\141\174"] = svrRedPointData
  }
  return DebugData
end

return RedPointModule
