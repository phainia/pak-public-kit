local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_Friend_Function1_C = _G.NRCPanelBase:Extend("UMG_Friend_Function1_C")

function UMG_Friend_Function1_C:OnConstruct()
  self.TabList = {
    {
      name = LuaText.umg_friend_function1_1,
      TabType = FriendEnum.TAB_TYPE.Material,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_zhanghuputong_png.img_zhanghuputong_png'"
    },
    {
      name = LuaText.umg_friend_function1_2,
      TabType = FriendEnum.TAB_TYPE.Remark,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_beizhuputong_png.img_beizhuputong_png'"
    },
    {
      name = LuaText.umg_friend_function1_3,
      TabType = FriendEnum.TAB_TYPE.RemoveFriend,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_tianjia_png.img_tianjia_png'"
    },
    {
      name = LuaText.umg_friend_function1_4,
      TabType = FriendEnum.TAB_TYPE.AddBlackList,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_heimingdanputong_png.img_heimingdanputong_png'"
    },
    {
      name = LuaText.umg_friend_function1_5,
      TabType = FriendEnum.TAB_TYPE.Report,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_jubaoputong_png.img_jubaoputong_png'"
    }
  }
  self.TabList_2 = {
    {
      name = LuaText.umg_friend_function1_6,
      TabType = FriendEnum.TAB_TYPE.ChangeHeadIcon,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_gaitouxiang_png.img_gaitouxiang_png'"
    },
    {
      name = LuaText.umg_friend_function1_7,
      TabType = FriendEnum.TAB_TYPE.ChangeCardBG,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_zhanghuputong_png.img_zhanghuputong_png'"
    },
    {
      name = LuaText.umg_friend_function1_8,
      TabType = FriendEnum.TAB_TYPE.ChangeLabel,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_genghuanbiaoqian_png.img_genghuanbiaoqian_png'"
    },
    {
      name = LuaText.umg_friend_function1_9,
      TabType = FriendEnum.TAB_TYPE.Remark,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_beizhuputong_png.img_beizhuputong_png'"
    },
    {
      name = LuaText.umg_friend_function1_10,
      TabType = FriendEnum.TAB_TYPE.ChangeSign,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_gaiqianming_png.img_gaiqianming_png'"
    }
  }
  self.data = nil
  self.SelectTab = nil
  self.CardEnterType = nil
  self.ItemCount = nil
  self:SetRenderOpacity(0)
  self:SetIsEnabled(false)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnAddEventListener()
end

function UMG_Friend_Function1_C:IsShowCloseBtn(_IsShow)
  if _IsShow then
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Friend_Function1_C:OnDestruct()
end

function UMG_Friend_Function1_C:OnActive(_data, _screenPos, SelectTab, bSetPosition)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.data = _data
  self.SelectTab = SelectTab
  self:SetTabListPlayerInfo(self.TabList)
  self:SetTabListPlayerInfo(self.TabList_2)
  self:SetListData()
  if self.SelectTab == FriendEnum.SELECT_TAB.VisitPanelList then
    self:SetIsEnabled(true)
    self:SetRenderOpacity(1)
    self:PlayAnimation(self.In)
  elseif not bSetPosition then
    self:SetPositionInfo(_screenPos)
  else
    self:PlayAnimation(self.In)
  end
end

function UMG_Friend_Function1_C:CardEnter(_data, SelectTab, CardEnterType, Parent)
  self.data = _data
  self.SelectTab = SelectTab
  self.CardEnterType = CardEnterType
  self.Parent = Parent
  self:SetTabListPlayerInfo(self.TabList)
  self:SetTabListPlayerInfo(self.TabList_2)
  self:SetListData()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetRenderOpacity(1)
  self:SetIsEnabled(true)
  self:PlayAnimation(self.In)
end

function UMG_Friend_Function1_C:SetListData()
  local CardTabList = {}
  for i, List in ipairs(self.TabList) do
    table.insert(CardTabList, List)
  end
  local TabList = self:InitializeTabList(CardTabList)
  self:SetListInfo(TabList)
end

function UMG_Friend_Function1_C:SetListInfo(TabList)
  if self.CardEnterType == FriendEnum.AdminFriendType.Own then
    self.List:InitGridView(self.TabList_2)
    self.ItemCount = #self.TabList_2
  else
    self.List:InitGridView(TabList)
    self.ItemCount = #TabList
  end
  for i = 0, self.ItemCount - 1 do
    local Item = self.List:GetItemByIndex(i)
    Item:SetParent(self)
  end
end

function UMG_Friend_Function1_C:SetOnlyClick(index, IsCanClick)
  for i = 0, self.ItemCount - 1 do
    if index - 1 ~= i then
      local Item = self.List:GetItemByIndex(i)
      Item:SetIsCanClick(IsCanClick)
    end
  end
end

