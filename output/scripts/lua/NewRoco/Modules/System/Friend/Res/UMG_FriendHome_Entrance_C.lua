local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_FriendHome_Entrance_C = _G.NRCPanelBase:Extend("UMG_FriendHome_Entrance_C")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")

function UMG_FriendHome_Entrance_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_FriendHome_Entrance_C:OnDestruct()
  self:OnRemoveEventListener()
  if self.delayId then
    _G.DelayManager:CancelDelay(self.delayId)
    self.delayId = nil
  end
  if self.delayId_1 then
    _G.DelayManager:CancelDelay(self.delayId_1)
    self.delayId_1 = nil
  end
end

function UMG_FriendHome_Entrance_C:OnDeactive()
end

function UMG_FriendHome_Entrance_C:OnActive(homeInfo, homeOwnerId, friendCellHomeBriefInfo)
  _G.NRCAudioManager:PlaySound2DAuto(40006003, "UMG_FriendHome_Entrance_C:OnActive")
  if nil == homeInfo then
    Log.Error("UMG_FriendHome_Entrance_C:OnActive(homeInfo): homeInfo is nil")
    return
  end
  self.homeInfo = homeInfo
  self.homeOwnerId = homeOwnerId
  self.friendCellHomeBriefInfo = friendCellHomeBriefInfo
  self:RefreshView()
  self:PlayAnimation(self.In)
end

function UMG_FriendHome_Entrance_C:OnAddEventListener()
  self:AddButtonListener(self.BtnCancel.btnLevelUp, self.VisitHomeIndoor)
  self:AddButtonListener(self.BtnPayAVisit.btnLevelUp, self.VisitHomePlantGround)
  self:AddButtonListener(self.FullScreen_Close, self.OnClickBtnCancel)
  self:AddButtonListener(self.UMG_btnClose1.btnClose, self.OnClickBtnCancel)
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_HOME_ENTER_RSP, self.RestoreButtonClick)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendHome_Entrance_C", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.RestoreButtonClick)
end

function UMG_FriendHome_Entrance_C:OnRemoveEventListener()
  self:RemoveAllButtonListener()
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_HOME_ENTER_RSP, self.RestoreButtonClick)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.RestoreButtonClick)
end

function UMG_FriendHome_Entrance_C:OnClickBtnCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_FriendHome_Entrance_C:OnActive")
  self:PlayAnimation(self.Out)
end

function UMG_FriendHome_Entrance_C:VisitHomeIndoor()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_FriendHome_Entrance_C:OnActive")
  if _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.CheckInFightingOrObserver) then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.battle_chat_not_teleport)
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_HOME, true)
  if isBan then
    return
  end
  local limitHomeLevel = (_G.DataConfigManager:GetHomeGlobalConfig("home_visit_level", false) or {}).num or 5
  local friendHomeLevel = self.homeInfo and self.homeInfo.home_level or 1
  local selfHomeLevel = (_G.HomeIndoorSandbox.Server:GetLocalHomeBriefInfo() or {}).home_level or 1
  if limitHomeLevel > selfHomeLevel then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.home_visit_lock_mine, limitHomeLevel))
    return
  elseif limitHomeLevel > friendHomeLevel then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_50313)
    return
  end
  self.BtnCancel:SetIsEnabled(false)
  if self.delayId then
    _G.DelayManager:CancelDelay(self.delayId)
    self.delayId = nil
  end
  self.delayId = _G.DelayManager:DelaySeconds(3, self.RestoreButtonClick1, self)
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdSendZoneSceneHomeEnterReq, self.homeOwnerId)
end

function UMG_FriendHome_Entrance_C:VisitHomePlantGround()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_FriendHome_Entrance_C:OnActive")
  if _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.CheckInFightingOrObserver) then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.battle_chat_not_teleport)
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_HOME, true)
  if isBan then
    return
  end
  local limitHomeLevel = (_G.DataConfigManager:GetHomeGlobalConfig("home_visit_level", false) or {}).num or 5
  local friendHomeLevel = self.homeInfo and self.homeInfo.home_level or 1
  local selfHomeLevel = (_G.HomeIndoorSandbox.Server:GetLocalHomeBriefInfo() or {}).home_level or 1
  if limitHomeLevel > selfHomeLevel then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.home_visit_lock_mine, limitHomeLevel))
    return
  elseif limitHomeLevel > friendHomeLevel then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_50313)
    return
  end
  self.BtnPayAVisit:SetIsEnabled(false)
  if self.delayId_1 then
    _G.DelayManager:CancelDelay(self.delayId_1)
    self.delayId_1 = nil
  end
  self.delayId_1 = _G.DelayManager:DelaySeconds(3, self.RestoreButtonClick, self)
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdSendZoneSceneHomeEnterReq, self.homeOwnerId, nil, nil, nil, nil, ProtoEnum.ZoneSceneHomeEnterReq.HomeSceneType.HomeSceneType_Plant)
end

