local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AccountSettingList_C = Base:Extend("UMG_AccountSettingList_C")
local FriendModuleCmd = require("NewRoco.Modules.System.Friend.FriendModuleCmd")

function UMG_AccountSettingList_C:OnConstruct()
  self.InitialQuery = true
  self.bAddListener = false
end

function UMG_AccountSettingList_C:OnDestruct()
  if self.delayID then
    _G.DelayManager:CancelDelayById(self.delayID)
    self.delayID = nil
  end
end

function UMG_AccountSettingList_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if _data then
    if self.data.displayText == LuaText.privacy_setting_10 or self.data.displayText == LuaText.privacy_setting_11 then
      self.NRCSwitcher_77:SetActiveWidgetIndex(1)
    else
      self.NRCSwitcher_77:SetActiveWidgetIndex(0)
    end
    if 0 == self.NRCSwitcher_77:GetActiveWidgetIndex() then
      self.NRCText_39:SetText(self.data.displayText)
      self:AddButtonListener(self.OutOfStuckBtn.btnLevelUp, self.onClickOutOfStuckBtn)
    else
      self.NRCText_41:SetText(self.data.displayText)
      self.WatchBattleList:SetItemClickAble(true)
      if self.data.displayText == LuaText.privacy_setting_11 then
        local checkItem1 = self.WatchBattleList:GetItemByIndex(0)
        checkItem1.ParentView = self.WatchBattleList
        checkItem1.data = {}
        checkItem1.data.Name = "FriendSuggest"
        checkItem1.data.OnItemSelectedCallbackOwner = self
        checkItem1.data.OnItemSelectedCallback = self.onClickSuggestOnBtn
        checkItem1.text:SetText(LuaText.privacy_setting_12)
        local checkItem2 = self.WatchBattleList:GetItemByIndex(1)
        checkItem2.ParentView = self.WatchBattleList
        checkItem2.data = {}
        checkItem2.data.Name = "FriendSuggest"
        checkItem2.data.OnItemSelectedCallbackOwner = self
        checkItem2.data.OnItemSelectedCallback = self.onClickSuggestOffBtn
        checkItem2.text:SetText(LuaText.privacy_setting_13)
        self.Details_7.Title:SetText(LuaText.privacy_setting_9)
        self.CloseAnnotationBtn = _data.CloseAnnotationBtn
        self.BtnDetails_18:SetVisibility(UE4.ESlateVisibility.Visible)
        if not self.bAddListener then
          self.bAddListener = true
          self:AddButtonListener(self.BtnDetails_18.btnLevelUp, self.ShowDetailsText)
          self:AddButtonListener(_data.CloseAnnotationBtn, self.CloseDetailsText)
        end
        if self.InitialQuery then
          self.InitialQuery = false
          _G.NRCModuleManager:DoCmd(FriendModuleCmd.QueryWhetherCanBeSearched, self, self.QueryCallback)
        end
      elseif self.data.displayText == LuaText.privacy_setting_10 then
        local checkItem1 = self.WatchBattleList:GetItemByIndex(0)
        checkItem1.ParentView = self.WatchBattleList
        checkItem1.data = {}
        checkItem1.data.Name = "FriendSearch"
        checkItem1.data.OnItemSelectedCallbackOwner = self
        checkItem1.data.OnItemSelectedCallback = self.onClickSearchOnBtn
        checkItem1.text:SetText(LuaText.privacy_setting_12)
        local checkItem2 = self.WatchBattleList:GetItemByIndex(1)
        checkItem2.ParentView = self.WatchBattleList
        checkItem2.data = {}
        checkItem2.data.Name = "FriendSearch"
        checkItem2.data.OnItemSelectedCallbackOwner = self
        checkItem2.data.OnItemSelectedCallback = self.onClickSearchOffBtn
        checkItem2.text:SetText(LuaText.privacy_setting_13)
        self.Details_7.Title:SetText(LuaText.privacy_setting_8)
        self.CloseAnnotationBtn = _data.CloseAnnotationBtn
        self.BtnDetails_18:SetVisibility(UE4.ESlateVisibility.Visible)
        if not self.bAddListener then
          self.bAddListener = true
          self:AddButtonListener(self.BtnDetails_18.btnLevelUp, self.ShowDetailsText)
          self:AddButtonListener(_data.CloseAnnotationBtn, self.CloseDetailsText)
        end
        if self.InitialQuery then
          self.InitialQuery = false
          _G.NRCModuleManager:DoCmd(FriendModuleCmd.QueryWhetherCanBeSearched, self, self.QueryCallback)
        end
      end
    end
  end
end

function UMG_AccountSettingList_C:ShowDetailsText()
  self.BtnDetails_18:PlayAnimationReverse(self.BtnDetails_18.Up)
  self.CloseAnnotationBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Details_7:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.bShowDetails = true
end

function UMG_AccountSettingList_C:CloseDetailsText()
  if self.bShowDetails then
    self.BtnDetails_18:PlayAnimation(self.BtnDetails_18.Up)
    self.CloseAnnotationBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Details_7:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bShowDetails = false
end

function UMG_AccountSettingList_C:QueryCallback(_friendship)
  if self.WatchBattleList and UE4.UObject.IsValid(self.WatchBattleList) then
    local item = self.WatchBattleList:GetItemByIndex(0)
    if item and item.data then
      if item.data.Name == "FriendSuggest" then
        if _friendship and _friendship.can_be_sugguested then
          self.WatchBattleList:SelectItemByIndex(0)
        else
          if _friendship and not _friendship.can_be_sugguested then
            self.WatchBattleList:SelectItemByIndex(1)
          else
          end
        end
      end
      if item.data.Name == "FriendSearch" then
        if _friendship and _friendship.can_be_searched then
          self.WatchBattleList:SelectItemByIndex(0)
        elseif _friendship and not _friendship.can_be_searched then
          self.WatchBattleList:SelectItemByIndex(1)
        end
      end
    end
  end
end

function UMG_AccountSettingList_C:SetCallback()
end

function UMG_AccountSettingList_C:onClickSuggestOnBtn()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetWhetherCanBeSuggested, true, self, self.SetCallback)
end

function UMG_AccountSettingList_C:onClickOutOfStuckBtn()
  _G.NRCAudioManager:PlaySound2DAuto(1064, "UMG_SystemSettingMain_C:OpenServiceProtocol")
  self.delayID = _G.DelayManager:DelaySeconds(0.1, function()
    self.data.func()
  end)
end

function UMG_AccountSettingList_C:onClickSuggestOffBtn()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetWhetherCanBeSuggested, false, self, self.SetCallback)
end

function UMG_AccountSettingList_C:onClickSearchOnBtn()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetWhetherCanBeSearched, true, self, self.SetCallback)
end

function UMG_AccountSettingList_C:onClickSearchOffBtn()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetWhetherCanBeSearched, false, self, self.SetCallback)
end

function UMG_AccountSettingList_C:OnDeactive()
  self.InitialQuery = true
end

return UMG_AccountSettingList_C
