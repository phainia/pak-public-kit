local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_LegendaryBattle_Close_C = _G.NRCPanelBase:Extend("UMG_LegendaryBattle_Close_C")

function UMG_LegendaryBattle_Close_C:OnConstruct()
  self.itemDataList = {}
  local rsp
  self.data = self.module:GetData("LegendaryBattleModuleData")
  self.rspData = self.data:GetCatchSuccReward()
  if not self.rspData then
    self:FakeRsp()
  end
  self:SetChildViews(self.PopUp)
  self:InitDataList()
end

function UMG_LegendaryBattle_Close_C:OnActive()
  self:SetCommonPopUpInfo(self.PopUp)
  self:UpdateInfo()
  self:LoadAnimation(0)
end

function UMG_LegendaryBattle_Close_C:OnCloseBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_LegendaryBattle_Close_C:OnCloseBtnClick")
  _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_Result_Close)
  self:LoadAnimation(2)
end

function UMG_LegendaryBattle_Close_C:OnPcClose()
  self:OnCloseBtnClick()
end

function UMG_LegendaryBattle_Close_C:OnDeactive()
end

function UMG_LegendaryBattle_Close_C:OnAddEventListener()
end

function UMG_LegendaryBattle_Close_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_LegendaryBattle_Close_C:InitDataList()
  local tempBallId = DataConfigManager:GetLegendaryGlobalConfig("temp_ball_id").num
  local tempBallBagCfg = _G.DataConfigManager:GetBagItemConf(tempBallId)
  if not tempBallBagCfg then
    Log.Error("UMG_BattleBallEntry_C Bag Conf not found " .. tempBallId)
  else
    self.tempBallIconPath = NRCUtils:FormatConfIconPath(tempBallBagCfg.icon, _G.UIIconPath.BagItemPath)
  end
  local initInfo = BattleUtils.GetBattleInitInfo()
  local monsterConfId = _G.DataConfigManager:GetBattleConf(initInfo.battle_cfg_id[1]).npc_battle_list[1].pos1_1st[1]
  local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterConfId)
  local RewardId = self.data:GetLegendaryBattleAwardId(initInfo.beast_star, monsterConf.base_id)
  local RewardConf = _G.DataConfigManager:GetRewardConf(RewardId)
  local msg = _G.DataConfigManager:GetLocalizationConf("legendary_battle_title_1").msg
  if not self.rspData.ret_info.goods_reward or not self.rspData.ret_info.goods_reward.rewards then
    Log.Error("rewards \228\184\186\231\169\186")
    return
  end
  local displayName = ""
  if RewardConf then
    displayName = RewardConf.DisplayName
  end
  local itemData0 = {
    textCescribe = displayName,
    baseBallNum = self.rspData.base_ball_num,
    coinNum = self.rspData.ret_info.goods_reward.rewards and self.rspData.ret_info.goods_reward.rewards[1] and self.rspData.ret_info.goods_reward.rewards[1].num,
    iconPath = self.tempBallIconPath
  }
  table.insert(self.itemDataList, itemData0)
  if self.rspData.achieves then
    for i, achieve in pairs(self.rspData.achieves) do
      local achieveConfig = _G.DataConfigManager:GetLegendaryBattleAward(achieve.cfg_id)
      local itemData = {
        textCescribe = achieveConfig.name,
        baseBallNum = achieve.reward_ball_num,
        iconPath = self.tempBallIconPath
      }
      table.insert(self.itemDataList, itemData)
      if self.totalBaseBallNum then
        self.totalBaseBallNum = self.totalBaseBallNum + achieve.reward_ball_num
      else
        self.totalBaseBallNum = achieve.reward_ball_num
      end
    end
  else
    Log.Error("\229\144\142\229\143\176BeastBattleAchieves\230\149\176\230\141\174\228\184\186\231\169\186")
  end
end

function UMG_LegendaryBattle_Close_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_LegendaryBattle_Close_C:RemovePlayerLevel(_rewards)
  local rewards = {}
  for i, _ in ipairs(_rewards) do
    if _.type ~= _G.Enum.GoodsType.GT_VITEM or _.id ~= _G.Enum.VisualItem.VI_ROLE_LEVEL then
      table.insert(rewards, _)
    end
  end
  return rewards
end

function UMG_LegendaryBattle_Close_C:UpdateInfo()
  if self.totalBaseBallNum then
    self.totalBaseBallNum = self.totalBaseBallNum + self.rspData.base_ball_num
  else
    self.totalBaseBallNum = self.rspData.base_ball_num
  end
  self.ItemListScrollView:InitList(self.itemDataList)
  if self.itemDataList[1] then
    self.NRCImage_15:SetPath(self.itemDataList[1].iconPath)
    self.TextQuantity_1:SetText(string.format("x%s", self.itemDataList[1] and self.itemDataList[1].coinNum))
  end
  self.TextQuantity:SetText(" \195\151 " .. self.totalBaseBallNum)
  local msg = _G.DataConfigManager:GetLocalizationConf("legendary_battle_title_1").msg
  self.PopUp:SetTitleTextInfo(msg)
end

function UMG_LegendaryBattle_Close_C:SendBattleCatchConfirmReq()
end

function UMG_LegendaryBattle_Close_C:FakeRsp()
  self.rspData = ProtoMessage:newZoneBattleCatchConfirmRsp()
  self.rspData.ret_info.goods_reward.rewards[1] = {}
  self.rspData.ret_info.goods_reward.rewards[1].num = 7
  self.rspData.base_ball_num = 5
  local BeastBattleAchieves1 = ProtoMessage:newBeastBattleAchieves()
  BeastBattleAchieves1.achieve_type = 1
  BeastBattleAchieves1.reward_ball_num = 2
  BeastBattleAchieves1.cfg_id = 1001
  table.insert(self.rspData.achieves, BeastBattleAchieves1)
  local BeastBattleAchieves2 = ProtoMessage:newBeastBattleAchieves()
  BeastBattleAchieves2.achieve_type = 2
  BeastBattleAchieves2.reward_ball_num = 3
  BeastBattleAchieves2.cfg_id = 1002
  table.insert(self.rspData.achieves, BeastBattleAchieves2)
  local BeastBattleAchieves3 = ProtoMessage:newBeastBattleAchieves()
  BeastBattleAchieves3.achieve_type = 3
  BeastBattleAchieves3.reward_ball_num = 4
  BeastBattleAchieves3.cfg_id = 1003
  table.insert(self.rspData.achieves, BeastBattleAchieves3)
  local BeastBattleAchieves4 = ProtoMessage:newBeastBattleAchieves()
  BeastBattleAchieves4.achieve_type = 3
  BeastBattleAchieves4.reward_ball_num = 4
  BeastBattleAchieves4.cfg_id = 1004
  table.insert(self.rspData.achieves, BeastBattleAchieves4)
end

function UMG_LegendaryBattle_Close_C:HandleBattleCatchConfirmRsp(rsp)
end

return UMG_LegendaryBattle_Close_C
