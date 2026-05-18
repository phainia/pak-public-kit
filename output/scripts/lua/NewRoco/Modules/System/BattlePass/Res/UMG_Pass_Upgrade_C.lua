local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_Pass_Upgrade_C = _G.NRCPanelBase:Extend("UMG_Pass_Upgrade_C")

function UMG_Pass_Upgrade_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self:OnAddEventListener()
  self.bgProxy = _G.NRCModuleManager:DoCmd(TUIModuleCmd.PushBlackBackgroundWidgets, {
    self.FullStateMask,
    self.NRCImage_60
  })
  local goods_shop_id = self.module.data:GetBuyLevelGoodsShopId()
  local goodsCfg = _G.DataConfigManager:GetNormalShopConf(goods_shop_id)
  if goodsCfg and goodsCfg.price_goods_type == Enum.GoodsType.GT_VITEM then
    self.upgradeVisualItemType = goodsCfg.price_goods_id
  else
    Log.Error("UMG_Pass_Upgrade_C:OnConstruct invalid config", goodsCfg, (goodsCfg or {}).price_goods_type)
  end
end

function UMG_Pass_Upgrade_C:OnDestruct()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.bgProxy)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnVItemChangedHandler)
end

function UMG_Pass_Upgrade_C:OnActive()
  self.battlePassInfo = self.module.data:GetPlayerBattlePassInfo()
  local num2 = _G.NRCModuleManager:GetModule("BagModule").data:GetvItemNum(self.upgradeVisualItemType)
  local initData = {
    {
      moneyType = self.upgradeVisualItemType,
      sum = num2,
      IsShowBuyIcon = false
    }
  }
  self.MoneyBtn:InitGridView(initData)
  self.curLevel = self.battlePassInfo.exp_info.level
  self.toLevel = self.curLevel + 1
  self.themeId = self.battlePassInfo.theme_id
  self.isPaid = self.module.data:IsPaid()
  self.curLvCount = 1
  self.MaxLv = self.module.data:GetBpMaxLevel()
  self.battlePassId = self.battlePassInfo.battle_pass_id
  local battlePassCfg = _G.DataConfigManager:GetBattlePassConf(self.battlePassId)
  self.TOP_LEVEL = battlePassCfg.top_level
  self:SetCommonPopUpInfo()
  self.BUY_LEVEL_UNIT = self.module.data:GetBuyLevelUnit()
  self:SetCommonAddSubtractInfo(self.AddSubtract_NoProgressBar, nil, nil, "+" .. self.BUY_LEVEL_UNIT, "-" .. self.BUY_LEVEL_UNIT, 1)
  self:InitUI()
  self:UpdateUI()
  self:LoadAnimation(0)
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BattlePassModule", "BattlePassAwardMain", _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BattlePassAwardMain").UPGRADE)
  self:AddPcInputBlock()
end

function UMG_Pass_Upgrade_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Btn_RightText = LuaText.tips_dialog_butten_accept
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnBtnCancelClick
  CommonPopUpData.Btn_RightHandler = self.OnBtnBuyClick
  CommonPopUpData.Btn_LeftHandler = self.OnBtnCancelClick
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Pass_Upgrade_C:OnDeactive()
  self:CancelDelay()
  self:RemovePcInputBlock()
end

function UMG_Pass_Upgrade_C:AddPcInputBlock()
end

function UMG_Pass_Upgrade_C:RemovePcInputBlock()
end

function UMG_Pass_Upgrade_C:OnPcClose()
  self:OnBtnCancelClick()
end

function UMG_Pass_Upgrade_C:OnVItemChangedHandler()
  local num2 = _G.NRCModuleManager:GetModule("BagModule").data:GetvItemNum(self.upgradeVisualItemType)
  local initData = {
    {
      moneyType = self.upgradeVisualItemType,
      sum = num2,
      IsShowBuyIcon = false
    }
  }
  self.MoneyBtn:InitGridView(initData)
  self:UpdateCost()
end

function UMG_Pass_Upgrade_C:OnAddEventListener()
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnVItemChangedHandler)
end

function UMG_Pass_Upgrade_C:InitUI()
  local goods_shop_id = self.module.data:GetBuyLevelGoodsShopId()
  self.BUY_LEVEL_UNIT = self.module.data:GetBuyLevelUnit()
  local goodsCfg = _G.DataConfigManager:GetNormalShopConf(goods_shop_id)
  self.costPerLv = goodsCfg.origin_price
  self.goodsShopId = goods_shop_id
  local goodsSevData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, goodsCfg.shop_id, goodsCfg.id)
  if goodsSevData then
    self.costPerLv = goodsSevData.real_price.num
  end
  local BuyBtnDefaultColor = self.PopUp2.Btn_Right.Quantity.ColorAndOpacity
  self.BuyBtnDefaultColor = UE4.FSlateColor()
  self.BuyBtnDefaultColor.SpecifiedColor = BuyBtnDefaultColor.SpecifiedColor
  self.MaxCol = self.SecondLine.m_colCount
