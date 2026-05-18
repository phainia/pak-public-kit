local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_Friend_Function_C = _G.NRCPanelBase:Extend("UMG_Friend_Function_C")

function UMG_Friend_Function_C:OnConstruct()
  self.FriendListOrAddFriendOffsets = UE4.FMargin()
  self.FriendListOrAddFriendOffsets.Left = 163
  self.FriendListOrAddFriendOffsets.Top = 125
  local ViewportScale = UE4.UWidgetLayoutLibrary.GetViewportSize(_G.UE4Helper.GetCurrentWorld())
  local ApplyAndBlackListSize = {X = 1105, Y = 388}
  local ApplyAndBlackListPositionY = 47
  self.SizeX = (ViewportScale.X - ApplyAndBlackListSize.X) / 2
  self.SizeY = (ViewportScale.y - ApplyAndBlackListSize.Y) / 2 + ApplyAndBlackListPositionY
  Log.Debug(ViewportScale, self.SizeX, self.SizeY, "UMG_Friend_Function_C:OnConstruct")
  self:OnAddEventListener()
end

function UMG_Friend_Function_C:OnDestruct()
end

function UMG_Friend_Function_C:OnActive(_data, _screenPos, _OffSet, SelectTab)
  self.data = _data
  self.SelectTab = SelectTab
  self:SetPositionInfo(_screenPos, _OffSet, SelectTab)
  self:SetPanelInfo()
end

function UMG_Friend_Function_C:SetPositionInfo(_screenPos, _OffSet, _SelectTab)
  local screenPos = _screenPos
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), screenPos, screenPos)
  if _SelectTab == FriendEnum.SELECT_TAB.FriendList or _SelectTab == FriendEnum.SELECT_TAB.AddFriend then
    screenPos.Y = screenPos.Y + _OffSet + self.FriendListOrAddFriendOffsets.Top
    screenPos.X = screenPos.X + self.FriendListOrAddFriendOffsets.Left
  elseif _SelectTab == FriendEnum.SELECT_TAB.FriendApply then
    screenPos.Y = screenPos.Y + _OffSet + self.SizeY
    screenPos.X = screenPos.X + self.SizeX
  end
  self.CanvasPanel_31.Slot:SetPosition(screenPos)
end

function UMG_Friend_Function_C:SetPanelInfo()
  if self.SelectTab == FriendEnum.SELECT_TAB.FriendList then
    self.SizeBox_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SizeBox_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Remark:SetText(LuaText.umg_friend_function_1)
    self.Text_Examine_1:SetText(LuaText.umg_friend_function_2)
    self.Text_Remark_1:SetText(LuaText.umg_friend_function_3)
  end
end

function UMG_Friend_Function_C:OnDeactive()
end

function UMG_Friend_Function_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtn)
  self:AddButtonListener(self.Btn_Examine.btnLevelUp, self.OnCheckMaterial)
  self:AddButtonListener(self.Btn_Remark.btnLevelUp, self.OnAddOrModifyInfo)
  self:AddButtonListener(self.Btn_Examine_1.btnLevelUp, self.OnDeleteOrAddBlackList)
  self:AddButtonListener(self.Btn_Remark_1.btnLevelUp, self.OnAddBlackListOrReport)
  self:AddButtonListener(self.Btn_Examine_2.btnLevelUp, self.OnFriendReport)
end

function UMG_Friend_Function_C:OnCheckMaterial()
  Log.Error("\230\159\165\231\156\139\232\181\132\230\150\153\233\162\132\231\149\153\230\142\165\229\143\163")
end

function UMG_Friend_Function_C:OnAddOrModifyInfo()
  if self.SelectTab == FriendEnum.SELECT_TAB.FriendList then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendRemark, self.data)
  else
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, self.data.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.ADD_FRIEND)
  end
end

function UMG_Friend_Function_C:OnDeleteOrAddBlackList()
  if self.SelectTab == FriendEnum.SELECT_TAB.FriendList then
    self:OnDeleteFriendOrAddBlack("delete_friend_affirm_content", self.DeleteCallback)
  else
    self:OnDeleteFriendOrAddBlack("blacklist_affirm_content", self.OnOnAddBlackListCallback)
  end
end

function UMG_Friend_Function_C:OnAddBlackListOrReport()
  if self.SelectTab == FriendEnum.SELECT_TAB.FriendList then
    self:OnDeleteFriendOrAddBlack("blacklist_affirm_content", self.OnOnAddBlackListCallback)
  else
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendReport, self.data)
  end
end

function UMG_Friend_Function_C:OnFriendReport()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendReport, self.data)
end

function UMG_Friend_Function_C:OnDeleteFriendOrAddBlack(_Id, Callback)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local dialogContext = DialogContext()
  local Text = _G.DataConfigManager:GetLocalizationConf(_Id).msg
  local TipsContent = string.format(Text, self.data.name)
  dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, Callback)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_Friend_Function_C:DeleteCallback(_ok)
  if _ok then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, self.data.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.REMOVE_FRIEND)
  end
end

function UMG_Friend_Function_C:OnOnAddBlackListCallback(_ok)
  if _ok then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddOrRemoveBlackList, self.data.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveBlackListReq.TYPE.ADD, self.data)
  end
end

function UMG_Friend_Function_C:OnCloseBtn()
  self:DoClose()
end

return UMG_Friend_Function_C
