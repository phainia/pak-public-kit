local LevelUpUtils = require("NewRoco.Modules.System.LevelUpUI.LevelUpUtils")
local LevelUpUIModuleEvent = reload("NewRoco.Modules.System.LevelUpUI.LevelUpUIModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_LevelInformation_C = _G.NRCViewBase:Extend("UMG_LevelInformation_C")

function UMG_LevelInformation_C:OnConstruct()
  self.GetRewardsBtn:SetBtnText(LuaText.umg_levelinformation_1)
  self.IsLock = false
  local RoleExpConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ROLE_EXP_CONF):GetAllDatas()
  self.MaxLevel = RoleExpConf[#RoleExpConf].id
end

function UMG_LevelInformation_C:OnActive()
end

function UMG_LevelInformation_C:OnDeactive()
end

function UMG_LevelInformation_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseButtonClick)
  self:AddButtonListener(self.GetRewardsBtn.btnLevelUp, self.OnCheckRewardsClick)
  self:AddButtonListener(self.Btn_Detail.btnLevelUp, self.StudentCardClick)
  self:AddButtonListener(self.HeadBtn, self.OpenCardHead)
end

function UMG_LevelInformation_C:OnCloseButtonClick()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseMenu")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_LevelInformation_C:OnCloseButtonClick")
  if self.owner then
    self.owner:FadeOut()
  end
end

function UMG_LevelInformation_C:SetPlayerHead()
  local AvatarPath = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetCurrentUsePlayerHead)
  self.HeadItem:HideLevel(true)
  self.HeadItem.HeadPortrait:SetPath(AvatarPath)
end

function UMG_LevelInformation_C:SetPlayerName()
end

function UMG_LevelInformation_C:InitWithData(data)
  self.uiData = data
  self:OnAddEventListener()
  local pet_top_level = 0
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if worldLevel then
    local worldLevelConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.WORLD_LEVEL_CONF):GetAllDatas()
    for index, item in ipairs(worldLevelConf) do
      if item.world_level == worldLevel then
        self.levelMagicTitle:SetText(item.title)
        pet_top_level = item.pet_top_level
      end
    end
  end
  local MagicianTitle = LevelUpUtils.GetMagicianTitle()
  self.Title:SetText(MagicianTitle)
  self.leveIcon1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.leveIcon2:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.leveIcon3:SetVisibility(UE4.ESlateVisibility.Hidden)
  if 0 == worldLevel then
    self.leveIcon1:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 10 == worldLevel then
    self.leveIcon3:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.leveIcon2:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local starData = LevelUpUtils.GetStarListData()
  for i, item in ipairs(starData) do
    local index = i - 1
    self["Star_" .. index]:OnItemUpdate(item)
    self["Star_" .. index]:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.UIDtext:SetText(_G.DataModelMgr.PlayerDataModel:GetPlayerUin())
  self.nameText:SetText("")
  self.levelText:SetText(_G.DataModelMgr.PlayerDataModel:GetPlayerLevel())
  local Exp = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_ROLEEXP) or 0
  local Level = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  if 0 == Level then
    Level = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  end
  self:SetExpBar(Exp, Level)
  local WorldHintText = {}
  local world_level = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  self.CurrentWorldLevelConf = LevelUpUtils.GetWorldLevelConfByWorldLevel(world_level)
  if self.CurrentWorldLevelConf then
    for i, item in ipairs(self.CurrentWorldLevelConf.promote_desc) do
      local reward = {}
      local iconPath = ""
      if item.icon then
        iconPath = item.icon
      end
      if item.value then
        reward = {
          Description = item.promote_text,
          value = item.value,
          icon = iconPath
        }
      else
        reward = {
          Description = item.promote_text,
          value = nil,
          icon = iconPath
        }
      end
      table.insert(WorldHintText, reward)
    end
    self.LevelTipsList:InitGridView(WorldHintText)
    local num = #WorldHintText
    for i = 1, num do
      local item = self.LevelTipsList:GetItemByIndex(i - 1)
      item:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  self:SetPlayerHead()
end

function UMG_LevelInformation_C:SetExpBar(exp, level)
  local Exp, Max, Percent = self:CalcExpInfo(exp, level)
  self.levelText:SetText(level)
  self.ExpBar:SetPercent(Percent)
  self.ProgressText:SetText(string.format("%d", Exp, Max))
  if Max <= 0 then
    local Font = self.ProgressText_1.Font
    Font.Size = 30
    self.ProgressText_1:SetFont(Font)
    self.ProgressText_1:SetText(LuaText.role_exp_lv_max)
    self.ProgressText:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ProgressText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFC65FFF"))
  else
    local Font = self.ProgressText_1.Font
    Font.Size = 22
    self.ProgressText_1:SetFont(Font)
    self.ProgressText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#929086FF"))
    self.ProgressText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.ProgressText_1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.ProgressText_1:SetText(string.format("/%d", Max))
  end
end

function UMG_LevelInformation_C:CalcExpInfo(exp, level)
  if level and self.MaxLevel and level >= self.MaxLevel then
    return exp, 0, 1
  end
  local RoleExpConf = _G.DataConfigManager:GetRoleExpConf(level)
  local MaxExp = RoleExpConf and RoleExpConf.need_exp or -1
  MaxExp = math.max(0, MaxExp)
  local Percent = exp / MaxExp
  return exp, MaxExp, Percent
end

function UMG_LevelInformation_C:OnCheckRewardsClick()
  if not self.owner then
    return
  end
  if self.owner.isPlayingAnimation then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1003, "OnCheckRewardsClick")
  self.owner:SwitchToRewards()
end

function UMG_LevelInformation_C:StudentCardClick()
  if self.IsLock then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_LevelMain_C:OnSystemIconClicked")
  self:DispatchEvent(LevelUpUIModuleEvent.LEVELUP_OPEN_CARD_SET_LOCK, true)
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenStudentCardPanel, nil, FriendEnum.AdminFriendType.Own, FriendEnum.Source.Friend, nil)
end

function UMG_LevelInformation_C:OpenCardHead()
  if self.IsLock then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_LevelMain_C:OnSystemIconClicked")
  self:DispatchEvent(LevelUpUIModuleEvent.LEVELUP_OPEN_CARD_SET_LOCK, true)
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChangeAvatarPanel)
end

function UMG_LevelInformation_C:SetLockInfo(IsLock)
  self.IsLock = IsLock
end

function UMG_LevelInformation_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    if self.owner then
      self.owner.isPlayingAnimation = false
    end
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif Animation == self.Out then
    local num = self.LevelTipsList:GetItemCount()
    for i = 1, num do
      local item = self.LevelTipsList:GetItemByIndex(i - 1)
      item:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.owner then
      self.owner:RewardsPlayIn()
    end
  end
end

return UMG_LevelInformation_C