end

function UMG_Pass_Upgrade_C:SetCommonAddSubtractInfo(AddSubtract, SliderInfo, ProgressBarInfo, MultipleAddBtnText, MultipleSubtractBtnText, SelectNum)
  local CommonAddSubtractData = _G.NRCCommonAddSubtractData()
  if MultipleAddBtnText then
    CommonAddSubtractData.MultipleAddBtnText = MultipleAddBtnText
  end
  if MultipleSubtractBtnText then
    CommonAddSubtractData.MultipleSubtractBtnText = MultipleSubtractBtnText
  end
  CommonAddSubtractData.AddBtnHandler = self.OnAddClick
  CommonAddSubtractData.SubtractBtnHandler = self.OnReduceClick
  CommonAddSubtractData.MultipleAddBtnHandler = self.OnBtnPlusClick
  CommonAddSubtractData.MultipleSubtractBtnHandler = self.OnBtnSubtractClick
  CommonAddSubtractData.SelectNum = SelectNum
  CommonAddSubtractData.Call = self
  AddSubtract:SetPanelInfo(CommonAddSubtractData)
end

function UMG_Pass_Upgrade_C:UpdateUI()
  local title = _G.DataConfigManager:GetLocalizationConf("BP_buy_level").msg
  self.Text_Describe_1:SetText(string.format(title, self.curLevel, self.toLevel))
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.gender = player.gender
  if self.rewards == nil then
    self.rewards = self:GetUpRewards(self.curLevel + 1, self.toLevel)
    self:SetupGridView()
  else
    local oldCount = #self.rewards
    self.rewards = self:GetUpRewards(self.curLevel + 1, self.toLevel)
    local newCount = #self.rewards
    if oldCount <= newCount then
      self:SetupGridView()
      for i = oldCount + 1, newCount do
        local item = self.SecondLine:GetItemByIndex(i - 1)
        if item then
        else
          Log.Error("UMG_Pass_Upgrade_C:UpdateUI item is nil, the index is: ", i - 1)
        end
      end
    else
      for i = oldCount, newCount + 1, -1 do
        local item = self.SecondLine:GetItemByIndex(i - 1)
        if item then
        else
          Log.Error("UMG_Pass_Upgrade_C:UpdateUI item is nil, the index is: ", i - 1)
        end
      end
      self:DelaySeconds(0.21, function()
        self:SetupGridView()
      end)
    end
  end
  self.AddSubtract_NoProgressBar:SetSelectNumText(self.curLvCount)
  self:UpdateAddSubtractBtnState()
  self:UpdateCost()
end

function UMG_Pass_Upgrade_C:UpdateAddSubtractBtnState()
  if 1 == self.curLvCount then
    self.AddSubtract_NoProgressBar:SetSubtractBtnIsEnabledNewStyle(false)
  else
    self.AddSubtract_NoProgressBar:SetSubtractBtnIsEnabledNewStyle(true)
  end
  if self.toLevel == self.MaxLv then
    self.AddSubtract_NoProgressBar:SetAddBtnIsEnabledNewStyle(false)
  else
    self.AddSubtract_NoProgressBar:SetAddBtnIsEnabledNewStyle(true)
  end
end

function UMG_Pass_Upgrade_C:SetupGridView()
  local rewardsTable = {}
  for k, v in ipairs(self.rewards) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.Type
    rewards.itemId = v.Id
    rewards.itemNum = v.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(rewardsTable, rewards)
  end
  table.sort(rewardsTable, function(a, b)
    return a.itemId < b.itemId
  end)
  self.SecondLine:InitGridView(rewardsTable)
  if #self.rewards > self.MaxCol then
    self.ScrollBox_322.Slot:SetAutoSize(false)
  else
    self.ScrollBox_322.Slot:SetAutoSize(true)
  end
end

function UMG_Pass_Upgrade_C:OnBtnCancelClick()
  _G.NRCAudioManager:PlaySound2DAuto(1007, "UMG_Pass_Upgrade_C:OnBtnCancelClick")
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Pass_Upgrade_C:OnBtnCancelClick")
end

