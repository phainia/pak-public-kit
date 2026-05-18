local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_ChangeBackground_C = _G.NRCPanelBase:Extend("UMG_ChangeBackground_C")

function UMG_ChangeBackground_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self.originalCardSkinId = self.data:GetCurUsedCardSkinId()
  self.data:SetEditSelectedCardSkinId(self.originalCardSkinId)
  self.myCardSkinDic = {}
  self.ownedSkinIdToUpgradeCostIdDic = {}
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnBtnCloseClick)
  self:AddButtonListener(self.Confirm_1.btnLevelUp, self.OnClickConfirm)
  self:AddButtonListener(self.Rotation_1.btnLevelUp, self.OnResetBtnClicked)
  self:AddButtonListener(self.BtnUpgrade, self.OnBtnUpgrade)
  self:RegisterEvent(self, FriendModuleEvent.SetChooseCardBGPath, self.OnSetChooseCardBGPath)
  self:RegisterEvent(self, FriendModuleEvent.OnCardBackgroundItemSelect, self.OnCardBackgroundItemSelect)
  self:RegisterEvent(self, FriendModuleEvent.UpdateCardSkinInfo, self.UpdateCardSkinInfo)
  self:RegisterEvent(self, FriendModuleEvent.UpgradeCardSkinSucceed, self.UpgradeCardSkinSucceed)
end

function UMG_ChangeBackground_C:OnDestruct()
  self:UnRegisterEvent(self, FriendModuleEvent.SetChooseCardBGPath)
  self:UnRegisterEvent(self, FriendModuleEvent.OnCardBackgroundItemSelect)
  self:UnRegisterEvent(self, FriendModuleEvent.UpdateCardSkinInfo)
  self:UnRegisterEvent(self, FriendModuleEvent.UpgradeCardSkinSucceed)
end

function UMG_ChangeBackground_C:OnActive()
  self:UpdateList()
  self:UpdateOtherInfo()
  self.Item:SelectItemByIndex(0)
end

function UMG_ChangeBackground_C:UpdateList()
  self:InitMyCardSkinList(self.originalCardSkinId)
  local showCardList = {}
  for _, skin in ipairs(self.myCardSkinList) do
    table.insert(showCardList, skin)
  end
  for ownedSkinId, upgradeCostId in pairs(self.ownedSkinIdToUpgradeCostIdDic) do
    if ownedSkinId ~= upgradeCostId then
      for index, skin in ipairs(showCardList) do
        if skin.card_item_id == upgradeCostId then
          Log.DebugFormat("UMG_ChangeBackground_C:GetMyCardSkinList remove skin id : %s from myCardSkinList", tostring(upgradeCostId))
          table.remove(showCardList, index)
          break
        end
      end
    end
  end
  self.Item:InitList(showCardList)
end

function UMG_ChangeBackground_C:UpdateCardSkinInfo()
  self:UpdateList()
  self:UpdateOtherInfo()
end

function UMG_ChangeBackground_C:UpgradeCardSkinSucceed()
  self:PlayAnimation(self.upgrade)
end

function UMG_ChangeBackground_C:OnDeactive()
end

function UMG_ChangeBackground_C:UpdateOtherInfo()
  local selectedCardSkinId = self.data:GetEditSelectedCardSkinId()
  local CardSkinConf = _G.DataConfigManager:GetCardSkinConf(selectedCardSkinId)
  if CardSkinConf then
    self.BusinessCardPBg:SetPath(string.format(UEPath.CARD_COMMON_PATH, CardSkinConf.skin_resource_path, "Overhead", CardSkinConf.skin_resource_path, "Overhead"))
    self.BusinessCardBg:SetPath(string.format(UEPath.CARD_COMMON_PATH, CardSkinConf.skin_resource_path, "Fram", CardSkinConf.skin_resource_path, "Fram"))
  end
  local roleIcon
  if _G.DataModelMgr.PlayerDataModel:IsMale() then
    roleIcon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_MaleSilhouette_png.img_MaleSilhouette_png'"
  else
    roleIcon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_FemaleSilhouette_png.img_FemaleSilhouette_png'"
  end
  self.Role:SetPath(roleIcon)
  self:UpdateCardUpgradeInfo()
end