function UMG_Friend_Function1_C:SetPositionInfo(_screenPos)
  local ViewportScale = UE4.UWidgetLayoutLibrary.GetViewportSize(_G.UE4Helper.GetCurrentWorld())
  self:DelayFrames(2, function()
    local AbsoluteSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self.List:GetCachedGeometry())
    Log.Debug(AbsoluteSize, "UMG_Friend_Function1_C:SetPositionInfo")
    if _screenPos.Y + AbsoluteSize.Y > ViewportScale.Y then
      _screenPos.Y = ViewportScale.Y - AbsoluteSize.Y
    end
    UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), _screenPos, _screenPos)
    if self.SelectTab == FriendEnum.SELECT_TAB.FriendList or self.SelectTab == FriendEnum.SELECT_TAB.AddFriend then
      _screenPos.X = 251
    elseif self.SelectTab == FriendEnum.SELECT_TAB.StudentCardList then
      _screenPos.X = 1100
      _screenPos.Y = 200
    else
      _screenPos.X = 315
    end
    _screenPos.X = _screenPos.X * 1.5
    _screenPos.Y = _screenPos.Y * 1.5
    self.CanvasPanel_31.Slot:SetPosition(_screenPos)
    self:SetIsEnabled(true)
    self:SetRenderOpacity(1)
    self:PlayAnimation(self.In)
  end)
end

function UMG_Friend_Function1_C:InitializeTabList(TabListData)
  local SelectTab = self.SelectTab
  local TabList = TabListData
  if SelectTab == FriendEnum.SELECT_TAB.AddFriend then
    if self.data.is_friend then
      self:SetRemoveFriendTab(TabList)
    else
      self:SetAddFriendTab(self.TabList)
    end
  elseif SelectTab == FriendEnum.SELECT_TAB.FriendApply then
    self:SetAddBlackTab(TabList)
    self:SetAddFriendTab(TabList)
  elseif SelectTab == FriendEnum.SELECT_TAB.BlackList then
    self:SetRemoveBlackTab(TabList)
    self:SetAddFriendTab(TabList)
  elseif SelectTab == FriendEnum.SELECT_TAB.VisitPanelList then
    if self.data.is_friend then
      self:SetRemoveFriendTab(TabList)
    else
      self:SetAddFriendTab(self.TabList)
    end
    if self.data.is_black_role then
      self:SetRemoveBlackTab(TabList)
    else
      self:SetAddBlackTab(TabList)
    end
  end
  if self.CardEnterType and self.CardEnterType == FriendEnum.AdminFriendType.Others then
    table.remove(TabList, 1)
    table.remove(TabList, 1)
  elseif self.SelectTab ~= FriendEnum.SELECT_TAB.FriendList then
    table.remove(TabList, 2)
  end
  Log.Dump(TabList, 6, "UMG_Friend_Function1_C:InitializeTabList")
  return TabList
end

function UMG_Friend_Function1_C:SetAddFriendTab(TabList)
  TabList[3].name = LuaText.umg_friend_function1_11
  TabList[3].TabType = FriendEnum.TAB_TYPE.AddFriend
  TabList[3].Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_tianjia_png.img_tianjia_png'"
end

function UMG_Friend_Function1_C:SetRemoveFriendTab(TabList)
  TabList[3].name = LuaText.umg_friend_function1_3
  TabList[3].TabType = FriendEnum.TAB_TYPE.RemoveFriend
  TabList[3].Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_tianjia_png.img_tianjia_png'"
end

function UMG_Friend_Function1_C:SetAddBlackTab(TabList)
  TabList[4].name = LuaText.umg_friend_function1_4
  TabList[4].TabType = FriendEnum.TAB_TYPE.AddBlackList
  TabList[4].Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_heimingdanputong_png.img_heimingdanputong_png'"
end

function UMG_Friend_Function1_C:SetRemoveBlackTab(TabList)
  TabList[4].name = LuaText.umg_friend_function1_12
  TabList[4].TabType = FriendEnum.TAB_TYPE.RemoveBlackList
  TabList[4].Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_yichuheimingdan_png.img_yichuheimingdan_png'"
end

function UMG_Friend_Function1_C:SetTabListPlayerInfo(TabList)
  for i, List in ipairs(TabList) do
    List.PlayerInfo = self.data
    List.SelectTab = self.SelectTab
  end
end

function UMG_Friend_Function1_C:OnDeactive()
end

function UMG_Friend_Function1_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnClickCloseBtn)
end

function UMG_Friend_Function1_C:OnClickCloseBtn()
  self:PlayAnimation(self.Out)
end

function UMG_Friend_Function1_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    if self.SelectTab == FriendEnum.SELECT_TAB.VisitPanelList or self.SelectTab == FriendEnum.SELECT_TAB.StudentCardList or self.CardEnterType == FriendEnum.AdminFriendType.Others then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:DoClose()
    end
  elseif Animation == self.In and self.Parent then
    self.Parent:SetLock(false)
  end
end

return UMG_Friend_Function1_C