function UMG_FriendHome_Entrance_C:RestoreButtonClick()
  if self and self.BtnPayAVisit then
    self.BtnPayAVisit:SetIsEnabled(true)
  end
end

function UMG_FriendHome_Entrance_C:RestoreButtonClick1()
  if self and self.BtnCancel then
    self.BtnCancel:SetIsEnabled(true)
  end
end

local function _PetSortCompare(a, b)
  local statusPriority = {
    [_G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_CAN_STEAL] = 1,
    [_G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_IN_PRODUCT] = 2,
    [_G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_WAIT_PRODUCT] = 3,
    [_G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_CANT_STEAL] = 4,
    [_G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_GUARD] = 999
  }
  local aStatus = statusPriority[a.home_pet_info.status]
  local bStatus = statusPriority[b.home_pet_info.status]
  if aStatus ~= bStatus then
    return aStatus < bStatus
  end
  if a.level ~= b.level then
    return a.level > b.level
  end
  local aCfg = _G.DataConfigManager:GetPetbaseConf(a.base_conf_id)
  local bCfg = _G.DataConfigManager:GetPetbaseConf(b.base_conf_id)
  if aCfg and bCfg and aCfg.pictorial_book_id ~= bCfg.pictorial_book_id then
    return aCfg.pictorial_book_id < bCfg.pictorial_book_id
  end
  return false
end

function UMG_FriendHome_Entrance_C:RefreshView()
  local homeLv = math.max(self.homeInfo.home_level, 1)
  self.TextTitle:SetText(string.format(LuaText.home_name, self.homeInfo.home_name))
  self.Textclass:SetText(homeLv)
  self.ComfortLevel:InitGridView({
    self.homeInfo.home_comfort_level
  })
  local roomConf = _G.DataConfigManager:GetRoomConf(self.homeInfo.room_level)
  if roomConf then
    self.NRCText_7:SetText(roomConf.name)
    self.NRCText_8:SetText(roomConf.name)
    self.NRCText_9:SetText(roomConf.name)
    self.NRCText_10:SetText(roomConf.name)
    self.NRCText_11:SetText(roomConf.name)
    self.Photos:SetPath(roomConf.look)
  end
  self.HomeName:SetActiveWidgetIndex(self.homeInfo.room_level - 1)
  if self.friendCellHomeBriefInfo and self.friendCellHomeBriefInfo.home_pets and #self.friendCellHomeBriefInfo.home_pets > 0 then
    table.sort(self.friendCellHomeBriefInfo.home_pets, _PetSortCompare)
    if self.friendCellHomeBriefInfo.home_pets[#self.friendCellHomeBriefInfo.home_pets].home_pet_info and self.friendCellHomeBriefInfo.home_pets[#self.friendCellHomeBriefInfo.home_pets].home_pet_info.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_GUARD then
      table.remove(self.friendCellHomeBriefInfo.home_pets, #self.friendCellHomeBriefInfo.home_pets)
    end
  end
  if self.friendCellHomeBriefInfo and self.friendCellHomeBriefInfo.home_pets and #self.friendCellHomeBriefInfo.home_pets > 0 then
    self.Switcher:SetActiveWidgetIndex(0)
    self.PetList:InitList(self.friendCellHomeBriefInfo.home_pets)
  else
    self.Switcher:SetActiveWidgetIndex(1)
  end
  local isOpenHomeFunction = _G.NRCModuleManager:DoCmd(HomeModuleCmd.IsOpenHomeFunction)
  if isOpenHomeFunction then
    self.CanvasPanel_150:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_102:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_150:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanel_102:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local bUnlockPlantSystem = false
  if self.friendCellHomeBriefInfo and self.friendCellHomeBriefInfo.home_plant_info then
    bUnlockPlantSystem = self.friendCellHomeBriefInfo.home_plant_info.unlock == true
  end
  if bUnlockPlantSystem then
    self.Switcher_1:SetActiveWidgetIndex(0)
    local plantDisplayInfos = FarmUtils.ExtraPlantDisplayInfo(self.friendCellHomeBriefInfo, true)
    plantDisplayInfos = FarmUtils.MergePlantDisplayInfo(plantDisplayInfos)
    if 0 == #plantDisplayInfos then
      self.Switcher_1:SetActiveWidgetIndex(1)
    else
      self.PetList_1:InitList(plantDisplayInfos)
    end
  else
    self.Switcher_1:SetActiveWidgetIndex(2)
  end
end

function UMG_FriendHome_Entrance_C:OnPcClose()
  self:OnClickBtnCancel()
end

function UMG_FriendHome_Entrance_C:OnAnimationFinished(anim)
  if anim == self.Out then
    _G.NRCAudioManager:PlaySound2DAuto(40006007, "UMG_FriendHome_Entrance_C:OnActive")
    self:DoClose()
  end
end

return UMG_FriendHome_Entrance_C
