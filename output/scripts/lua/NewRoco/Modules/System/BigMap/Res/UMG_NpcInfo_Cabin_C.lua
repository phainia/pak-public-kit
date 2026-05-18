local UMG_NpcInfo_Cabin_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_Cabin_C")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local HomeUtils = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeUtils")

function UMG_NpcInfo_Cabin_C:OnConstruct()
  self:OnAddEventListener()
  self.Timer = TimerManager:CreateTimer(self, "UMG_NpcInfo_Cabin_C", math.maxinteger, self.OnSeconds, nil, 1)
  self.NRCText_9:SetText(LuaText.room_expend_succeed_map)
end

function UMG_NpcInfo_Cabin_C:OnDestruct()
  if self.Timer then
    TimerManager:RemoveTimer(self.Timer)
  end
end

function UMG_NpcInfo_Cabin_C:OnActive()
end

function UMG_NpcInfo_Cabin_C:OnDeactive()
end

function UMG_NpcInfo_Cabin_C:OnAddEventListener()
  self:AddButtonListener(self.BtnTransfer.btnLevelUp, self.TransferHomePlant)
  self:AddButtonListener(self.BtnTeleportationChamber.btnLevelUp, self.OnBtnTransferIndoorClick)
  self:AddButtonListener(self.Details.btnLevelUp, self.OnShowTips)
end

function UMG_NpcInfo_Cabin_C:OnBtnTransferClick()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_HOME, true)
  if isBan then
    return
  end
  if self.OnBtnTransferClickDelegate then
    self.OnBtnTransferClickDelegate()
  end
end

function UMG_NpcInfo_Cabin_C:TransferHomePlant()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_HOME, true)
  if isBan then
    return
  end
  local bCheckPlantMapUnlock = true
  local OwnerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerVisitOwnerUin() or 0
  if 0 ~= OwnerUin then
    local PlayerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
    if OwnerUin ~= PlayerUin then
      bCheckPlantMapUnlock = false
    end
  end
  if bCheckPlantMapUnlock then
    local bAbleToHomePlant = _G.DataModelMgr.PlayerDataModel:HasStoryFlag(_G.Enum.PlayerStoryFlagEnum.PSF_FUNC_HOME_START) and _G.DataModelMgr.PlayerDataModel:HasStoryFlag(_G.Enum.PlayerStoryFlagEnum.PSF_FUNC_UNLOCK_PLANT_LAND) and NRCModuleManager:DoCmd(BigMapModuleCmd.IsMapUnlock, 30002)
    if not bAbleToHomePlant then
      NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_50295)
      return
    end
  end
  local isBan1 = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
  if isBan1 then
    return
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer:IsInTogetherMove() then
    local banConf = _G.DataConfigManager:GetFunctionBanConf(106)
    if banConf then
      NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, banConf.ban_desc)
    end
    return
  end
  NRCModuleManager:DoCmd(HomeModuleCmd.ReqEnterPlayerHomeIndoor, nil, nil, nil, nil, nil, ProtoEnum.ZoneSceneHomeEnterReq.HomeSceneType.HomeSceneType_Plant)
end

function UMG_NpcInfo_Cabin_C:OnBtnTransferIndoorClick()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_HOME, true)
  if isBan then
    return
  end
  local isBan1 = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
  if isBan1 then
    return
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer:IsInTogetherMove() then
    local banConf = _G.DataConfigManager:GetFunctionBanConf(106)
    if banConf then
      NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, banConf.ban_desc)
    end
    return
  end
  NRCModuleManager:DoCmd(HomeModuleCmd.ReqEnterPlayerHomeIndoor)
end

function UMG_NpcInfo_Cabin_C:OnShowTips()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeComfortLevelTips)
end

function UMG_NpcInfo_Cabin_C:OnEnable(worldMap, npcInfo, OnBtnTransferClick, rsp)
  self.OnBtnTransferClickDelegate = OnBtnTransferClick
  local briefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo()
  if briefInfo then
    if rsp and rsp.friend_home_brief_info then
      self.npcName_3:SetText(string.format(LuaText.home_name, rsp.friend_home_brief_info.home_name))
    end
    self.NRCText_1:SetText(briefInfo.home_tag_name or "")
    self.Text_ComfortLevel:SetText(briefInfo.home_comfort_level or 0)
    self.Text_Class:SetText(briefInfo.home_level)
    self:InternalRefreshStatus()
    local room_conf = DataConfigManager:GetRoomConf(briefInfo.room_level)
    self.CabinIcon:SetPath(room_conf and room_conf.look)
  end
  self.npcDesc_2:SetText(worldMap.worldmap_npc_des)
  local friendCellHomeBriefInfo
  if rsp then
    friendCellHomeBriefInfo = rsp.friend_cell_home_brief_info
  end
  self:ShowHomePet(friendCellHomeBriefInfo)
  self:UpdatePlantStatus(friendCellHomeBriefInfo)
  self:SetHomeLevelRewardPanel()
