require("UnLuaEx")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local ItemEntryData = require("NewRoco.Modules.System.BattleUI.Res.ItemOperation.UMG_BattleItemEntry_C").Data
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BuffUtils = require("NewRoco.Modules.Core.Battle.Entity.Components.Buff.BuffUtils")
local UMG_BattleItemOperation_C = NRCPanelBase:Extend("UMG_BattleItemOperation_C")

function UMG_BattleItemOperation_C:Construct()
  self.Items = {
    self.UMG_BattleItemEntry_0,
    self.UMG_BattleItemEntry_1,
    self.UMG_BattleItemEntry_2,
    self.UMG_BattleItemEntry_3,
    self.UMG_BattleItemEntry_4,
    self.UMG_BattleItemEntry_5
  }
  if BattleUtils.IsTeam() then
    self:PlayAnimation(self.Displacement)
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.battleManager = _G.BattleManager
  self:PCKeySetting()
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_START, BattleEvent.DIRECT_UPDATE_UI, BattleEvent.UPDATE_DATA, BattleEvent.UI_UPDATE_PLAYERSKILL_TUTORIAL)
  _G.NRCEventCenter:RegisterEvent("UMG_BattleItemOperation_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
  NRCEventCenter:RegisterEvent("BattleItemOperation", self, BattlePerformEvent.SimulateClickItem0, self.SimulateClickItem0)
end

function UMG_BattleItemOperation_C:OnEnable(...)
  self:OnActive(...)
end

function UMG_BattleItemOperation_C:OnActive(pet, playAnim, callback)
  self:PCModeScreenSetting()
  self.pet = pet
  self:Show(playAnim, callback)
end

function UMG_BattleItemOperation_C:OnDisable()
  self:Hide(false)
end

function UMG_BattleItemOperation_C:OnDeactive()
  self:Hide(false)
end

function UMG_BattleItemOperation_C:WaitingRecycle()
  _G.BattleEventCenter:UnBind(self)
  NRCEventCenter:UnRegisterEvent(self, BattlePerformEvent.SimulateClickItem0, self.SimulateClickItem0)
end

function UMG_BattleItemOperation_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_START or eventName == BattleEvent.DIRECT_UPDATE_UI then
    self:InitItemData()
  elseif eventName == BattleEvent.UI_UPDATE_PLAYERSKILL_TUTORIAL then
    self:UpdatePlayerSkillTutorial(...)
  end
end

function UMG_BattleItemOperation_C:Destruct()
  table.clear(self.Items)
  self.TweenInCallback = nil
  self.TweenOutCallback = nil
  _G.BattleEventCenter:UnBind(self)
  NRCEventCenter:UnRegisterEvent(self, BattlePerformEvent.SimulateClickItem0, self.SimulateClickItem0)
  NRCUmgClass.Destruct(self)
end

function UMG_BattleItemOperation_C:PCKeySetting()
  self:SetUpPCKey()
end

function UMG_BattleItemOperation_C:GetTriggerInputActionName(type)
  if 0 == type then
    return self.triggerInputActionName
  end
end

function UMG_BattleItemOperation_C:SetUpPCKey()
  if SystemSettingModuleCmd then
    if self.UMG_BattleItemEntry_0 then
      self.UMG_BattleItemEntry_0.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_1")
      if "" ~= image then
        self.UMG_BattleItemEntry_0.Text_PCKey:SetImageMode(image)
      else
        self.UMG_BattleItemEntry_0.Text_PCKey:SetText(text)
      end
    end
    if self.UMG_BattleItemEntry_1 then
      self.UMG_BattleItemEntry_1.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_2")
      if "" ~= image then
        self.UMG_BattleItemEntry_1.Text_PCKey:SetImageMode(image)
      else
        self.UMG_BattleItemEntry_1.Text_PCKey:SetText(text)
      end
    end
    if self.UMG_BattleItemEntry_2 then
      self.UMG_BattleItemEntry_2.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_3")
      if "" ~= image then
        self.UMG_BattleItemEntry_2.Text_PCKey:SetImageMode(image)
      else
        self.UMG_BattleItemEntry_2.Text_PCKey:SetText(text)
      end
    end
    if self.UMG_BattleItemEntry_3 then
      self.UMG_BattleItemEntry_3.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_4")
      if "" ~= image then
        self.UMG_BattleItemEntry_3.Text_PCKey:SetImageMode(image)
      else
        self.UMG_BattleItemEntry_3.Text_PCKey:SetText(text)
      end
    end
    if self.UMG_BattleItemEntry_4 then
      self.UMG_BattleItemEntry_4.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_5")
      if "" ~= image then
        self.UMG_BattleItemEntry_4.Text_PCKey:SetImageMode(image)
      else
        self.UMG_BattleItemEntry_4.Text_PCKey:SetText(text)
      end
    end
    if self.UMG_BattleItemEntry_5 then
      self.UMG_BattleItemEntry_5.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_6")
      if "" ~= image then
        self.UMG_BattleItemEntry_5.Text_PCKey:SetImageMode(image)
      else
        self.UMG_BattleItemEntry_5.Text_PCKey:SetText(text)
      end
    end
  end
end

function UMG_BattleItemOperation_C:recordInputActionTrigger(inputActionName)
  self.triggerInputActionName = inputActionName
end

function UMG_BattleItemOperation_C:BattleMagicStart()
  if self.triggerInputActionName then
    return
  else
    _G.BattleEventCenter:Dispatch(BattleEvent.INPUT_ACTION_TRIGGER, "IA_BattleMagicStart")
  end
  self.UMG_BattleItemEntry_0:OnItemPressed()
end

function UMG_BattleItemOperation_C:BattleMagicEnd()
  if self.triggerInputActionName ~= "IA_BattleMagicStart" then
    return
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.INPUT_ACTION_TRIGGER)
  self.UMG_BattleItemEntry_0:OnItemRelease()
