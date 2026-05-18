local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_Card_Function_C = _G.NRCViewBase:Extend("UMG_Card_Function_C")

function UMG_Card_Function_C:Construct()
  NRCViewBase.Construct(self)
  self.TabList = {
    {
      name = LuaText.players_interact_chat,
      TabType = FriendEnum.TAB_TYPE.Chitchat,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconliaotian_png.img_iconliaotian_png'",
      IsActive = true
    },
    {
      name = LuaText.players_interact_world_report,
      TabType = FriendEnum.TAB_TYPE.WorldInfo,
      IsActive = true,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconxinxi_png.img_iconxinxi_png'"
    },
    {
      name = LuaText.players_interact_apply_online_btn,
      TabType = FriendEnum.TAB_TYPE.RequestAccess,
      IsActive = true,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconshengqing_png.img_iconshengqing_png'"
    },
    {
      name = LuaText.players_interact_invite_online_btn,
      TabType = FriendEnum.TAB_TYPE.Invitation,
      IsActive = true,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconyaoqing_png.img_iconyaoqing_png'"
    },
    {
      name = LuaText.players_interact_spar_btn,
      TabType = FriendEnum.TAB_TYPE.Fight,
      IsActive = true,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconqiecuo_png.img_iconqiecuo_png'"
    },
    {
      name = LuaText.friend_recommend_tips3,
      TabType = FriendEnum.TAB_TYPE.InteractiveEggs,
      IsActive = true,
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_icondan_png.img_icondan_png'"
    }
  }
  self.CardBaseInfo = nil
  self.SelectTab = nil
  self.PlayerCardBriefInfo = nil
end

function UMG_Card_Function_C:OnActive()
end

function UMG_Card_Function_C:OnDeactive()
end

function UMG_Card_Function_C:OnAddEventListener()
end

function UMG_Card_Function_C:SetIsShow(_IsShow)
  if _IsShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Card_Function_C:SetFunctionInfo(_CardBaseData, _SelectTab, _PlayerCardBriefInfo)
  self.CardBaseInfo = _CardBaseData
  self.SelectTab = _SelectTab
  self.PlayerCardBriefInfo = _PlayerCardBriefInfo
  self.Is_Friend = _PlayerCardBriefInfo.is_friend
  self:SetAddFriendTab()
  if self.SelectTab ~= FriendEnum.SELECT_TAB.FaceToFaceInteraction then
    self:UpdateTabListByFriendPanel()
  end
  self:AddBaseData(_CardBaseData)
  self.List:InitGridView(self.TabList)
end

function UMG_Card_Function_C:SetAddFriendTab()
  if self.Is_Friend then
    self.TabList[1].name = LuaText.players_interact_chat
    self.TabList[1].TabType = FriendEnum.TAB_TYPE.Chitchat
    self.TabList[1].Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_iconliaotian_png.img_iconliaotian_png'"
    self.TabList[1].IsActive = true
  else
    self.TabList[1].name = LuaText.umg_friend_function1_11
    self.TabList[1].TabType = FriendEnum.TAB_TYPE.AddFriend
    self.TabList[1].Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconaddfriend_png.img_iconaddfriend_png'"
    self.TabList[1].IsActive = true
    if self.SelectTab ~= FriendEnum.SELECT_TAB.FaceToFaceInteraction and self.SelectTab ~= FriendEnum.SELECT_TAB.VisitPanelList then
      self:RemoveTabByType({
        FriendEnum.TAB_TYPE.Invitation,
        FriendEnum.TAB_TYPE.Fight,
        FriendEnum.TAB_TYPE.InteractiveEggs
      })
    end
  end
end

function UMG_Card_Function_C:AddBaseData(_CardBaseData)
  for i, Tab in ipairs(self.TabList) do
    Tab.PlayerInfo = self.CardBaseInfo
  end
end

function UMG_Card_Function_C:UpdateTabListByFriendPanel()
  if not self.PlayerCardBriefInfo.online then
    for i, Tab in ipairs(self.TabList) do
      if Tab.TabType == FriendEnum.TAB_TYPE.Chitchat or Tab.TabType == FriendEnum.TAB_TYPE.AddFriend then
        Tab.IsActive = true
      else
        Tab.IsActive = false
      end
    end
  end
end

function UMG_Card_Function_C:RemoveTabByType(_TypeList)
  for i = #self.TabList, 1, -1 do
    for j, Type in ipairs(_TypeList) do
      if self.TabList[i].TabType == Type then
        table.remove(self.TabList, i)
        break
      end
    end
  end
end

return UMG_Card_Function_C
