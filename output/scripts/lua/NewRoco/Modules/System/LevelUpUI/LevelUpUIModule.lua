local LevelUpUIModule = NRCModuleBase:Extend("LevelUpUIModule")
local LevelUpUIModuleEvent = reload("NewRoco.Modules.System.LevelUpUI.LevelUpUIModuleEvent")

function LevelUpUIModule:OnConstruct()
  _G.LevelUpUIModuleCmd = reload("NewRoco.Modules.System.LevelUpUI.LevelUpUIModuleCmd")
  self.data = self:SetData("LevelUpUIModuleData", "NewRoco.Modules.System.LevelUpUI.LevelUpUIModuleData")
end

function LevelUpUIModule:OnDestruct()
end

function LevelUpUIModule:OnActive()
  self:RegisterCmd(LevelUpUIModuleCmd.SendQueryLevelAwardReq, self.OnCmdSendQueryLevelAwardReq)
  self:RegisterCmd(LevelUpUIModuleCmd.OpenLevelUpRewardPanel, self.OnCmdOpenLevelUpRewardPanel)
  self:RegisterCmd(LevelUpUIModuleCmd.OpenLevelBreakThroughPanel, self.OnCmdOpenBreakThrough)
  self:RegisterCmd(LevelUpUIModuleCmd.OpenLevelMagicianPanel, self.OnCmdOpenLevelMagician)
  self:RegisterCmd(LevelUpUIModuleCmd.RequestOpenLevelPanel, self.RequestOpenLevelPanel)
  self:RegisterCmd(LevelUpUIModuleCmd.SendGetLevelAwardReq, self.OnCmdSendGetLevelAwardReq)
  self:RegisterCmd(LevelUpUIModuleCmd.CheckIfLevelUpAwardsAvailable, self.CheckIfLevelUpAwardsAvailable)
  self:RegisterCmd(LevelUpUIModuleCmd.ChangeLevelListSelected, self.OnCmdLevelListSelectedChange)
  self:RegisterCmd(LevelUpUIModuleCmd.CheckCanSetItemSelect, self.CheckCanSetItemSelect)
  self:RegisterCmd(LevelUpUIModuleCmd.CloseLevelUpRewardPanel, self.OnCmdClosedLevelUpRewardPanel)
  self:RegisterCmd(LevelUpUIModuleCmd.ChangeLevelPlayerHead, self.OnCmdChangeLevelPlayerHead)
  self:RegisterCmd(LevelUpUIModuleCmd.ChangeLevelPlayerName, self.OnCmdChangeLevelPlayerName)
  self:RegisterCmd(LevelUpUIModuleCmd.LevelUpCloseCardSetLock, self.OnCmdLevelUpCloseCardSetLock)
  self:RegisterCmd(LevelUpUIModuleCmd.OpenLevelUpReward, self.OpenLevelUpReward)
  self:RegisterCmd(LevelUpUIModuleCmd.HasLevelMainPanel, self.HasLevelMainPanel)
  self:RegPanel("LevelUpRewards", "UMG_LevelUpRewards", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanelAutoRendering("LevelMain", "UMG_LevelMain", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  self:RegPanel("LevelBreakThrough", "UMG_LevelBreakThrough", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("LevelMagician", "UMG_LevelMagician", _G.Enum.UILayerType.UI_LAYER_DIALOGUE)
end

function LevelUpUIModule:OnDeactive()
end

function LevelUpUIModule:OnCmdOpenLevelUpRewardPanel(_param)
  if self:HasPanel("LevelMain") then
    local panel = self:GetPanel("LevelMain")
    panel:PlayAnimation(panel.In)
  elseif _param then
    self:OpenPanel("LevelMain", _param)
  end
end

function LevelUpUIModule:OnCmdClosedLevelUpRewardPanel()
  if self:HasPanel("LevelMain") then
    self:ClosePanel("LevelMain")
  end
end

function LevelUpUIModule:OnCmdChangeLevelPlayerHead()
  if self:HasPanel("LevelMain") then
    local panel = self:GetPanel("LevelMain")
    if panel then
      panel:UpdatePlayerHead()
    end
  end
end

function LevelUpUIModule:OnCmdChangeLevelPlayerName()
  if self:HasPanel("LevelMain") then
    local panel = self:GetPanel("LevelMain")
    if panel then
      panel:UpdatePlayerName()
    end
  end
end

function LevelUpUIModule:OnCmdLevelUpCloseCardSetLock(IsLock)
  self:DispatchEvent(LevelUpUIModuleEvent.LEVELUP_OPEN_CARD_SET_LOCK, IsLock)
end

function LevelUpUIModule:OnCmdOpenBreakThrough(_param)
  self:OpenPanel("LevelBreakThrough", _param)
end

function LevelUpUIModule:OnCmdOpenLevelMagician(param)
  self:OpenPanel("LevelMagician", param)
end

function LevelUpUIModule:CheckCanSetItemSelect(index)
  if self:HasPanel("LevelMain") then
    local panel = self:GetPanel("LevelMain")
    if panel and panel.UMG_LevelUpRewards then
      local curSelectIndex = panel.UMG_LevelUpRewards.curSelectedIndex
      if curSelectIndex and math.abs(index - curSelectIndex) > 2 then
        return false, index - curSelectIndex > 2 and curSelectIndex + 2 or curSelectIndex - 2
      end
      return true
    end
  end
end

function LevelUpUIModule:OnCmdLevelListSelectedChange(index)
  if self:HasPanel("LevelMain") then
    local panel = self:GetPanel("LevelMain")
    if panel then
      panel:ChangeLevelListSelected(index)
    end
  end
end

function LevelUpUIModule:CheckIfLevelUpAwardsAvailable()
  local valid_awards = DataModelMgr.PlayerDataModel.playerInfo.common_info.level_award_info.valid_awards
  if nil == valid_awards or 0 == #valid_awards then
    return false
  else
    return true
  end
end

function LevelUpUIModule:OnCmdSendQueryLevelAwardReq()
  Log.Debug("\233\161\181\233\157\162\230\137\147\229\188\128\229\187\182\232\191\159\233\151\174\233\162\152Log:\229\144\145\229\144\142\229\143\176\232\175\183\230\177\130\229\165\150\229\138\177\228\191\161\230\129\175", UE4Helper.GetTime())
  local req = _G.ProtoMessage:newZoneQueryLevelAwardReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_QUERY_LEVEL_AWARD_REQ, req, self, self.GetZoneQueryLevelAwardRsp, false, false)
end

function LevelUpUIModule:GetZoneQueryLevelAwardRsp(_rsp)
  if _rsp.awards == nil or 0 == _rsp.awards then
  else
    Log.Debug("\233\161\181\233\157\162\230\137\147\229\188\128\229\187\182\232\191\159\233\151\174\233\162\152Log:\229\144\142\229\143\176\229\155\158\229\140\133\229\136\176\228\186\134", UE4Helper.GetTime())
    self:CalcRewardsState(_rsp.awards.valid_awards)
  end
end

function LevelUpUIModule:OnCmdSendGetLevelAwardReq(level)
  local req = _G.ProtoMessage:newZoneGetLevelAwardReq()
  req.level = level
  self.level = level
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_LEVEL_AWARD_REQ, req, self, self.GetZoneGetLevelAwardRsp, false, true)
end

function LevelUpUIModule:GetZoneGetLevelAwardRsp(_rsp)
  if 0 ~= _rsp.ret_info.ret_code then
    local key = string.format("Error_Code_%d", _rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
    if self:HasPanel("LevelMain") then
      local panel = self:GetPanel("LevelMain")
      panel.UMG_LevelUpRewards.clickable = true
    end
  else
    if _rsp.awards ~= nil then
      self:CalcRewardsState(_rsp.awards.valid_awards)
      DataModelMgr.PlayerDataModel.playerInfo.common_info.level_award_info.valid_awards = _rsp.awards.valid_awards
    end
    if _rsp.ret_info.goods_reward.rewards and #_rsp.ret_info.goods_reward.rewards > 0 then
      _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, _rsp.ret_info.goods_reward.rewards, LuaText.levelupuimodule_1)
    end
  end
  self:DispatchEvent(LevelUpUIModuleEvent.LEVLEUP_Close_Mask)
end

function LevelUpUIModule:GetZoneExpChangeNotify(_rsp)
end

function LevelUpUIModule:RequestOpenLevelPanel()
  _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.SendQueryLevelAwardReq)
