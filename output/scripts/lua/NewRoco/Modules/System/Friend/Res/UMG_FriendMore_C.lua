local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_FriendMore_C = _G.NRCViewBase:Extend("UMG_FriendMore_C")

function UMG_FriendMore_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self.TabList = {
    {
      name = LuaText.chat_func_btn_text_card,
      TabType = FriendEnum.ChatFunctionTabList.CheckCard
    },
    {
      name = LuaText.visible_circle_teleport_btn_text,
      TabType = FriendEnum.ChatFunctionTabList.Teleport
    },
    {
      name = LuaText.players_interact_world_report,
      TabType = FriendEnum.ChatFunctionTabList.WorldInformation
    },
    {
      name = LuaText.chat_func_btn_text_home,
      TabType = FriendEnum.ChatFunctionTabList.HomeInformation
    },
    {
      name = LuaText.umg_friend_function1_2,
      TabType = FriendEnum.ChatFunctionTabList.ChangeNickname
    },
    {
      name = LuaText.umg_friend_function1_4,
      TabType = FriendEnum.ChatFunctionTabList.BlockFriend
    },
    {
      name = LuaText.umg_friend_function1_5,
      TabType = FriendEnum.ChatFunctionTabList.ReportFriend
    },
    {
      name = LuaText.chat_delete_message_role_list,
      TabType = FriendEnum.ChatFunctionTabList.RemoveSession
    }
  }
  self.MoreList:InitGridView(self.TabList)
end

function UMG_FriendMore_C:OnDestruct()
end

function UMG_FriendMore_C:OnActive()
end

function UMG_FriendMore_C:OnDeactive()
end

function UMG_FriendMore_C:OnAddEventListener()
end

return UMG_FriendMore_C
