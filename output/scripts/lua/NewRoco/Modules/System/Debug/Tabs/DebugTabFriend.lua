local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabFriend = Base:Extend("DebugTabFriend")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")

function DebugTabFriend:SetupTabs()
end

function DebugTabFriend:BatchSendFriends(Name, Panel, InputNumber)
  local create_num
  if Panel then
    create_num = Panel:GetInputNumber()
  else
    create_num = tonumber(InputNumber)
  end
  if create_num <= 0 then
    create_num = 20
  end
  local req = _G.ProtoMessage:newZoneGmFriendOperReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.type = 1
  req.name_prefix = string.format("\233\135\143\228\186\167\229\176\143\230\180\155\229\133\139%d\229\143\183\230\156\186", math.random(0, 99999999))
  req.num = create_num
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FRIEND_OPER_REQ, req, self, self.batchSendFriendRsp)
end

function DebugTabFriend:BatchCreateFriends(Name, Panel, InputNumber)
  local create_num
  if Panel then
    create_num = Panel:GetInputNumber()
  else
    create_num = tonumber(InputNumber)
  end
  if create_num <= 0 then
    create_num = 20
  end
  local req = _G.ProtoMessage:newZoneGmFriendOperReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.type = 2
  req.name_prefix = string.format("\233\135\143\228\186\167\229\176\143\230\180\155\229\133\139%d\229\143\183\230\156\186", math.random(0, 99999999))
  req.num = create_num
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FRIEND_OPER_REQ, req, self, self.batchSendFriendRsp)
end

function DebugTabFriend:BatchCreateBlackList(Name, Panel, InputNumber)
  local create_num
  if Panel then
    create_num = Panel:GetInputNumber()
  else
    create_num = tonumber(InputNumber)
  end
  if create_num <= 0 then
    create_num = 20
  end
  local req = _G.ProtoMessage:newZoneGmFriendOperReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.type = 3
  req.name_prefix = string.format("\233\135\143\228\186\167\229\176\143\230\180\155\229\133\139%d\229\143\183\230\156\186", math.random(0, 99999999))
  req.num = create_num
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FRIEND_OPER_REQ, req, self, self.batchSendFriendRsp)
end

function DebugTabFriend:batchSendFriendRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("\229\165\189\229\143\139\230\137\185\233\135\143\229\164\132\231\144\134\229\164\177\232\180\165\239\188\140\230\137\190\229\144\142\229\143\176\229\144\140\229\173\166\233\151\174\233\151\174\229\144\167", table.tostring(rsp))
  end
end

function DebugTabFriend:OpenFriend()
  _G.IsGMOpenFriend = true
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenMainPanel)
end

function DebugTabFriend:VisitFriend(Name, Panel, InputNumber)
  local uin
  if Panel then
    uin = Panel:GetInputNumber()
  else
    uin = tonumber(InputNumber)
  end
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.DebugToVisit, uin)
end

function DebugTabFriend:OpenStudentCardPanel(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenStudentCardPanel, nil, FriendEnum.AdminFriendType.Own, FriendEnum.Source.Friend, nil)
end

function DebugTabFriend:DebugVisiblePoolInfo(Name, Panel)
  GlobalConfig.DebugVisiblePoolInfo = not GlobalConfig.DebugVisiblePoolInfo
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowVisiblePoolInfo)
  if GlobalConfig.DebugVisiblePoolInfo then
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "\229\188\128\229\144\175\230\152\190\231\164\186\229\143\175\232\167\129\229\140\186\228\191\161\230\129\175(\230\150\176)", true, true, UE4.FLinearColor(0, 1, 0, 1), 5)
  else
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "\229\133\179\233\151\173\230\152\190\231\164\186\229\143\175\232\167\129\229\140\186\228\191\161\230\129\175(\230\150\176)", true, true, UE4.FLinearColor(0, 1, 0, 1), 5)
  end
end

function DebugTabFriend:ShowPlayerDistance(Name, Panel)
  if self.DistanceTimer then
    _G.TimerManager:RemoveTimer(self.DistanceTimer)
    self.DistanceTimer = nil
  end
  _G.GlobalConfig.bShowPlayerDistance = not _G.GlobalConfig.bShowPlayerDistance
  if _G.GlobalConfig.bShowPlayerDistance then
    Log.Error("\229\188\128\229\144\175\230\152\190\231\164\186\231\142\169\229\174\182\232\183\157\231\166\187\229\138\159\232\131\189")
    self.DistanceTimer = _G.TimerManager:CreateTimer(self, "DebugTabFriend.DistanceTimer", 999, self.OnDistanceTimerUpdate, nil, 1)
  else
    Log.Error("\229\133\179\233\151\173\230\152\190\231\164\186\231\142\169\229\174\182\232\183\157\231\166\187\229\138\159\232\131\189")
    self:OnDistanceTimerUpdate(true)
  end
end

function DebugTabFriend:OnDistanceTimerUpdate(Close)
  local PlayerList = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_ALL_PLAYER)
  local LocalPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local MeshComp = LocalPlayer.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  if MeshComp then
    local OwnerLocation = MeshComp:Abs_K2_GetComponentLocation()
    for _, Player in pairs(PlayerList) do
      if Player and Player ~= LocalPlayer and Player.hudComponent then
        if Close then
          Player.hudComponent:SetHudName(Player.serverData.base.name)
        else
          local PlayerMeshComp = Player.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
          if PlayerMeshComp then
            local Dist = UE4.FVector.Dist(OwnerLocation, PlayerMeshComp:Abs_K2_GetComponentLocation())
            Player.hudComponent:SetHudName(Player.serverData.base.name .. ":" .. tostring(math.floor(Dist)))
          end
        end
      end
    end
  end
end

function DebugTabFriend:ShowHudVisitPanel(Name, Panel, InputNumber)
  local Uin
  if Panel then
    Uin = Panel:GetInputNumber()
  else
    Uin = tonumber(InputNumber)
  end
  local PlayerList = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_ALL_PLAYER)
  for _, Player in pairs(PlayerList) do
    if Player and Player.serverData.base.logic_id == Uin then
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenStudentCardPanel, Player.serverData, FriendEnum.AdminFriendType.Others, FriendEnum.Source.Scene, FriendEnum.SELECT_TAB.FaceToFaceInteraction)
      return
    end
  end
end

function DebugTabFriend:OpenSwapEggsPanel(Name, Panel)
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenSwapEggsUI)
end

return DebugTabFriend
