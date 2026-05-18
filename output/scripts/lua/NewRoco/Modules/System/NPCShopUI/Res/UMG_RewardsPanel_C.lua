local NPCShopUIModuleEvent = require("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_RewardsPanel_C = _G.NRCPanelBase:Extend("UMG_RewardsPanel_C")

function UMG_RewardsPanel_C:OnConstruct()
  self.uiData = {}
  self.canClose = false
  UE4Helper.SetDesiredShowCursor(true, "UMG_RewardsPanel_C")
  self:AddPcInputBlock()
  self.bgProxy = _G.NRCModuleManager:DoCmd(TUIModuleCmd.PushBlackBackgroundWidgets, {
    self.NRCImage_35,
    self.NRCImage_17
  })
  self.IsOpenLegendaryBattleClosePanel = nil
end

function UMG_RewardsPanel_C:OnDestruct()
  UE4Helper.ReleaseDesiredShowCursor("UMG_RewardsPanel_C")
  self:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.bgProxy)
end

function UMG_RewardsPanel_C:OnActive(_param, text, reward_id, action, isOpenByBattleRewardPanel, IsOpenLegendaryBattleClosePanel)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400001, "UMG_ItemRewards_C:OnActive")
  local TitleText = text
  self.action = action
  self.isOpenByBattleRewardPanel = isOpenByBattleRewardPanel
  self.IsOpenLegendaryBattleClosePanel = IsOpenLegendaryBattleClosePanel
  if not _param and action then
    if reward_id then
      local RewardConf = _G.DataConfigManager:GetRewardConf(reward_id)
      if RewardConf then
        local RewardInfos = {}
        local RewardsInConf = RewardConf.RewardItem
        for _, item in ipairs(RewardsInConf) do
          table.insert(RewardInfos, {
            itemId = item.Id,
            id = item.Id,
            num = item.Count,
            type = item.Type,
            IsOverrideNum = true
          })
        end
        local text1 = LuaText.get_report_reward
        self.uiData = RewardInfos
        TitleText = text1
      end
    end
  else
    self.uiData = _param
  end
  self:PlayAnimation(self.open)
  self:OnAddEventListener()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  if not string.IsNilOrEmpty(TitleText) then
    self.NRCTitle:SetText(TitleText)
  end
  self:SetDatas(self.uiData)
  self:BindInputAction()
end

function UMG_RewardsPanel_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_RewardsPanel_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

function UMG_RewardsPanel_C:SetDatas(RewardsList)
  if self.isOpenByBattleRewardPanel and self.isOpenByBattleRewardPanel == true then
    if RewardsList and #RewardsList > 0 then
      local rewardsTable = _G.NRCCommonItemIconData():FromGoodsItem(RewardsList)
      for i = 1, #rewardsTable do
        rewardsTable[i].tag = self.uiData[i].tag
      end
      self.ItemList:InitList(rewardsTable)
      return
    else
      self.ItemList:Clear()
      return
    end
  end
  local SortRewardsList = self:SortItem(RewardsList)
  if SortRewardsList and #SortRewardsList > 0 then
    local rewardsTable = _G.NRCCommonItemIconData():FromGoodsItem(SortRewardsList)
    self.ItemList:InitList(rewardsTable)
  else
    self.ItemList:Clear()
  end
end

function UMG_RewardsPanel_C:SortItem(RewardsList)
  local SortRewardsList = {}
  for i, Reward in ipairs(RewardsList) do
    Reward.Sort = 0
    Reward.Conf = nil
    if Reward.type == _G.ProtoEnum.GoodsType.GT_VITEM then
      Reward.Sort = 999
      Reward.Conf = _G.DataConfigManager:GetVisualItemConf(Reward.id)
    elseif Reward.type == _G.ProtoEnum.GoodsType.GT_PET then
      Reward.Sort = 998
      Reward.Conf = _G.DataConfigManager:GetPetbaseConf(Reward.id)
    elseif Reward.type == _G.ProtoEnum.GoodsType.GT_BAGITEM then
      Reward.Sort = 997
      Reward.Conf = _G.DataConfigManager:GetBagItemConf(Reward.id)
    end
  end
  SortRewardsList = RewardsList
  table.sort(SortRewardsList, function(a, b)
    if a.Conf and b.Conf and a.Sort == b.Sort then
      if a.type == _G.ProtoEnum.GoodsType.GT_VITEM and b.type == _G.ProtoEnum.GoodsType.GT_VITEM then
        if (a.Conf.item_quality or 0) ~= (b.Conf.item_quality or 0) then
          return a.Conf.item_quality > b.Conf.item_quality
        else
          return a.Conf.sort_id < b.Conf.sort_id
        end
      elseif a.type == _G.ProtoEnum.GoodsType.GT_PET and b.type == _G.ProtoEnum.GoodsType.GT_PET then
        return a.Conf.id < b.Conf.id
      elseif a.type == _G.ProtoEnum.GoodsType.GT_BAGITEM and b.type == _G.ProtoEnum.GoodsType.GT_BAGITEM then
        if (a.Conf.item_quality or 0) ~= (b.Conf.item_quality or 0) then
          return a.Conf.item_quality > b.Conf.item_quality
        else
          return a.Conf.sort_id < b.Conf.sort_id
        end
      end
    else
      return a.Sort > b.Sort
    end
  end)
  return SortRewardsList
end

function UMG_RewardsPanel_C:OnDeactive()
end

function UMG_RewardsPanel_C:OnAddEventListener()
  self:AddButtonListener(self.Closebtn, self.OnBtnCloseClick)
end

function UMG_RewardsPanel_C:OnBtnCloseClick()
  if self.canClose == true then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400003, "UMG_ItemRewards_C:OnBtnCloseClick")
    self:PlayAnimation(self.close)
    self.canClose = false
  end
end

function UMG_RewardsPanel_C:OnAnimationFinished(Animation)
  if self.close == Animation then
    self.canClose = true
    if self.action then
      self.action:Finish()
    end
    _G.NRCModuleManager:GetModule("NPCShopUIModule"):DispatchEvent(NPCShopUIModuleEvent.NPCSHOP_ITEM_REWARS_CLOSE)
    if self.IsOpenLegendaryBattleClosePanel then
      _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_RewardsPanel_Close)
    end
    self:DoClose()
  elseif Animation == self.open then
    self:UnlockIsSelectBtn()
    self.canClose = true
  end
end

function UMG_RewardsPanel_C:UnlockIsSelectBtn()
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BattlePassModule", "BattlePassAwardMain", _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BattlePassAwardMain").GET)
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BattlePassModule", "BattlePassAwardMain", _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BattlePassAwardMain").TIPS)
end

function UMG_RewardsPanel_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_RewardsPanel")
  if mappingContext then
    mappingContext:BindAction("IA_CloseRewardsPanel", self, "OnPcClose2")
  end
end

function UMG_RewardsPanel_C:OnPcClose2()
  self:OnBtnCloseClick()
end

return UMG_RewardsPanel_C
