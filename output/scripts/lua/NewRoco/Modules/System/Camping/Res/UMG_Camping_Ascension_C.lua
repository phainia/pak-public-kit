local UMG_Camping_Ascension_C = _G.NRCPanelBase:Extend("UMG_Camping_Ascension_C")
local CampingModuleEvent = reload("NewRoco.Modules.System.Camping.CampingModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")

function UMG_Camping_Ascension_C:OnConstruct()
  self.UiData = {}
  self.PanelType = nil
  self.UpgradeType = nil
  self.ClickEnable = true
  local insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu")
  self.insufficientText = insufficientText and insufficientText.msg or "\230\157\144\230\150\153\228\184\141\232\182\179\230\178\161\233\133\141\230\150\135\230\156\172"
  local ItemRequiredText = _G.DataConfigManager:GetLocalizationConf("Camp_cailiao")
  self.ItemRequired:SetText(ItemRequiredText and ItemRequiredText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  local MaxLevelHint = _G.DataConfigManager:GetLocalizationConf("Camp_UP_tishengshangxian")
  self.MaxLevelHint_2:SetText(MaxLevelHint and MaxLevelHint.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  local LevelUpButtonText = _G.DataConfigManager:GetLocalizationConf("Camp_BTN_tisheng")
  self.icon = "PaperSprite'/Game/NewRoco/Modules/System/Camping/Raw/Frames/img_tisheng_png.img_tisheng_png'"
  self.GetRewardsBtn:SetBtnText(LevelUpButtonText and LevelUpButtonText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176")
  self.GetRewardsBtn:SetPath(self.icon)
  self.waitingForIncrease = false
  self.waitingForIncreaseValue = 0
  self.waitingForIncreaseType = nil
end

function UMG_Camping_Ascension_C:OnDestruct()
  self:RemoveHpListener()
end

function UMG_Camping_Ascension_C:OnActive(_param)
  self:AddHpListener()
  self.RestoreList = {}
  self.current_hp_value_for_anim = 0
  self:RefreshPanel(_param)
  self:PlayAnimation(self.open)
end

function UMG_Camping_Ascension_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    if self.Action then
      self.Action:EndAction()
    end
    self:DoClose()
  end
end

function UMG_Camping_Ascension_C:OnDeactive()
end

function UMG_Camping_Ascension_C:AddHpListener()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:AddEventListener(self, PlayerModuleEvent.ON_ROLE_HP_CHANGE_RAW, self.RoleHpChange)
  localPlayer:AddEventListener(self, PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE_RAW, self.RoleHpMaxChange)
  _G.NRCEventCenter:RegisterEvent("UMG_Camping_Ascension_C", self, BagModuleEvent.BagItemAdd, self.BagItemUpdate)
  _G.NRCEventCenter:RegisterEvent("UMG_Camping_Ascension_C", self, BagModuleEvent.BagItemUpdate, self.BagItemUpdate)
end

function UMG_Camping_Ascension_C:BagItemUpdate(ItemId)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.RefreshPanelData)
end

function UMG_Camping_Ascension_C:RemoveHpListener()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_ROLE_HP_CHANGE_RAW, self.RoleHpChange)
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE_RAW, self.RoleHpMaxChange)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.BagItemUpdate)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.BagItemUpdate)
end

function UMG_Camping_Ascension_C:OnAddEventListener()
  self:RemoveAllButtonListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtnClick)
  self:AddButtonListener(self.GetRewardsBtn.btnLevelUp, self.OnBtnGetRewardClick)
  self:RegisterEvent(self, CampingModuleEvent.CAMPING_ASCENSION_REFRESH_PANEL, self.RefreshPanel)
end

function UMG_Camping_Ascension_C:OnCloseBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_Camping_Ascension_C:OnCloseBtnClick")
  self:PlayAnimation(self.close)
end