end

function UMG_NpcInfo_Cabin_C:OnSeconds()
  self:InternalRefreshStatus()
end

function UMG_NpcInfo_Cabin_C:InternalRefreshStatus()
  local briefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo()
  local Status, Arg1, Arg2, Arg3 = HomeIndoorSandbox.Server:GetExpansionStatus(briefInfo.room_expansion_info, briefInfo.room_level)
  if Status == HomeIndoorSandbox.Enum.EnmExpandStatus.None then
    self.CanvasPanel_112:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_112:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self:CheckDisplayHomeIsMine() then
      self.NRCSwitcher_0:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      if Status == HomeIndoorSandbox.Enum.EnmExpandStatus.Expanding then
        self.NRCSwitcher_0:SetActiveWidgetIndex(1)
        local Remaining = Arg1
        local CostTime = Arg2
        local RoomLevelConf = Arg3
        Remaining = math.floor(Remaining)
        local Hour = Remaining // 3600
        Remaining = Remaining - Hour * 3600
        local Minus = Remaining // 60
        Remaining = Remaining - Minus * 60
        self.Time:SetText(string.format("%02d:%02d:%02d", Hour, Minus, Remaining))
      else
        self.NRCSwitcher_0:SetActiveWidgetIndex(0)
      end
    else
      self.NRCSwitcher_0:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_NpcInfo_Cabin_C:SetHomeLevelRewardPanel()
  self.HomeLevelRewardPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local redDotData = _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.GetReasonPointData, Enum.RedPointReason.RPR_HOME_LEVEL_REWARD)
  if redDotData and next(redDotData) and self:CheckDisplayHomeIsMine() then
    self.HomeLevelRewardPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_NpcInfo_Cabin_C:CheckDisplayHomeIsMine()
  local bDisplayHomeIsMine = false
  if HomeIndoorSandbox then
    local DisplayHomeBriefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo() or {}
    local DisplayHomeOwnerUin = DisplayHomeBriefInfo.home_owner_id or 0
    local MyHomeBriefInfo = HomeIndoorSandbox.Server:GetLocalHomeBriefInfo() or {}
    local MyUin = MyHomeBriefInfo.home_owner_id or 0
    if DisplayHomeOwnerUin == MyUin then
      bDisplayHomeIsMine = true
    end
  end
  return bDisplayHomeIsMine
end

function UMG_NpcInfo_Cabin_C:ShowHomePet(homeInfo)
  local homeBriefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo() or {}
  local bIsDisplayHomeOwner = homeBriefInfo.home_owner_id == _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local homePetInfoTable = {}
  if homeInfo then
    homePetInfoTable = HomeUtils.GetDisplayHomePetInfo(homeInfo)
  else
    local homePetInfos = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePetInfo)
    if homePetInfos and #homePetInfos then
      homePetInfoTable = HomeUtils.GetDisplayHomePetInfo(homePetInfos)
    end
  end
  if homePetInfoTable and #homePetInfoTable > 0 then
    self.Icon_List:InitGridView(homePetInfoTable)
    self.Icon_List:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HomePetPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  self.Icon_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HomePetPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_NpcInfo_Cabin_C:UpdatePlantStatus(homeInfo)
  local plantDisplayInfos = {}
  local homeBriefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo() or {}
  local bIsDisplayHomeOwner = homeBriefInfo.home_owner_id == _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  if homeInfo then
    plantDisplayInfos = FarmUtils.ExtraPlantDisplayInfo(homeInfo, not bIsDisplayHomeOwner)
  else
    local bInHomeScene = _G.NRCModuleManager:DoCmd(HomeModuleCmd.IsInHomeScene)
    if bInHomeScene then
      local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player and player.serverData then
        plantDisplayInfos = FarmUtils.ExtraPlantDisplayInfo(player.serverData, not bIsDisplayHomeOwner)
      end
    else
      Log.Warning("UMG_NpcInfo_Cabin_C:UpdatePlantStatus \229\143\136\228\184\141\229\156\168\229\174\182\229\155\173\233\135\140\233\157\162\239\188\140\229\143\136\230\178\161\231\148\179\232\175\183\230\149\176\230\141\174\239\188\140\230\178\161\230\149\176\230\141\174\229\177\149\231\164\186")
    end
  end
  plantDisplayInfos = FarmUtils.MergePlantDisplayInfo(plantDisplayInfos, true)
  self.Icon_List2:InitGridView(plantDisplayInfos)
  if 0 == #plantDisplayInfos then
    self.HomePetPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.HomePetPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_NpcInfo_Cabin_C