end

function UMG_BattleItemOperation_C:StopShowHide()
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_BattleItemOperation_C:Show(playAnim, callback)
  self:InitItemData()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.UMG_BattleItemEntry_0:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_BattleItemEntry_0.bNeedSetGuideWidget = true
  self.UMG_BattleItemEntry_1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_BattleItemEntry_2:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_BattleItemEntry_3:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_BattleItemEntry_4:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TweenOutCallback = nil
  if playAnim then
    self:StopAllAnimations()
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.TweenIn)
    self:PlayOpenAnim(true)
  end
  if callback then
    callback()
  end
  if BattleUtils.IsFinalBattle() then
    if self.BegFallIntoRank then
      self.BegFallIntoRank:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.NRCText_0 then
      self.NRCText_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:UpdatePlayerSkillTutorial(BuffUtils.IsPetHasPlayerSkillBuff(self.pet))
end

function UMG_BattleItemOperation_C:ChangeMaterial()
end

function UMG_BattleItemOperation_C:Hide(playAnim, callback)
  if playAnim then
    self:StopAllAnimations()
    self:PlayAnimation(self.TweenOut)
    self.TweenOutCallback = callback
    self:PlayOpenAnim(false)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if callback then
      callback()
    end
  end
end

function UMG_BattleItemOperation_C:SelectItem(index, isPressed)
  if self.Items[index] then
    if isPressed then
      self.Items[index]:OnItemPressed()
    else
      self.Items[index]:OnItemRelease()
    end
  end
end

function UMG_BattleItemOperation_C:OnAnimationFinished(Animation)
  if Animation == self.TweenIn then
  elseif Animation == self.TweenOut then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local Callback = self.TweenOutCallback
    self.TweenOutCallback = nil
    if Callback then
      Callback()
    end
  end
end