end

function LevelUpUIModule:CalcRewardsState(_param)
  local playerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
  self.param = _param
  for i, item in ipairs(worldLevelConf) do
    if worldLevel < item.world_level and playerLevel == item.update_grade_level then
      local req = _G.ProtoMessage:newZoneWorldLevelTaskQueryReq()
      req.world_level_task_id = item.update_task_id
      Log.Debug("\229\143\145\233\128\129\229\141\143\232\174\174\230\159\165\232\175\162\228\187\187\229\138\161\231\138\182\230\128\129", table.tostring(req))
      Log.Debug("\233\161\181\233\157\162\230\137\147\229\188\128\229\187\182\232\191\159\233\151\174\233\162\152Log:\229\143\175\232\131\189\232\191\152\232\166\129\230\159\165\232\175\162\228\184\128\228\184\139\228\187\187\229\138\161\231\154\132\231\138\182\230\128\129...", UE4Helper.GetTime())
      _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_WORLD_LEVEL_TASK_QUERY_REQ, req, self, self.GetSelectTaskTypeInfo)
      return
    end
  end
  self:GetSelectTaskTypeInfo(nil)
end

function LevelUpUIModule:GetSelectTaskTypeInfo(rsp)
  Log.Debug("LevelUpUIModule:GetSelectTaskTypeInfo", table.tostring(rsp))
  local _param = self.param
  local levelListInfo = {}
  local playerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
  local worldLevelMap = {}
  for i, item in ipairs(worldLevelConf) do
    worldLevelMap[item.world_level] = item
  end
  local RoleExpConfs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ROLE_EXP_CONF):GetAllDatas()
  local rewardSearchTable = {}
  if _param then
    for i = 1, #_param do
      rewardSearchTable[_param[i]] = true
    end
  end
  local RoleWorldLevelMap = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ROLE_WORLD_LEVEL_MAP_CONF):GetAllDatas()
  local shouldHaveIcon = false
  local last_used_index = -1
  for index, item in pairs(RoleWorldLevelMap) do
    if 1 == item.list_type then
      if item.grade_num > playerLevel + 5 then
        break
      end
      last_used_index = index
      local RoleExpItem = _G.DataConfigManager:GetRoleExpConf(item.grade_num)
      if playerLevel < item.grade_num then
        table.insert(levelListInfo, {
          type = item.list_type,
          level = item.grade_num,
          awardState = 0,
          data = RoleExpItem
        })
      elseif rewardSearchTable[item.grade_num] then
        table.insert(levelListInfo, {
          type = item.list_type,
          level = item.grade_num,
          awardState = 1,
          data = RoleExpItem
        })
        shouldHaveIcon = true
      else
        table.insert(levelListInfo, {
          type = item.list_type,
          level = item.grade_num,
          awardState = 2,
          data = RoleExpItem
        })
      end
    elseif 2 == item.list_type then
      last_used_index = index
      if worldLevelMap[item.grade_num] then
        local taskState = 0
        local worldLevelData = worldLevelMap[item.grade_num]
        if playerLevel < worldLevelData.update_grade_level then
          taskState = 1
        elseif playerLevel > worldLevelData.update_grade_level then
          taskState = 4
        elseif worldLevel >= item.grade_num then
          taskState = 4
        else
          Log.Dump(rsp, 3, "\232\191\153\228\184\170\232\166\129\233\151\174\228\184\128\228\184\139\229\144\142\229\143\176")
          if rsp.world_level_task_state == _G.ProtoEnum.WorldLevelTaskState.WLTS_UNABLE_TO_UNLOCK then
            taskState = 1
          elseif rsp.world_level_task_state == _G.ProtoEnum.WorldLevelTaskState.WLTS_ENABLE_TO_UNLOCK then
            taskState = 2
          elseif rsp.world_level_task_state == _G.ProtoEnum.WorldLevelTaskState.WLTS_IS_OPENED then
            taskState = 3
          elseif rsp.world_level_task_state == _G.ProtoEnum.WorldLevelTaskState.WLTS_IS_WAITED then
            taskState = 3
          elseif rsp.world_level_task_state == _G.ProtoEnum.WorldLevelTaskState.WLTS_IS_DONE then
            taskState = 4
          end
        end
        if _G.DataModelMgr.PlayerDataModel:IsVisitState() and not _G.DataModelMgr.PlayerDataModel:IsVisitOwner() and 2 == taskState then
          taskState = 6
        end
        local WorldLevelConfItem = _G.DataConfigManager:GetWorldLevelConf(item.grade_num + 1)
        table.insert(levelListInfo, {
          type = item.list_type,
          level = item.grade_num,
          awardState = taskState,
          data = WorldLevelConfItem
        })
      else
        Log.Error("\230\152\159\233\152\182\233\133\141\231\189\174\229\146\140\232\167\146\232\137\178\231\173\137\231\186\167\229\175\185\228\184\141\228\184\138", item.grade_num)
      end
    else
      Log.Error("\231\173\150\229\136\146\233\133\141\231\189\174\230\156\137\233\151\174\233\162\152list type\228\184\141\229\144\136\230\179\149", item.list_type)
    end
  end
  if last_used_index < #RoleWorldLevelMap then
    local lastLevelInfo = levelListInfo[#levelListInfo]
    if 1 == lastLevelInfo.type then
      if 0 == lastLevelInfo.awardState then
        lastLevelInfo.awardState = 5
      end
    elseif 2 == lastLevelInfo.type and 1 == lastLevelInfo.awardState then
      lastLevelInfo.awardState = 5
    end
  end
  Log.Debug("\233\161\181\233\157\162\230\137\147\229\188\128\229\187\182\232\191\159\233\151\174\233\162\152Log:\232\175\183\230\177\130\229\188\128\233\161\181\233\157\162!", UE4Helper.GetTime())
  if self:HasPanel("LevelMain") then
    NRCModuleManager:GetModule("LevelUpUIModule"):DispatchEvent(LevelUpUIModuleEvent.LEVELUP_REFRESH_REWARDS_PANEL, {levelListInfo = levelListInfo, shouldHaveIcon = shouldHaveIcon})
  else
    self:OnCmdOpenLevelUpRewardPanel({levelListInfo = levelListInfo, shouldHaveIcon = shouldHaveIcon})
  end
end

function LevelUpUIModule:RegPanel(name, path, layer)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/LevelUpUI/Res/%s", path)
  registerData.panelLayer = layer
  self:RegisterPanel(registerData)
end

function LevelUpUIModule:RegPanelAutoRendering(name, path, layer)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/LevelUpUI/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = true
  self:RegisterPanel(registerData)
end

function LevelUpUIModule:OpenLevelUpReward()
  self:OpenPanel("LevelUpRewards")
end

function LevelUpUIModule:HasLevelMainPanel()
  return self:HasPanel("LevelMain")
end

return LevelUpUIModule
