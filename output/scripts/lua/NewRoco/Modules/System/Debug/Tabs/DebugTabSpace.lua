local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local QuickTeleport = require("NewRoco.Modules.Core.Scene.Common.QuickTeleport")
local CameraMoveInstance = require("NewRoco.Modules.System.MiniGame.CameraMoveInstance")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local EnumDict = {
  [UE.ESlateVisibility.Visible] = "Visible",
  [UE.ESlateVisibility.Hidden] = "Hidden",
  [UE.ESlateVisibility.Collapsed] = "Collapsed",
  [UE.ESlateVisibility.HitTestInvisible] = "HitTestInvisible",
  [UE.ESlateVisibility.SelfHitTestInvisible] = "SelfHitTestInvisible"
}
local DebugTabSpace = Base:Extend("DebugTabSpace")

function DebugTabSpace:SetupTabs()
  self:Add("\230\183\187\229\138\160StoryFlag", self.AddStoryFlag, self)
  self:Add("\231\167\187\233\153\164StoryFlag", self.RemoveStoryFlag, self)
  for Name, Value in pairs(Enum.TaskClassType) do
    self:Add(Name, self.ShowTaskByType, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\160\185\230\141\174\228\187\187\229\138\161\231\177\187\229\158\139\229\185\178\229\152\155\229\145\162")
  end
  self:Add("PutContent", self.PutContent, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("GetContent", self.GetContent, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("Big", self.BigSan, self)
  self:Add("No", self.NoSan, self)
  self:Add("\233\147\190\232\161\168\232\138\130\231\130\185\230\149\176\233\135\143", self.ListTest, self)
end

function DebugTabSpace:ListTest()
  local LinkedList = require("Utils.LinkedList")
  local List = LinkedList("Test")
  List:Insert("1")
  List:Insert("2")
  List:Insert("3")
  List:Insert("4")
  List:PrintAll()
  List:Iterate(nil, function(Value)
    List:Remove(Value)
    List:Insert(tostring(tonumber(Value) + 4))
  end)
  List:PrintAll()
  List:RemoveAll()
  List:PrintAll()
  self:Inspect(LinkedList.GetNodeCounts(), "Linked-List Node Count")
end

function DebugTabSpace:BigSan()
  local Nearest = self:GetNearestNpc()
  Nearest.viewObj:Nourish_Big_CT()
end

function DebugTabSpace:NoSan()
  local Nearest = self:GetNearestNpc()
  Nearest.viewObj:NoNourish()
end

function DebugTabSpace:AddHook(Name, Panel, InputText)
  local DebugHook = require("NewRoco.Modules.System.Debug.DebugHook")
  local Input
  if Panel then
    Input = Panel:GetInputString()
  else
    Input = InputText
  end
  local Parts = string.split(Input, "@")
  if not Parts then
    return
  end
  if 2 ~= #Parts then
    return
  end
  DebugHook.Add(Parts[1], tonumber(Parts[2]))
end

function DebugTabSpace:RemoveHook(Name, Panel, InputText)
  local DebugHook = require("NewRoco.Modules.System.Debug.DebugHook")
  local Input
  if Panel then
    Input = Panel:GetInputString()
  else
    Input = InputText
  end
  local Parts = string.split(Input, "@")
  if not Parts then
    return
  end
  if 2 ~= #Parts then
    return
  end
  DebugHook.Remove(Parts[1], tonumber(Parts[2]))
end

function DebugTabSpace:ShowCachedActions(Name, Panel)
  local SceneModule = self:GetModule("SceneModule")
  self:Inspect(SceneModule.ActionCaches, "ActionCaches")
end

function DebugTabSpace:ShowUIStats(Name, Panel)
  self:Inspect(_G.NRCPanelManager.panelDict, "panelDict")
end

function DebugTabSpace:ShowPlayerStats(Name, Panel)
  self:Inspect(self:GetPlayer(), "SceneLocalPlayer")
end

function DebugTabSpace:ShowPlayerInfoStats(Name, Panel)
  self:Inspect(_G.DataModelMgr.PlayerDataModel.loginData, "Info Stats")
end

function DebugTabSpace:AddCachedDebugData(Name, Panel)
  self:InspectAddCached(Panel, "AddCachedDebugData")
end

function DebugTabSpace:ShowCachedDebugData(Name, Panel)
  self:InspectOpenCached(Panel, self:GetInputString() or "Data")
end

function DebugTabSpace:DumpUMGStats(Widget)
  if UE4.UObject.IsValid(Widget) then
    local SeqPlayers
    if Widget and Widget.ActiveSequencePlayers then
      for _, SeqPlayer in tpairs(Widget.ActiveSequencePlayers) do
        SeqPlayers = SeqPlayers or {}
        table.insert(SeqPlayers, SeqPlayer:GetUserTag())
      end
    end
    return {
      Name = Widget:GetName(),
      Visibility = EnumDict[Widget:GetVisibility()],
      AnyAnimationPlaying = Widget.IsAnyAnimationPlaying and tostring(Widget:IsAnyAnimationPlaying()) or "Nope",
      Opacity = Widget.GetRenderOpacity and Widget:GetRenderOpacity() or "Nope",
      SequencePlayers = SeqPlayers or "Nope"
    }
  else
    return "Invalid"
  end
end

function DebugTabSpace:ShowMainUIStats(Name, Panel)
  local Module = self:GetModule("MainUIModule")
  local MainPanel = Module:GetPanel("LobbyMain", 1)
  self:Inspect({
    Panel = self:DumpUMGStats(MainPanel),
    PlayerAbilities = self:DumpUMGStats(MainPanel.UMG_PlayerAbilities),
    MainPet = self:DumpUMGStats(MainPanel.UMG_MainPet),
    PlayerInfoHUD = self:DumpUMGStats(MainPanel.UMG_PlayerInfoHUD),
    EquipItem = self:DumpUMGStats(MainPanel.UMG_PlayerInfoHUD.EquipItem),
    FullStateMask = self:DumpUMGStats(MainPanel.FullStateMask),
    VisibleContent = self:DumpUMGStats(MainPanel.VisibleContents)
  }, "Visibility")
end

function DebugTabSpace:FlushMainPanelAnimation(Name, Panel)
  local Module = self:GetModule("MainUIModule")
  local MainPanel = Module:GetPanel("LobbyMain", 1)
  if MainPanel then
    MainPanel:FlushAnimations()
  else
    self:ShowTips("\228\184\187\231\149\140\233\157\162\229\188\128\228\186\134")
  end
end

function DebugTabSpace:ShowPlayerInputStats(Name, Panel)
  local Player = self:GetPlayer()
  self:Inspect(Player.inputComponent, "InputComponent")
end

function DebugTabSpace:ShowGlobalConfig(Name, Panel)
  self:Inspect(_G.GlobalConfig, "GlobalConfig")
end

function DebugTabSpace:ShowPlayerMoveStats(Name, Panel)
  local Player = self:GetPlayer()
  local Controller = Player:GetUEController()
  local IsIdle = UE4.UNRCNavLibrary.CheckIfPathFollowingIdle(Player.viewObj, Controller)
  local Component = Controller.Pawn.CharacterMovement
  self:Inspect({
    PathFollowingIdle = IsIdle,
    MovementMode = Component.MovementMode,
    CustomMovementMode = Component.CustomMovementMode
  }, "Move Status")
end

function DebugTabSpace:ShowTaskStats(Name, Panel)
  local TaskModule = self:GetModule("TaskModule")
  self:Inspect(TaskModule, "TaskModule")
end

function DebugTabSpace:ShowTaskByType(Name, Panel)
  local Value = Enum.TaskClassType[Name]
  local TaskModule = self:GetModule("TaskModule")
  local Display = {}
  for ID, Obj in pairs(TaskModule.data.TaskMap) do
    if Obj.Config.task_class == Value then
      table.insert(Display, Obj)
    end
  end
  self:Inspect(Display, Name)
end

function DebugTabSpace:ShowNetworkStats(Name, Panel)
  self:Inspect(_G.ZoneServer, "ZoneServer")
end

function DebugTabSpace:GetInfoTest(Name, Panel)
  local Hello = "1213123"
  local Info = Log.Inspect()
  self:Inspect(Info)
end

function DebugTabSpace:StopPlayer(Name, Panel)
  local Player = self:GetPlayer()
  Player:Stop()
end

function DebugTabSpace:ShowPlayer(Name, Panel)
  local Player = self:GetPlayer()
  Player:SetVisible(true)
end

function DebugTabSpace:HidePlayer(Name, Panel)
  local Player = self:GetPlayer()
  Player:Stop()
  Player:SetVisible(false)
end

function DebugTabSpace:ShowTeleportStats(Name, Panel)
  local Player = self:GetPlayer()
  self:Inspect(Player.teleportComponent, "teleportComponent")
end

function DebugTabSpace:ShakeTree(Name, Panel)
  local NPC = self:GetNearestNpc()
  local View = NPC.viewObj
  View:Shake()
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabSpace:Boom(Name, Panel)
  local World = _G.UE4Helper.GetCurrentWorld()
  local Player = self:GetPlayer()
  local Location = Player.viewObj:K2_GetActorLocation()
  Log.Error("boom at location", tostring(Location))
  UE.UNRCStatics.BatchShakeTrees(World, Location, 500)
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabSpace:ShowAllPets(Name, Panel)
  self:Inspect(_G.DataModelMgr.PlayerDataModel.pets, "All Pets")
end

function DebugTabSpace:ShowUISessions(Name, Panel)
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local MainView = mainUIModule and mainUIModule:GetPanel("LobbyMain") or nil
  self:Inspect(MainView:GetCurPetSession(), "UI Sessions")
end

function DebugTabSpace:ChangeWeather(Name, Panel, InputNumber)
  local num
  if Panel then
    num = self:GetInputNumber(0)
  else
    num = tonumber(InputNumber) or 0
  end
  self:DoCmd(EnvSystemModuleCmd.ChangeWeather, num, true)
end

function DebugTabSpace:PlayAppear(Name, Panel)
  self:GetNearestNpc().viewObj:AllAppear()
  self:ClosePanel()
end

function DebugTabSpace:PlayClose(Name, Panel)
  self:GetNearestNpc().viewObj:Close()
  self:ClosePanel()
end

function DebugTabSpace:PlayUnlock(Name, Panel)
  self:GetNearestNpc().viewObj:TurnAndOpen(self:GetPlayer().viewObj:K2_GetActorLocation())
  self:ClosePanel()
end

function DebugTabSpace:PlayOpen(Name, Panel)
  self:GetNearestNpc().viewObj:Open()
  self:ClosePanel()
end

function DebugTabSpace:Reload(Name)
  local Manager = _G.DataConfigManager
  local ID = Manager.ConfigTableId[Name]
  Manager.__dataTables[ID] = nil
end

function DebugTabSpace:CameraLiteTest(Name, Panel, InputText)
  local Numbers
  if Panel then
    Numbers = Panel:GetInputNumbers()
  else
    local Raw = InputText
    local Texts
    if not string.IsNilOrEmpty(Raw) then
      Texts = string.split(Raw, ",")
      for i = 1, #Texts do
        Texts[i] = tonumber(Texts[i])
      end
    end
    Numbers = Texts
  end
  local ConfID = Numbers[1] or 10001
  local NPCID = Numbers[2] or 0
  self:Reload("CAMERA_MOVE_LITE")
  local Conf = table.clone(_G.DataConfigManager:GetCameraMoveLite(ConfID))
  if 0 ~= NPCID then
    Conf.focus_npc[1] = NPCID
    Log.Error("Focusing", NPCID)
  else
    local NPC = self:GetNearestNpc()
    if not NPC then
      Log.Error("\229\145\168\229\155\180\230\178\161\230\156\137NPC")
      return
    end
    local ID = NPC.serverData.npc_base.npc_content_cfg_id
    Conf.focus_npc[1] = ID
    Log.Error("Focusing", NPC:DebugNPCNameAndID())
  end
  local Instance = CameraMoveInstance(ConfID)
  Instance.CameraMoveConf = Conf
  Instance:Start(self, self.OnCameraOver)
  self:ClosePanel()
end

function DebugTabSpace:OnCameraOver()
  Log.Error("Camera Move Done")
end

function DebugTabSpace:ForceOpenBox(Name, Panel)
  local NPC = self:GetNearestNpc()
  NPC.viewObj:Show()
  self:ClosePanel()
end

function DebugTabSpace:GoMagic(Name, Panel, InputText)
  local Numbers = {}
  if Panel then
    Numbers = Panel:GetInputNumbers()
  else
    local Raw = InputText
    local Texts = {}
    if not string.IsNilOrEmpty(Raw) then
      Texts = string.split(Raw, ",")
      for i = 1, #Texts do
        Texts[i] = tonumber(Texts[i])
      end
      Numbers = Texts
    end
  end
  local Pos
  if #Numbers < 3 then
    local Player = self:GetPlayer()
    local Forward = Player:GetForwardVector()
    Pos = Player:GetActorLocation()
    Pos = Pos + Forward * 1500
    Pos.Z = Pos.Z + 300
  else
    Pos = UE.FVector(Numbers[1] or 0, Numbers[2] or 0, Numbers[3] or 0)
  end
  local TP = QuickTeleport()
  TP:Go(Pos, self, self.Teleported)
end

function DebugTabSpace:Teleported()
  Log.Error("Teleported!!!")
  self:ClosePanel()
end

function DebugTabSpace:PutContent()
  local Player = self:GetPlayer()
  local List = ProtoMessage:newPointList()
  table.insert(List.points, Player:GetServerPoint())
  _G.DataModelMgr.RemoteStorage:Set("TestKey", ".Next.PointList", List, self, self.OnPutResult)
end

function DebugTabSpace:OnPutResult(rsp)
  Log.Dump(rsp, 2, "DebugTabSpace:OnPutResult")
end

function DebugTabSpace:GetContent()
  _G.DataModelMgr.RemoteStorage:Get("TestKey", ".Next.PointList", self, self.OnGetContent)
end

function DebugTabSpace:OnGetContent(Data)
  Log.Dump(Data, 2, "DebugTabSpace:OnGetContent")
end

function DebugTabSpace:AddStoryFlag(Name, Panel)
  local Flag = self:GetInputNumber(0)
  local Flags = _G.DataModelMgr.PlayerDataModel:GetStoryFlags()
  if not table.contains(Flags, Flag) then
    table.insert(Flags, Flag)
    _G.DataModelMgr.PlayerDataModel:SendEvent(ENUM_PLAYER_DATA_EVENT.STORY_FLAG_ADDED, Flag)
    _G.DataModelMgr.PlayerDataModel:SendEvent(ENUM_PLAYER_DATA_EVENT.STORY_FLAG_CHANGE, Flag)
  end
end

function DebugTabSpace:RemoveStoryFlag(Name, Panel)
  local Flag = self:GetInputNumber(0)
  local Flags = _G.DataModelMgr.PlayerDataModel:GetStoryFlags()
  if table.contains(Flags, Flag) then
    table.removeValue(Flags, Flag)
    _G.DataModelMgr.PlayerDataModel:SendEvent(ENUM_PLAYER_DATA_EVENT.STORY_FLAG_REMOVED, Flag)
    _G.DataModelMgr.PlayerDataModel:SendEvent(ENUM_PLAYER_DATA_EVENT.STORY_FLAG_CHANGE, Flag)
  end
end

return DebugTabSpace