function UMG_BattleItemOperation_C:InitItemData()
  local team = _G.BattleManager.battlePawnManager:GetTeam(BattleEnum.Team.ENUM_TEAM)
  if not team then
    Log.Error("UMG_BattleItemOperation_C:InitItemData team is not found")
    return
  end
  local player = team.player
  if not player then
    Log.Error("UMG_BattleItemOperation_C:InitItemData player is not found")
    return
  end
  local itemData = player.itemInfo or {}
  local items = {}
  local isForbidItem = false
  local isForbidMagic = false
  local battleStartParam = _G.BattleManager.battleRuntimeData.battleStartParam
  if battleStartParam then
    isForbidItem = battleStartParam:CheckInitState(ProtoEnum.BATTLEFIELD_BIT_TYPE.BT_FORBID_ITEM)
    isForbidMagic = battleStartParam:CheckInitState(ProtoEnum.BATTLEFIELD_BIT_TYPE.BT_FORBID_ITEM_ROLE_MAGIC)
  end
  _G.IsOpenPlayerSkill = true
  if _G.IsOpenPlayerSkill then
    items[1] = {}
  end
  for _, v in ipairs(itemData) do
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(v.item_conf_id)
    local allow_use_cnt_inbattle = v.allow_use_cnt_inbattle
    if BagItemConf then
      if v.num > 0 and (BattleUtils.IsPvpWithForm() or true == v.is_equipped or BattleUtils.IsLeaderChallenge() or BattleUtils.IsNpcChallenge()) then
        if _G.IsOpenPlayerSkill and not isForbidMagic and v.item_type == ProtoEnum.BagItemType.BI_PLAYERSKILL then
          items[1] = ItemEntryData(v.item_id, v.item_conf_id, v.gid, v.num, v.is_charge, v.remain_use_cnt, v.max_use_cnt, v.allow_use_cnt, BagItemConf.type, v.battle_use_time_remain, v.battle_use_time_max, allow_use_cnt_inbattle)
        elseif v.item_type == ProtoEnum.BagItemType.BI_ITEM and not isForbidItem then
          table.insert(items, ItemEntryData(v.item_id, v.item_conf_id, v.gid, v.num, v.is_charge, v.remain_use_cnt, v.max_use_cnt, v.allow_use_cnt, BagItemConf.type, nil, nil, allow_use_cnt_inbattle))
        end
      end
    else
      Log.Error("UMG_BattleItemOperation_C:InitItemData item conf id is not found, id is ", v.item_conf_id)
    end
  end
  for Index, Item in ipairs(self.Items) do
    Item:SetData(items[Index], Index)
  end
end

function UMG_BattleItemOperation_C:HideFx()
end

function UMG_BattleItemOperation_C:SetMaterialAsset(Index, Item, ItemData)
  local MaterialAsset
  if 1 == Index or 4 == Index then
    if ItemData and ItemData.gid then
      MaterialAsset = BattleUtils.LoadResAsyncMaterial(BattleConst.ItemOperationMaterial.Material_1)
    else
      MaterialAsset = BattleUtils.LoadResAsyncMaterial(BattleConst.ItemOperationSprite.Sprite_1)
    end
  elseif 2 == Index or 6 == Index then
    if ItemData and ItemData.gid then
      MaterialAsset = BattleUtils.LoadResAsyncMaterial(BattleConst.ItemOperationMaterial.Material_2)
    else
      MaterialAsset = BattleUtils.LoadResAsyncMaterial(BattleConst.ItemOperationSprite.Sprite_2)
    end
  elseif 3 == Index or 5 == Index then
    if ItemData and ItemData.gid then
      MaterialAsset = BattleUtils.LoadResAsyncMaterial(BattleConst.ItemOperationMaterial.Material_3)
    else
      MaterialAsset = BattleUtils.LoadResAsyncMaterial(BattleConst.ItemOperationSprite.Sprite_3)
    end
  end
  Item:SetMaterialAssetInfo(MaterialAsset)
end

function UMG_BattleItemOperation_C:PlayOpenAnim(_IsOpen)
  local indexToItem = BattleUtils.GetMainWindowSubPanelItemOpenOrderTable(self.Items)
  for i, BagItemEntry in pairs(indexToItem) do
    if _IsOpen then
      BagItemEntry.CanvasPanel_0:SetRenderOpacity(0)
      self:PlaySkillItemAnim(BagItemEntry, _IsOpen, i)
    else
      BagItemEntry:PlayOpenAnimation(_IsOpen)
    end
  end
end

function UMG_BattleItemOperation_C:PlaySkillItemAnim(BagItemEntry, _IsOpen, i)
  BagItemEntry:DelayPlayAnim(_IsOpen, i)
end

function UMG_BattleItemOperation_C:SimulateClickItem0()
  self.UMG_BattleItemEntry_0:DoClick()
end

function UMG_BattleItemOperation_C:PCModeScreenSetting()
  if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() and not self.isSetPCMode then
    self.isSetPCMode = true
    self.CanvasPanel_31:SetRenderScale(UE4.FVector2D(0.88, 0.88))
    local Padding = UE4.FMargin()
    Padding.Left = -82
    Padding.Top = 0
    Padding.Right = 0
    Padding.Bottom = 0
    self.CanvasPanel_31.Slot:SetOffsets(Padding)
    self.HorizontalBox_115:SetRenderScale(UE4.FVector2D(0.88, 0.88))
  end
end

function UMG_BattleItemOperation_C:UpdatePlayerSkillTutorial(showPlayerSkillTutorialHighLight)
  for Index, Item in ipairs(self.Items) do
    Item:UpdatePlayerSkillTutorial(showPlayerSkillTutorialHighLight)
  end
end

return UMG_BattleItemOperation_C