function UMG_Pass_Upgrade_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self.module:ShowOrHideMainTime(true)
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_Pass_Upgrade_C:OnBtnBuyClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401015, "UMG_Pass_Upgrade_C:OnBtnBuyClick")
  if self.MoneyEnough then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local title = LuaText.umg_pass_purchase_1
    local costCount = self.costPerLv * self.curLvCount
    local des = string.format(LuaText.bp_buy_level_confirm, costCount, self.toLevel - self.curLevel)
    local leftText = LuaText.umg_pass_purchase_2
    local rightText = LuaText.umg_pass_purchase_3
    local Context = DialogContext()
    Context:SetTitle(title):SetContent(des):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, self.OnBuy):SetCloseOnCancel(true):SetButtonText(rightText, leftText)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
  else
    local costCount = self.costPerLv * self.curLvCount
    local goods_shop_id = self.module.data:GetBuyLevelGoodsShopId()
    local goodsCfg = _G.DataConfigManager:GetNormalShopConf(goods_shop_id)
    local iconPath = NPCShopUtils:GetGoodsCurrencyIconByType(goodsCfg.price_goods_type, goodsCfg.price_goods_id, true)
    self.PopUp2.Btn_Right:SetClickAble(true)
    self.PopUp2.Btn_Right:SetTitleTextAndIcon(iconPath, costCount)
    self.PopUp2.Btn_Right.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:ShowItemNotEnoughDialog(costCount)
  end
end

function UMG_Pass_Upgrade_C:ShowItemNotEnoughDialog(costCount)
  if self.upgradeVisualItemType == _G.Enum.VisualItem.VI_COUPON then
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.JudgeBuyCouponGiftItem, costCount)
  elseif self.upgradeVisualItemType == _G.Enum.VisualItem.VI_DIAMOND then
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.JudgeBuyDiamondGiftItem, costCount)
  else
    Log.Error("UMG_Pass_Upgrade_C:ShowItemNotEnoughDialog not support this type:", tostring(self.upgradeVisualItemType))
  end
end

function UMG_Pass_Upgrade_C:OnBuy(isOk)
  if isOk then
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.BuyLevelReq, self.goodsShopId, self.curLvCount)
    self:DoClose()
  end
end

function UMG_Pass_Upgrade_C:OnBtnSubtractClick()
  _G.NRCAudioManager:PlaySound2DAuto(1220002009, "UMG_Pass_Upgrade_C:OnBtnSubtractClick")
  local newLvCount = self.curLvCount - self.BUY_LEVEL_UNIT
  if newLvCount <= 0 then
    if 1 == self.curLvCount then
      return
    end
    self.curLvCount = 1
    self.toLevel = self.curLevel + 1
    self:UpdateUI()
    return
  end
  self.curLvCount = newLvCount
  self.toLevel = self.curLevel + self.curLvCount
  self:UpdateUI()
end

function UMG_Pass_Upgrade_C:OnBtnPlusClick()
  _G.NRCAudioManager:PlaySound2DAuto(1220002011, "UMG_Pass_Upgrade_C:OnBtnPlusClick")
  local newLvCount = self.curLvCount + self.BUY_LEVEL_UNIT
  if self.curLevel + newLvCount > self.MaxLv then
    if self.curLevel + newLvCount >= self.MaxLv + self.BUY_LEVEL_UNIT then
      local canTirggerTips = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.CanAwardTablTipsTirgger)
      if false == canTirggerTips then
        return
      end
      local errorTips = _G.DataConfigManager:GetLocalizationConf("Error_bp_buylevel").msg
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, errorTips)
      return
    end
    self.curLvCount = self.curLvCount + (self.BUY_LEVEL_UNIT - (self.curLevel + newLvCount - self.MaxLv))
    self.toLevel = self.MaxLv
    self:UpdateUI()
    return
  end
  self.curLvCount = newLvCount
  self.toLevel = self.curLevel + self.curLvCount
  self:UpdateUI()
end

function UMG_Pass_Upgrade_C:OnAddClick()
  _G.NRCAudioManager:PlaySound2DAuto(1220002010, "UMG_Pass_Upgrade_C:OnAddClick")
  local newLvCount = self.curLvCount + 1
  if self.curLevel + newLvCount > self.MaxLv then
    local canTirggerTips = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.CanAwardTablTipsTirgger)
    if false == canTirggerTips then
      return
    end
    local errorTips = _G.DataConfigManager:GetLocalizationConf("Error_bp_buylevel").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, errorTips)
    return
  end
  self.curLvCount = newLvCount
  self.toLevel = self.curLevel + self.curLvCount
  self:UpdateUI()
end

