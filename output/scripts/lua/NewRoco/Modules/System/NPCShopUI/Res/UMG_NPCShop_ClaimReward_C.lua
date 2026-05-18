local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_NPCShop_ClaimReward_C = _G.NRCPanelBase:Extend("UMG_NPCShop_ClaimReward_C")

function UMG_NPCShop_ClaimReward_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
end

function UMG_NPCShop_ClaimReward_C:OnDestruct()
end

function UMG_NPCShop_ClaimReward_C:OnActive(_param, _param1, isRefresh)
  self.uiData = _param
  self.shopId = _param1
  self:SetUpInfos()
  if not isRefresh then
    self:OnAddEventListener()
    self:PlayAnimation(self:GetAnimByIndex(0))
  end
  self:SetCommonPopUpInfo()
end

function UMG_NPCShop_ClaimReward_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.TitleText = _G.DataConfigManager:GetLocalizationConf("shop_reward_collection").msg
  CommonPopUpData.Btn_LeftText = _G.DataConfigManager:GetLocalizationConf("shop_cancel").msg
  CommonPopUpData.Btn_RightText = _G.DataConfigManager:GetLocalizationConf("shop_confirm").msg
  CommonPopUpData.Desc = ""
  CommonPopUpData.ClosePanelHandler = self.OnBtnCloseClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp1:SetPanelInfo(CommonPopUpData)
end

function UMG_NPCShop_ClaimReward_C:OnDeactive()
end

function UMG_NPCShop_ClaimReward_C:RefreshInfos()
  local req = _G.ProtoMessage:newZoneShopGetInfoReq()
  req.shop_id = self.shopId
  local reqShopData = {
    shopId = self.shopId,
    Caller = self,
    rspHandler = self.GetStoreListRsp,
    needModal = false,
    ignoreErrorTip = false,
    reqTag = "UMG_NPCShop_ClaimReward_C:RefreshInfos"
  }
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OnCmdReqGetShopData, reqShopData)
end

function UMG_NPCShop_ClaimReward_C:GetStoreListRsp(_rsp)
  local isRefresh = true
  self:OnActive(_rsp.shop_data.consume_info, _rsp.shop_data.id, isRefresh)
end

function UMG_NPCShop_ClaimReward_C:SetUpInfos()
  local totalConsumptionConf = _G.DataConfigManager:GetShopTotalConsumptionConf(self.shopId)
  local iconPath = ""
  if totalConsumptionConf then
    iconPath = NPCShopUtils:GetGoodsCurrencyIconByType(totalConsumptionConf.price_goods_type, totalConsumptionConf.price_goods_id)
  end
  local text
  if self.uiData then
    text = self.uiData.total_consume_num
  else
    text = 0
  end
  self.AllText:SetText(text)
  self.CostIcon:SetPath(iconPath)
  local rewardList = self:SetRewardList()
  self.ItemView:InitList(rewardList)
end

local function compare(a, b)
  if a.isRewardTaken == true and b.isRewardTaken == false then
    return false
  elseif a.isRewardTaken == true and b.isRewardTaken == true then
    return a.rewardInfo.total_consumption_level < b.rewardInfo.total_consumption_level
  elseif a.isRewardTaken == false and b.isRewardTaken == false then
    return a.rewardInfo.total_consumption_level < b.rewardInfo.total_consumption_level
  elseif a.isRewardTaken == false and b.isRewardTaken == true then
    return true
  end
end

function UMG_NPCShop_ClaimReward_C:SetRewardList()
  local totalConsumptionConf = _G.DataConfigManager:GetShopTotalConsumptionConf(self.shopId)
  local shopConf = _G.DataConfigManager:GetShopConf(self.shopId)
  local currencyId
  if shopConf and shopConf.goods and #shopConf.goods > 0 then
    currencyId = shopConf.goods[1].goods_id
  else
    currencyId = totalConsumptionConf.currency_type
  end
  local rewardList = {}
  local nextLevel
  if self.uiData and self.uiData.reward_taken_info then
    nextLevel = #self.uiData.reward_taken_info + 1
    for i = 1, #totalConsumptionConf.shop_consumption_reward do
      if self.uiData.reward_taken_info[i] then
        table.insert(rewardList, {
          isRewardTaken = self.uiData.reward_taken_info[i].is_reward_taken,
          rewardInfo = totalConsumptionConf.shop_consumption_reward[i],
          shopId = self.shopId,
          currency_type = currencyId,
          total_consume_num = self.uiData.total_consume_num,
          nextLevel = nextLevel,
          price_goods_type = totalConsumptionConf.price_goods_type,
          price_goods_id = totalConsumptionConf.price_goods_id
        })
      else
        table.insert(rewardList, {
          isRewardTaken = false,
          rewardInfo = totalConsumptionConf.shop_consumption_reward[i],
          shopId = self.shopId,
          currency_type = currencyId,
          total_consume_num = self.uiData.total_consume_num,
          nextLevel = nextLevel,
          price_goods_type = totalConsumptionConf.price_goods_type,
          price_goods_id = totalConsumptionConf.price_goods_id
        })
      end
    end
  else
    nextLevel = 1
    for i = 1, #totalConsumptionConf.shop_consumption_reward do
      table.insert(rewardList, {
        isRewardTaken = false,
        rewardInfo = totalConsumptionConf.shop_consumption_reward[i],
        shopId = self.shopId,
        currency_type = currencyId,
        total_consume_num = 0,
        nextLevel = nextLevel,
        price_goods_type = totalConsumptionConf.price_goods_type,
        price_goods_id = totalConsumptionConf.price_goods_id
      })
    end
  end
  table.sort(rewardList, compare)
  return rewardList
end

function UMG_NPCShop_ClaimReward_C:OnAddEventListener()
end

function UMG_NPCShop_ClaimReward_C:OnBtnCloseClick()
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1061, "UMG_NPCShop_ClaimReward_C:OnBtnCloseClick")
  self:PlayAnimation(self:GetAnimByIndex(2))
end

function UMG_NPCShop_ClaimReward_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_NPCShop_ClaimReward_C
