local UMG_Camping_Restore_C = _G.NRCPanelBase:Extend("UMG_Camping_Restore_C")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")

function UMG_Camping_Restore_C:OnConstruct()
  self.UiData = {}
  self.PanelType = nil
  self.UpgradeType = nil
  self.ClickEnable = true
  local insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu")
  self.insufficientText = insufficientText and insufficientText.msg or "\230\157\144\230\150\153\228\184\141\232\182\179\230\178\161\233\133\141\230\150\135\230\156\172"
  local LevelUpButtonText = _G.DataConfigManager:GetLocalizationConf("Camp_BTN_tisheng")
  self.LevelUpText:SetText(LevelUpButtonText and LevelUpButtonText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  local ItemRequiredText = _G.DataConfigManager:GetLocalizationConf("Camp_cailiao")
  self.ItemRequired:SetText(ItemRequiredText and ItemRequiredText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  local MaxLevelHint = _G.DataConfigManager:GetLocalizationConf("Camp_UP_tishengshangxian")
  self.MaxLevelHint_2:SetText(MaxLevelHint and MaxLevelHint.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  self.waitingForIncrease = false
  self.waitingForIncreaseValue = 0
  self.waitingForIncreaseType = nil
end

function UMG_Camping_Restore_C:OnDestruct()
  self:RemoveListener()
end

function UMG_Camping_Restore_C:OnActive(_param)
  self.UiData = nil
  self.PanelType = nil
  self.UpgradeType = nil
  self.ClickEnable = true
  self.Restore:Init()
  self:AddListener()
  self:RefreshPanel(_param)
  self:PlayAnimation(self.open)
end

function UMG_Camping_Restore_C:OnDeactive()
end

function UMG_Camping_Restore_C:AddListener()
  _G.NRCEventCenter:RegisterEvent("UMG_Camping_Restore_C", self, BagModuleEvent.BagItemAdd, self.BagItemUpdate)
  _G.NRCEventCenter:RegisterEvent("UMG_Camping_Restore_C", self, BagModuleEvent.BagItemUpdate, self.BagItemUpdate)
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtnClick)
  self:AddButtonListener(self.GetRewardsBtn, self.OnBtnGetRewardClick)
end

function UMG_Camping_Restore_C:RemoveListener()
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.BagItemUpdate)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.BagItemUpdate)
  self:RemoveAllButtonListener()
end

function UMG_Camping_Restore_C:BagItemUpdate(UpdateItem)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.RefreshPanelData)
end

function UMG_Camping_Restore_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    if self.Action then
      self.Action:EndAction()
    end
    self:DoClose()
  end
end

function UMG_Camping_Restore_C:RefreshPanel(_param)
  if self.UiData then
    local origin_origin_value = self.UiData.origin_value
    local origin_target_value = self.UiData.target_value
    local target_origin_value = _param.data.origin_value
    local target_target_value = _param.data.target_value
    if origin_origin_value < target_origin_value then
      self.Restore:PushLevelUpData({
        origin_origin_value = origin_origin_value,
        origin_target_value = origin_target_value,
        target_origin_value = target_origin_value,
        target_target_value = target_target_value,
        max_value = _param.data.max_value,
        caller = self,
        callback = self.OnRestoreAnimationFinished
      })
      self.waitingForIncrease = false
    end
  else
    self.Restore:SetUnderData(_param.data.origin_value, _param.data.target_value, _param.data.max_value)
    self.Restore.UMG_Camping_FontFX:PlayAnimation(self.Restore.UMG_Camping_FontFX.hide)
  end
  self.UiData = _param.data
  self.Action = _param.data.action
  self.ClickEnable = true
  for _, value in pairs(self.UiData.item_list) do
    if value.itemNum < value.itemNeedNum then
      self.ClickEnable = false
    end
  end
  if _param.open_type == _G.CampingModuleEnum.PanelType.BottleTime then
    self.Title:SetText(LuaText.umg_camping_restore_3)
    self.UpgradeType = _G.Enum.VisualItem.VI_BOTTLE_TIMES
  elseif _param.open_type == _G.CampingModuleEnum.PanelType.BottleVolume then
    self.Title:SetText(LuaText.umg_camping_restore_4)
    self.UpgradeType = _G.Enum.VisualItem.VI_BOTTLE_VOLUME
  end
  if self.UiData.max_value == self.UiData.origin_value then
    self.TextSwitcher:SetActiveWidgetIndex(1)
  else
    self.TextSwitcher:SetActiveWidgetIndex(0)
    self.List:InitGridView(self.UiData.item_list)
  end
  local upgradeEnable = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel() >= self.UiData.requiredLevel
  if upgradeEnable then
    self.ButtonSwitcher:SetActiveWidgetByWidgetName("Panel_Rewards")
  else
    self.ButtonSwitcher:SetActiveWidgetByWidgetName("TheLevel")
    self.LevelRequiredText:SetText(self.UiData.requiredLevel)
  end
end

function UMG_Camping_Restore_C:LockPlayer(switchState)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.inputComponent:SetInputEnable(self, not switchState)
end

function UMG_Camping_Restore_C:OnCloseBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_Camping_Restore_C:OnCloseBtnClick")
  self:PlayAnimation(self.close)
end

function UMG_Camping_Restore_C:OnBtnGetRewardClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_Camping_Restore_C:OnBtnGetRewardClick")
  if self.waitingForIncrease then
    Log.Debug("\231\173\137\229\190\133\230\149\176\230\141\174\230\143\144\229\141\135\228\184\173")
    return
  end
  if self.waitingForAnimation then
    Log.Debug("\231\173\137\229\190\133\229\138\168\231\148\187\230\146\173\229\174\140")
    return
  end
  if self.ClickEnable then
    self.waitingForIncrease = true
    self.waitingForAnimation = true
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.SendUpgradeReq, self.UpgradeType, self.UiData.upgradeId)
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.JustPlayCampingSkill, "/Game/ArtRes/Effects/G6Skill/Luying/MagicUpHeart.MagicUpHeart")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, self.insufficientText or "\228\184\141\231\159\165\233\129\147\228\184\186\228\187\128\228\185\136\230\152\175\231\169\186\231\154\132")
  end
end

function UMG_Camping_Restore_C:OnRestoreAnimationFinished()
  self.waitingForAnimation = false
end

return UMG_Camping_Restore_C