function UMG_Pass_Upgrade_C:OnReduceClick()
  _G.NRCAudioManager:PlaySound2DAuto(1220002008, "UMG_Pass_Upgrade_C:OnReduceClick")
  local newLvCount = self.curLvCount - 1
  if newLvCount <= 0 then
    return
  end
  self.curLvCount = newLvCount
  self.toLevel = self.curLevel + self.curLvCount
  self:UpdateUI()
end

function UMG_Pass_Upgrade_C:OnAddMoneyBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_Pass_Upgrade_C:OnBtnBuyClick")
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenTopUpShop)
end

local function _GetAward(r, items, bp_level)
  for _, item in ipairs(items) do
    local key = item.Type .. "-" .. item.Id
    if r[key] then
      r[key].Count = item.Count + r[key].Count
    else
      r[key] = {
        Type = item.Type,
        Id = item.Id,
        Count = item.Count,
        level = bp_level
      }
    end
  end
end

function UMG_Pass_Upgrade_C:GetUpRewards(formLv, toLv)
  local themeId = self.themeId
  local reward_set_id = _G.DataConfigManager:GetBattlePassThemeConf(themeId).reward_set_id
  local passRewardCfgs = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.GetAllRewardConfig)
  local r = {}
  local tempRewaredCfg
  for i, cfg in ipairs(passRewardCfgs) do
    if cfg.belong_reward_set_id == reward_set_id then
      if cfg.bp_level == 999 then
        tempRewaredCfg = cfg
      elseif formLv <= cfg.bp_level and toLv >= cfg.bp_level and cfg.belong_reward_set_id == reward_set_id then
        local freeRewardId = cfg.male_free_reward_id
        if 2 == self.gender then
          freeRewardId = cfg.female_free_reward_id
        end
        local freeItems = _G.DataConfigManager:GetRewardConf(freeRewardId).RewardItem
        _GetAward(r, freeItems, cfg.bp_level)
        if self.isPaid then
          local paid_reward_id
          if 1 == self.gender then
            paid_reward_id = cfg.male_paid_reward_id
          else
            paid_reward_id = cfg.female_paid_reward_id
          end
          if nil ~= paid_reward_id and paid_reward_id > 0 then
            local paidItem = _G.DataConfigManager:GetRewardConf(paid_reward_id).RewardItem
            _GetAward(r, paidItem, cfg.bp_level)
          end
        end
      end
    end
  end
  if tempRewaredCfg and toLv > self.TOP_LEVEL then
    for i = self.TOP_LEVEL + 1, toLv do
      local freeItems = _G.DataConfigManager:GetRewardConf(tempRewaredCfg.free_reward_id).RewardItem
      _GetAward(r, freeItems, i)
      if self.isPaid then
        local paid_reward_id
        if 1 == self.gender then
          paid_reward_id = tempRewaredCfg.male_paid_reward_id
        else
          paid_reward_id = tempRewaredCfg.female_paid_reward_id
        end
        if nil ~= paid_reward_id and paid_reward_id > 0 then
          local paidItem = _G.DataConfigManager:GetRewardConf(paid_reward_id).RewardItem
          _GetAward(r, paidItem, i)
        end
      end
    end
  end
  local t = {}
  for _, value in pairs(r) do
    t[#t + 1] = value
  end
  table.sort(t, function(a, b)
    return a.level < b.level
  end)
  return t
end

function UMG_Pass_Upgrade_C:GetVITemCount()
  local sumMoneyNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(self.upgradeVisualItemType)
  return sumMoneyNum
end

function UMG_Pass_Upgrade_C:UpdateCost()
  local costCount = self.costPerLv * self.curLvCount
  local goods_shop_id = self.module.data:GetBuyLevelGoodsShopId()
  local goodsCfg = _G.DataConfigManager:GetNormalShopConf(goods_shop_id)
  local iconPath = NPCShopUtils:GetGoodsCurrencyIconByType(goodsCfg.price_goods_type, goodsCfg.price_goods_id, true)
  self.PopUp2.Btn_Right:SetClickAble(true)
  self.PopUp2.Btn_Right:SetTitleTextAndIcon(iconPath, costCount)
  self.PopUp2.Btn_Right.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local ownCount = self:GetVITemCount()
  if costCount <= ownCount then
    self.PopUp2.Btn_Right.Quantity:SetColorAndOpacity(self.BuyBtnDefaultColor)
    self.MoneyEnough = true
  else
    local color = UE4.FSlateColor()
    color.SpecifiedColor = UE4.FColor(255, 0, 0, 255):ToLinearColor()
    self.PopUp2.Btn_Right.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#af3d3e"))
    self.MoneyEnough = false
  end
end

return UMG_Pass_Upgrade_C