function UMG_ChangeBackground_C:UpdateCardUpgradeInfo()
  local canUpgrade = self:CanUpgradeForSelectedSkin()
  if canUpgrade then
    self.BtnUpgrade:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BtnUpgrade:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local selectedCardSkinId = self.data:GetEditSelectedCardSkinId()
  local selectedCardSkinConfig = _G.DataConfigManager:GetCardSkinConf(selectedCardSkinId)
  self.Grade:Init(selectedCardSkinId)
  self.Grade_1:Init(selectedCardSkinId)
  if selectedCardSkinConfig and selectedCardSkinConfig.level_icon and selectedCardSkinConfig.level_icon ~= "" then
    self:PlayAnimation(self.shine_loop)
  else
    self:PlayAnimation(self.shine_no)
  end
  self.RedDot:SetupKey(440, selectedCardSkinId)
end

function UMG_ChangeBackground_C:CanUpgradeForSelectedSkin()
  local selectedCardSkinId = self.data:GetEditSelectedCardSkinId()
  local selectedSkinData = self.myCardSkinDic[selectedCardSkinId]
  if selectedSkinData and selectedSkinData.ConfigurationInfo then
    local upgradeCostId = selectedSkinData.ConfigurationInfo.level_up_cost
    if upgradeCostId and upgradeCostId > 0 then
      local upgradeCostSkinData = self.myCardSkinDic[upgradeCostId]
      if upgradeCostSkinData then
        if selectedCardSkinId == upgradeCostId then
          return upgradeCostSkinData.ownedNum > 1
        else
          return upgradeCostSkinData.ownedNum > 0
        end
      end
    end
  end
  return false
end

function UMG_ChangeBackground_C:InitMyCardSkinList(curCardSkinId)
  local allSkin = self.data:GetSkinList()
  local myCardSkinList = {}
  self.ownedSkinIdToUpgradeCostIdDic = {}
  if allSkin then
    for _, skin in ipairs(allSkin) do
      if 0 ~= skin.card_item_get_timestamp then
        table.insert(myCardSkinList, skin)
        if skin.ConfigurationInfo and skin.ConfigurationInfo.level_up_cost and skin.ConfigurationInfo.level_up_cost > 0 then
          self.ownedSkinIdToUpgradeCostIdDic[skin.card_item_id] = skin.ConfigurationInfo.level_up_cost
        end
      end
    end
  end
  if #myCardSkinList > 0 then
    table.sort(myCardSkinList, function(a, b)
      if a.card_item_id == curCardSkinId then
        return true
      elseif b.card_item_id == curCardSkinId then
        return false
      else
        return a.card_item_get_timestamp > b.card_item_get_timestamp
      end
    end)
  end
  self.myCardSkinList = myCardSkinList
  self.myCardSkinDic = {}
  for _, skin in ipairs(myCardSkinList) do
    self.myCardSkinDic[skin.card_item_id] = skin
  end
end

function UMG_ChangeBackground_C:OnBtnUpgrade()
  local selectedCardSkinId = self.data:GetEditSelectedCardSkinId()
  local canUpgrade = self:CanUpgradeForSelectedSkin()
  if not canUpgrade then
    Log.ErrorFormat("UMG_ChangeBackground_C:OnBtnUpgrade can not upgrade for selected skin id: %s", tostring(selectedCardSkinId))
    return
  end
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.OnCmdRequestUpgradeCardSkin, selectedCardSkinId)
end

function UMG_ChangeBackground_C:OnBtnCloseClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_ChangeBackground_C:OnClickConfirm")
  self:OnClose()
end

function UMG_ChangeBackground_C:OnClickConfirm()
  local selectedCardSkinId = self.data:GetEditSelectedCardSkinId()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetStudentCardBGPath, selectedCardSkinId)
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_ChangeBackground_C:OnClickConfirm")
end

function UMG_ChangeBackground_C:OnResetBtnClicked()
  Log.Debug("UMG_ChangeBackground_C:OnResetBtnClicked()")
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(LuaText.rolecard_skin_revert_tips):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel):SetCloseOnCancel(true):SetCallback(self, self.OnResetDialogCallBack):SetClickAnywhereClose(false)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_ChangeBackground_C:OnResetDialogCallBack(isOk)
  Log.Debug("UMG_ChangeBackground_C:OnResetDialogCallBack() isOk = " .. tostring(isOk))
  if isOk then
    local defaultCardSkinId = self.data:GetDefaultSkinId()
    if defaultCardSkinId and defaultCardSkinId > 0 then
      self.data:SetEditSelectedCardSkinId(defaultCardSkinId)
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetStudentCardBGPath, defaultCardSkinId)
    end
  end
end

function UMG_ChangeBackground_C:OnSetChooseCardBGPath(...)
  self:UpdateOtherInfo()
end

function UMG_ChangeBackground_C:OnCardBackgroundItemSelect()
  self:UpdateOtherInfo()
end

return UMG_ChangeBackground_C