function UMG_Camping_Ascension_C:OnBtnGetRewardClick()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Camping_Ascension_C:OnBtnGetRewardClick")
  if self.waitingForIncrease then
    Log.Debug("\231\173\137\229\190\133\230\149\176\230\141\174\230\143\144\229\141\135\228\184\173")
    return
  end
  self.waitingForIncreaseType = self.UpgradeType
  self.waitingForIncreaseValue = self.UiData.origin_value
  self.waitingForIncrease = true
  if self.ClickEnable then
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.SendUpgradeReq, self.UpgradeType, self.UiData.upgradeId)
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.JustPlayCampingSkill, "/Game/ArtRes/Effects/G6Skill/Luying/MagicUpHeart.MagicUpHeart")
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.insufficientText or "\228\184\141\231\159\165\233\129\147\228\184\186\228\187\128\228\185\136\230\152\175\231\169\186\231\154\132")
  end
end

function UMG_Camping_Ascension_C:RefreshPanel(_param)
  self.UiData = _param.data
  self.Action = _param.data.action
  self:OnAddEventListener()
  self.ClickEnable = true
  for _, value in pairs(self.UiData.item_list) do
    if value.itemNum < value.itemNeedNum then
      self.ClickEnable = false
    end
  end
  if _param.open_type == _G.CampingModuleEnum.PanelType.RoleHpMax then
    self:OpenRoleHpPanel()
    self.UpgradeType = _G.Enum.VisualItem.VI_ROLE_HP_MAX
  end
  if self.UiData.max_value == self.UiData.origin_value then
    self.TextSwitcher:SetActiveWidgetByWidgetName("Ceiling")
  else
    self.TextSwitcher:SetActiveWidgetByWidgetName("UnderLevel")
    self.List:InitGridView(self.UiData.item_list)
  end
  local upgradeEnable = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel() >= self.UiData.requiredLevel
  if upgradeEnable then
    self.ButtonSwitcher:SetActiveWidgetByWidgetName("Panel_Rewards")
  else
    self.ButtonSwitcher:SetActiveWidgetByWidgetName("TheLevel")
    self.LevelRequiredText:SetText(self.UiData.requiredLevel)
  end
  if self.waitingForIncrease then
    if self.waitingForIncreaseType == self.UpgradeType and self.waitingForIncreaseValue < self.UiData.origin_value then
      self.waitingForIncrease = false
    else
      self.waitingForIncrease = false
    end
  end
end

function UMG_Camping_Ascension_C:OpenRoleHpPanel()
  if not self.RestoreList then
    return
  end
  if 0 == #self.RestoreList then
    for i = 1, self.UiData.current_value do
      table.insert(self.RestoreList, {
        heartType = _G.CampingModuleEnum.RoleHpType.GreenHeart
      })
    end
    for i = math.max(self.UiData.current_value + 1, 1), self.UiData.origin_value do
      table.insert(self.RestoreList, {
        heartType = _G.CampingModuleEnum.RoleHpType.GreyHeart
      })
    end
  else
    local healthHeart = false
    for i = 1, self.UiData.current_value do
      if self.RestoreList[i] then
        if self.RestoreList[i].heartType == _G.CampingModuleEnum.RoleHpType.GreyHeart then
          healthHeart = true
          self.RestoreList[i] = {
            heartType = _G.CampingModuleEnum.RoleHpType.HealthHeart
          }
        else
          self.RestoreList[i] = {
            heartType = _G.CampingModuleEnum.RoleHpType.NoChange
          }
        end
      elseif true == healthHeart then
        table.insert(self.RestoreList, {
          delayTime = 0.3,
          heartType = _G.CampingModuleEnum.RoleHpType.GetNewHeart
        })
      else
        table.insert(self.RestoreList, {
          delayTime = 0.0,
          heartType = _G.CampingModuleEnum.RoleHpType.GetNewHeart
        })
      end
    end
    for i = math.max(self.UiData.current_value + 1, 1), self.UiData.origin_value do
      if self.RestoreList[i] then
        self.RestoreList[i] = {
          heartType = _G.CampingModuleEnum.RoleHpType.GreyHeart
        }
      end
    end
  end
  self.HeartList:InitGridView(self.RestoreList)
  self.Title:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_TITLE_ganjin").msg)
  self.CurrentHp:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_UP_ganjin").msg)
end

function UMG_Camping_Ascension_C:RoleHpChange(newHp)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.RefreshPanelData)
end

function UMG_Camping_Ascension_C:RoleHpMaxChange(newHpMax)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.RefreshPanelData)
end

function UMG_Camping_Ascension_C:LockPlayer(switchState)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.inputComponent:SetInputEnable(self, switchState)
end

return UMG_Camping_Ascension_C
