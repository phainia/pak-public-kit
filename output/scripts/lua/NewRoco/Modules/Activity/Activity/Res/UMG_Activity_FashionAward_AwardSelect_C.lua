local UMG_Activity_FashionAward_AwardSelect_C = _G.NRCPanelBase:Extend("UMG_Activity_FashionAward_AwardSelect_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_FashionAward_AwardSelect_C:OnConstruct()
  self:SetChildViews(self.FashionOption1, self.FashionOption2, self.FashionOption3)
  self:AddButtonListener(self.CloseBtn, self.OnClickClose)
  self:AddButtonListener(self.EmptyButton, self.OnClickClose)
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnClickClose)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnClickOk)
  self.TxtPower:SetText(_G.LuaText.activity_login_gift_choose_tips)
  self.Btn1:SetBtnText(_G.LuaText.activity_login_gift_choose_laterbutton_text)
  self.Btn2:SetBtnText(_G.LuaText.activity_login_gift_choose_surebutton_text)
  self.Btn2:SetIsEnabled(false)
end

function UMG_Activity_FashionAward_AwardSelect_C:OnActive(bagItem, treasureCfg)
  _G.NRCAudioManager:PlaySound2DAuto(40010019, "UMG_Activity_FashionAward_AwardSelect_C:OnActive")
  self.bagItem = bagItem
  for index, item in ipairs(treasureCfg and treasureCfg.choose_item_group or {}) do
    local itemCfg = _G.DataConfigManager:GetBagItemConf(item.Id)
    local itemBehavior = itemCfg and itemCfg.item_behavior and itemCfg.item_behavior[1]
    if itemBehavior and itemBehavior.use_action == Enum.ItemBehavior.IB_GET_AWARD then
      local rewardId = itemBehavior.ratio and itemBehavior.ratio[1]
      local rewardData = ActivityUtils.GetActivityRewardData(rewardId, true, true)
      if rewardData.itemType == Enum.GoodsType.GT_FASHION_SUITS then
        local fashionOptionItem = self["FashionOption" .. index]
        if fashionOptionItem then
          local fashionAwardItem = {
            optionCtrl = fashionOptionItem,
            index = index - 1,
            alreadyHave = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckHasSuit, rewardData.itemId)
          }
          fashionOptionItem:SetSelectCallback(_G.MakeWeakFunctor(self, self.OnClickChooseItem, fashionAwardItem))
          fashionOptionItem:SetExamineBtnCallback(_G.MakeWeakFunctor(self, self.OnClickShowItemTips, rewardData.itemType, rewardData.itemId))
          fashionOptionItem:SetName(rewardData.itemName)
          fashionOptionItem:SetCharacterImage(rewardData.showIcon)
          fashionOptionItem:SetAlreadyHave(fashionAwardItem.alreadyHave)
          local petIcon = ""
          local suitCfg = _G.DataConfigManager:GetFashionSuitsConf(rewardData.itemId)
          if suitCfg and (suitCfg.suit_grade == Enum.SuitGrade.SG_UNIBOND or suitCfg.suit_grade == Enum.SuitGrade.SG_BOND) and suitCfg.petbase_id and #suitCfg.petbase_id > 0 then
            local petBaseConf = _G.DataConfigManager:GetPetbaseConf(suitCfg.petbase_id[1])
            if petBaseConf then
              local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
              petIcon = modelConf and modelConf.icon
            end
          end
          fashionOptionItem:SetPetIcon(petIcon)
        end
      end
    end
  end
end

function UMG_Activity_FashionAward_AwardSelect_C:OnClickChooseItem(item)
  if not item then
    return
  end
  if item.alreadyHave then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.choose_reward_cant_repeat_tips)
    return
  end
  local preSelectItem = self.selectItem
  self.selectItem = item
  if preSelectItem and preSelectItem.optionCtrl then
    preSelectItem.optionCtrl:SetSelect(false)
  end
  if item.optionCtrl then
    item.optionCtrl:SetSelect(true)
  end
  self.Btn2:SetIsEnabled(true)
end

function UMG_Activity_FashionAward_AwardSelect_C:OnClickShowItemTips(itemType, itemId)
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, itemId, itemType, false)
end

function UMG_Activity_FashionAward_AwardSelect_C:OnClickOk()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_FashionAward_AwardSelect_Item_C:OnExamineBtnClick")
  local selectItem = self.selectItem
  if not selectItem then
    return
  end
  local bagItem = self.bagItem
  if bagItem then
    local extraParam = {}
    extraParam.disableRewardsPanel = true
    extraParam.callback = _G.MakeWeakFunctor(nil, function(rsp)
      local goodsReward = rsp and rsp.ret_info and rsp.ret_info.goods_reward
      if goodsReward then
        local fakeRsp = _G.ProtoMessage:newZoneShopBuyItemRsp()
        fakeRsp.ret_info.ret_code = 0
        fakeRsp.ret_info.goods_reward = goodsReward
        local diamondReturnInfo
        local changes = rsp.ret_info and rsp.ret_info.goods_reward and rsp.ret_info.goods_reward.rewards
        if changes then
          for _, change in ipairs(changes) do
            if change.type == _G.Enum.GoodsType.GT_VITEM and change.id == _G.Enum.VisualItem.VI_DIAMOND then
              diamondReturnInfo = {
                type = change.type,
                id = change.id,
                num = change.num
              }
              break
            end
          end
        end
        if diamondReturnInfo then
          function fakeRsp.onCloseCallback()
            local rewardlist = {diamondReturnInfo}
            
            _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, rewardlist, "")
          end
        end
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenFashionBuyResultPopUp, fakeRsp)
      end
    end)
    _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.UseBagItem, bagItem.gid, bagItem.id, 1, selectItem.index, extraParam)
  end
  self:OnClickClose()
end

function UMG_Activity_FashionAward_AwardSelect_C:OnClickClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_FashionAward_AwardSelect_Item_C:OnExamineBtnClick")
  _G.NRCAudioManager:PlaySound2DAuto(40010012, "UMG_Activity_FashionAward_AwardSelect_Item_C:OnExamineBtnClick")
  self:OnClose()
end

function UMG_Activity_FashionAward_AwardSelect_C:OnPcClose()
  self:OnClickClose()
end

return UMG_Activity_FashionAward_AwardSelect_C
