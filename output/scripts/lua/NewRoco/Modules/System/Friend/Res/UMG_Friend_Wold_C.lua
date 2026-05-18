local UMG_Friend_Wold_C = _G.NRCPanelBase:Extend("UMG_Friend_Wold_C")

function UMG_Friend_Wold_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self.data = self.module:GetData("FriendModuleData")
  self.AllFlower = nil
  self.FriendInfo = nil
  self:OnAddEventListener()
end

function UMG_Friend_Wold_C:OnDestruct()
end

function UMG_Friend_Wold_C:OnDeactive()
end

function UMG_Friend_Wold_C:OnAddEventListener()
end

function UMG_Friend_Wold_C:OnActive(layerParam, all_flower, FriendInfo)
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").WORLD
  if _G.GlobalConfig.DebugOpenUI then
    local itemList = {}
    for i = 1, 6 do
      table.insert(itemList, i)
    end
    self.ItemList:InitGridView(itemList)
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
    self:SetCommonPopUpInfo()
    return
  end
  self.In = self:GetAnimByIndex(0)
  self.Loop = self:GetAnimByIndex(1)
  self.Out = self:GetAnimByIndex(2)
  self.AllFlower = all_flower
  self.FriendInfo = FriendInfo
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_Friend_Wold_C:OnActive")
  Log.Dump(self.AllFlower, 3, "UMG_Friend_Wold_C:OnActive")
  Log.Dump(self.FriendInfo, 3, "UMG_Friend_Wold_C:OnActive")
  self:SetCommonPopUpInfo()
  self:SetPanelInfo()
  self:PlayAnimation(self.In)
  self:BindInputAction()
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
end

function UMG_Friend_Wold_C:SetPanelInfo()
  if not self.FriendInfo then
    Log.Error("\230\178\161\230\156\137\229\165\189\229\143\139\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return
  end
  self:SetFlowerSeedInfoList()
end

function UMG_Friend_Wold_C:SetCommonPopUpInfo()
  local IsFriend = self.FriendInfo and self.data:IsHasFriend(self.data:GetFriendList(), self.FriendInfo.uin) or false
  local name
  if IsFriend then
    name = LuaText.friend_world_info
  else
    name = LuaText.players_interact_world_report
  end
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = name
  CommonPopUpData.Desc = LuaText.friend_visit_tips
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.Cancel
  CommonPopUpData.Btn_RightHandler = self.OnTeleportPlayer
  CommonPopUpData.Btn_RightText = LuaText.visible_circle_teleport_btn_text
  CommonPopUpData.ClosePanelHandler = self.Cancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_Friend_Wold_C:GetFlowerType(BossNpcInfo)
  local IsLimitedFlower = false
  local IsShinyFlower = false
  local Is7StarHardFlower = false
  if BossNpcInfo.spec_flower_seed_id and BossNpcInfo.activity_id then
    local activityConf = _G.DataConfigManager:GetActivityConf(BossNpcInfo.activity_id)
    if activityConf then
      if activityConf.activity_type == Enum.ActivityType.ATP_LIMITED_FLOWER_SEED then
        IsLimitedFlower = true
      elseif activityConf.activity_type == Enum.ActivityType.ATP_SHINY_WEEKEND_PREVIEW or activityConf.activity_type == Enum.ActivityType.ATP_SHINY_WEEKEND_START then
        IsShinyFlower = true
      elseif activityConf.activity_type == Enum.ActivityType.ATP_FLOWER_APPEAR_HARD then
        Is7StarHardFlower = true
      end
    end
  end
  return {
    IsLimitedFlower = IsLimitedFlower,
    IsShinyFlower = IsShinyFlower,
    Is7StarHardFlower = Is7StarHardFlower
  }
end

function UMG_Friend_Wold_C:SetFlowerSeedInfoList()
  if self.AllFlower.boss_npcs and #self.AllFlower.boss_npcs > 0 then
    self.Switcher_73:SetActiveWidgetIndex(0)
    table.sort(self.AllFlower.boss_npcs, function(a, b)
      local a_type = self:GetFlowerType(a)
      local b_type = self:GetFlowerType(b)
      local a_is_7star_hard_flower = a_type.Is7StarHardFlower
      local b_is_7star_hard_flower = b_type.Is7StarHardFlower
      local a_is_shiny_flower = a_type.IsShinyFlower
      local b_is_shiny_flower = b_type.IsShinyFlower
      local a_is_limit_flower = a_type.IsLimitedFlower
      local b_is_limit_flower = b_type.IsLimitedFlower
      if a_is_7star_hard_flower and not b_is_7star_hard_flower then
        return true
      end
      if not a_is_7star_hard_flower and b_is_7star_hard_flower then
        return false
      end
      if a_is_shiny_flower and not b_is_shiny_flower then
        return true
      end
      if not a_is_shiny_flower and b_is_shiny_flower then
        return false
      end
      if a_is_limit_flower and not b_is_limit_flower then
        return true
      end
      if not a_is_limit_flower and b_is_limit_flower then
        return false
      end
      if a.star == b.star then
        return a.npc_cfg_id < b.npc_cfg_id
      end
      return a.star > b.star
    end)
    self.ItemList:InitGridView(self.AllFlower.boss_npcs)
  else
    self.Switcher_73:SetActiveWidgetIndex(1)
  end
end

function UMG_Friend_Wold_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    self:PlayAnimation(self.Loop)
  elseif Anim == self.Out then
    self:DoClose()
  end
end

function UMG_Friend_Wold_C:Cancel()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Friend_Wold_C:OnActive")
  self:PlayAnimation(self.Out)
end

function UMG_Friend_Wold_C:OnTeleportPlayer()
  if _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.CheckInFightingOrObserver) then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.battle_chat_not_teleport)
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_Friend_Item_C:StartFriendVisit")
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OnCmdTeleportToPlayerReq, self.FriendInfo.uin)
end

function UMG_Friend_Wold_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_FriendWold")
  if mappingContext then
    mappingContext:BindAction("IA_CloseFriendWold", self, "OnPcClose2")
  end
end

function UMG_Friend_Wold_C:OnPcClose2()
  self:Cancel()
end

return UMG_Friend_Wold_C
