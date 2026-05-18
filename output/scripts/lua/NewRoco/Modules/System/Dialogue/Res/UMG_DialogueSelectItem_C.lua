require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_ScrollViewItemBase_C")
local DialogueModuleEvent = reload("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local ShowID = RocoEnv.IS_EDITOR or not RocoEnv.IS_SHIPPING and _G.AppMain:HasLaunchParams()
local UMG_DialogueSelectItem_C = Base:Extend("UMG_DialogueSelectItem_C")
local TextStyle = {
  [0] = "Normal",
  [1] = "Normal",
  [2] = "Important"
}
local TextStyleSelected = {
  [0] = "NormalSelected",
  [1] = "NormalSelected",
  [2] = "ImportantSelected"
}

function UMG_DialogueSelectItem_C:SafeSetVisibility(item, visibility)
  if item and item.SetVisibility then
    item:SetVisibility(visibility)
  else
    Log.Warning("UMG_DialogueSelectItem_C:SafeSetVisibility: \229\175\185\232\175\157\233\128\137\233\161\185umg\230\140\135\233\146\136\231\169\186\228\186\134")
  end
end

function UMG_DialogueSelectItem_C:SetBackGround(bIsPress)
  if not self:IsValid() then
    return
  end
  local SetContent = self.Content
  if nil ~= SetContent then
    if bIsPress then
      self:SafeSetVisibility(self.Background_Selected, UE4.ESlateVisibility.Visible)
      self:SafeSetVisibility(self.Background, UE4.ESlateVisibility.Hidden)
      SetContent = string.format("<%s>%s</>", TextStyleSelected[self.textLevel], self.Content)
      self.ItemDesc:SetText(SetContent)
    else
      self:SafeSetVisibility(self.Background_Selected, UE4.ESlateVisibility.Hidden)
      self:SafeSetVisibility(self.Background, UE4.ESlateVisibility.Visible)
      SetContent = string.format("<%s>%s</>", TextStyle[self.textLevel], self.Content)
      self.ItemDesc:SetText(SetContent)
    end
  end
end

function UMG_DialogueSelectItem_C:OnSelectionChange(bSelected)
  Log.Debug("UMG_DialogueSelectItem_C:OnSelectionChange", self._index, bSelected)
  if self.needFirst then
    self.needFirst = false
    return
  end
  self:SetBackGround(bSelected)
  self.bSelectedAndTouch = bSelected
end

function UMG_DialogueSelectItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.bSelectedAndTouch then
    self:SetBackGround(true)
  end
end

function UMG_DialogueSelectItem_C:OnMouseLeave(MouseEvent)
  Log.Debug("UMG_DialogueSelectItem_C:OnMouseLeave")
  if self.bSelectedAndTouch then
    self:SetBackGround(false)
  end
end

function UMG_DialogueSelectItem_C:OnOverallTouchEnd()
  Log.Debug("UMG_DialogueSelectItem_C:OnOverallTouchEnd")
  self.bSelectedAndTouch = false
  self:SetBackGround(false)
end

function UMG_DialogueSelectItem_C:OnTouchStarted(MyGeometry, InTouchEvent)
  local Ret = Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  Log.Debug("UMG_DialogueSelectItem_C:OnTouchStarted")
  if self.scrollView then
    self.scrollView:SetItemSelected(self._index)
  end
  return Ret
end

function UMG_DialogueSelectItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Log.Debug("UMG_DialogueSelectItem_C:OnTouchEnded")
  self.bSelectedAndTouch = false
  self:SetBackGround(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1067, "UMG_DialogueSelectItem_C:OnMouseEnter")
  local Ret = Base.OnTouchEnded(self)
  local Disabled = not self.SelectConf
  local Option = self.scrollView and self.scrollView.Option
  if Option and not Disabled then
    Disabled = Option:IsDisableByOnlineMode()
  end
  Disabled = Disabled or _G.DataModelMgr.PlayerDataModel:IsOnlineProcessDisable(self.SelectConf.online_process)
  if Disabled then
    local showTip = ""
    if _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
      showTip = _G.DataConfigManager:GetLocalizationConf("Error_Code_2161").msg
    else
      showTip = _G.DataConfigManager:GetLocalizationConf("Error_Code_2162").msg
    end
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, showTip)
  else
    if Option and Option:CheckOptionIsBan(true) then
      return
    end
    local dialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
    dialogueModule:DispatchEvent(DialogueModuleEvent.DialogueSelectFinished, self.SelectConf)
  end
  return Ret
end

function UMG_DialogueSelectItem_C:DispatchSelectEvent()
end

function UMG_DialogueSelectItem_C:SetData(selectConf)
  Log.Debug("UMG_DialogueSelectItem_C:SetData")
  Base.SetData(self, selectConf)
  self.SelectConf = selectConf
  local content = selectConf.text
  local iconPath = selectConf.select_icon
  local textLevel = selectConf.color
  if selectConf.select_mark == Enum.SelectMarkYellow.SMY_ROLE_LEVEL_AWARD then
    if _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.CheckIfLevelUpAwardsAvailable) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_MAGIC_UP then
    if _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsBottleTimeUpgradeEnable) or _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsRolePowerUpgradeEnable) or _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsRoleHpUpgradeEnable) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_MAGIC_BOTTLE_TIMES then
    if _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsBottleTimeUpgradeEnable) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_MAGIC_BOTTLE_VOLUME then
    if _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsBottleVolumeUpgradeEnable) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_MAGIC_HEART then
    if _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsRoleHpUpgradeEnable) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_JUST_YELLOW then
    textLevel = 2
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_TRAVEL_YELLOW then
    if _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.IsFinishTravel) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_MAGIC_POWER then
    if _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.IsRolePowerUpgradeEnable) then
      textLevel = 2
    end
  elseif selectConf.select_mark == Enum.SelectMarkYellow.SMY_CAMP_LEVELUP then
  end
  if ShowID then
    content = string.format("%s(%d)", content, self.SelectConf.id)
  end
  self.Content = content
  self.textLevel = textLevel
  content = string.format("<%s>%s</>", TextStyle[self.textLevel], self.Content)
  self.ItemDesc:SetText(content)
  self.Icon:SetPath(iconPath)
  self.needFirst = true
end

function UMG_DialogueSelectItem_C:SetScrollView(scrollView)
  Base.SetScrollView(self, scrollView)
  self.scrollView = scrollView
end

function UMG_DialogueSelectItem_C:Destruct()
  Base.Destruct(self)
  self.scrollView = nil
end

return UMG_DialogueSelectItem_C
