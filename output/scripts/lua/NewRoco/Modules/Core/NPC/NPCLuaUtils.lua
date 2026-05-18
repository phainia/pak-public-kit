local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local HomeUtils = require("NewRoco.Modules.System.Home.IndoorSandbox.HomeUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local NPCLuaUtils = {}

function NPCLuaUtils.GetSenseInfo(option)
  local CompassConf = _G.DataConfigManager:GetNpcCompassOption(option.config.id)
  if not CompassConf then
    return 0, NPCModuleEnum.SenseTypeEnum.NoSense
  end
  local action = CompassConf.action
  local first_compass_option_type = action.first_compass_option_type
  local next_compass_option_type = action.next_compass_option_type
  local num = action.sense_dist
  local dist = num * num * 10000
  local opt_dist = option:GetSquaredDistance()
  dist = math.max(dist, opt_dist)
  if 0 == option.optionInfo.succ_exec_times then
    if first_compass_option_type == _G.Enum.CompassType.CT_ALL_DISTANCE then
      return dist, NPCModuleEnum.SenseTypeEnum.TotalSense
    elseif first_compass_option_type == _G.Enum.CompassType.CT_OPT_DISTANCE then
      return opt_dist, NPCModuleEnum.SenseTypeEnum.InteractableSense
    elseif first_compass_option_type == _G.Enum.CompassType.CT_NO_DISTANCE then
      return 0, NPCModuleEnum.SenseTypeEnum.NoSense
    end
  elseif next_compass_option_type == _G.Enum.CompassType.CT_ALL_DISTANCE then
    return dist, NPCModuleEnum.SenseTypeEnum.TotalSense
  elseif next_compass_option_type == _G.Enum.CompassType.CT_OPT_DISTANCE then
    return opt_dist, NPCModuleEnum.SenseTypeEnum.InteractableSense
  elseif next_compass_option_type == _G.Enum.CompassType.CT_NO_DISTANCE then
    return 0, NPCModuleEnum.SenseTypeEnum.NoSense
  end
  return 0, NPCModuleEnum.SenseTypeEnum.NoSense
end

function NPCLuaUtils.HasValidPoint(npcInfo)
  if not npcInfo then
    return false
  end
  local BaseInfo = npcInfo.base
  if not BaseInfo then
    return false
  end
  local NPCBase = npcInfo.npc_base
  if NPCBase and NPCBase.pos_need_adjust then
    return false
  end
  local Point = npcInfo.base.pt
  if not Point then
    return false
  end
  local Pos = Point.pos
  if not Pos then
    return false
  end
  if 0 == Pos.x and 0 == Pos.y and 0 == Pos.z then
    return false
  end
  return true
end

NPCLuaUtils.PreLoadMap = {}

function NPCLuaUtils.PreLoad(url, priority)
  if NPCLuaUtils.PreLoadMap[url] then
    Log.Warning("Already Request PreLoad")
    return
  end
  priority = priority or 1
  _G.NRCResourceManager:LoadResAsync(NPCLuaUtils.PreLoadMap, url, priority, 0, NPCLuaUtils.OnResLoadSucc, nil, nil)
end

function NPCLuaUtils:OnResLoadSucc(req, class)
  req.class = class
  req.classRef = class and UnLua.Ref(class)
  NPCLuaUtils.PreLoadMap[req.assetPath] = req
end

function NPCLuaUtils.GetClass(url)
  if NPCLuaUtils.PreLoadMap[url] then
    return NPCLuaUtils.PreLoadMap[url].class
  else
    Log.Error("\230\178\161\230\156\137\229\138\160\232\189\189\229\165\189\232\181\132\230\186\144\239\188\140\229\144\140\230\173\165\229\138\160\232\189\189\239\188\140\232\176\131\231\148\168\229\136\176\232\191\153\233\135\140\232\175\180\230\152\142\228\184\141\229\164\170\229\175\185\229\138\178", url)
    return UE4.UClass.Load(url)
  end
end

function NPCLuaUtils.OnSeatNPCNotify(NPC, Action, BaseData)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, BaseData.operator_obj_id)
  if not Player then
    return
  end
  Log.Debug("===NPCLuaUtils=====OnSeatNPCNotify===========", Player.serverData.base.name, Action.seat_idx, Action.is_client_req_leave_seat)
  if Player.isLocal then
    local InteractionComponent = NPC.InteractionComponent
    if InteractionComponent then
      local AllOptions = InteractionComponent:GetAllOptions()
      for _, Option in pairs(AllOptions) do
        if Option.config.action.action_type == Action.action_type then
          local CurrentAction = Option.CurrentAction
          if CurrentAction then
            local PlayerModule = NRCModuleManager:GetModule("PlayerModule")
            if PlayerModule then
              PlayerModule:UnRegisterEvent(CurrentAction, PlayerModuleEvent.ON_INPUT_MOVE_NOTIFY)
            end
            CurrentAction:Finish(false)
          end
        end
      end
    end
  elseif (Action.action_type == Enum.ActionType.ACT_SIT or Action.action_type == Enum.ActionType.ACT_HOME_SIT_LIE) and NPC and NPC.serverData and NPC.serverData.base and NPC.serverData.base.actor_id then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer and localPlayer.serverData and localPlayer.serverData.avatar_interact and localPlayer.serverData.avatar_interact.sit_info and localPlayer.serverData.avatar_interact.sit_info.sit_npc_id and NPC.serverData.base.actor_id == localPlayer.serverData.avatar_interact.sit_info.sit_npc_id then
      localPlayer:OnInteractionLookAt(Player.viewObj, Action.is_client_req_leave_seat)
    end
  end
  if Action.action_type == Enum.ActionType.ACT_SIT then
    local SeatIdx = Action.seat_idx + 1
    if -1 == Action.seat_idx then
      local SitInfo = {}
      SitInfo.seat_idx = -1
      SitInfo.sit_npc_id = 0
      local SeatArray = {}
      local SeatInfo = {}
      if Player and Player.serverData and Player.serverData.avatar_interact then
        SeatInfo.seat_idx = Player.serverData.avatar_interact.sit_info.seat_idx
        SeatInfo.interact_avatar_id = 0
        SeatIdx = SeatInfo.seat_idx + 1
      end
      table.insert(SeatArray, SeatInfo)
      NPCLuaUtils.SaveSeatNPCServerData(Player, NPC, SitInfo, SeatArray)
      if Action.is_client_req_leave_seat then
        local Conf = _G.DataConfigManager:GetRoleplayPropConf(NPC.config.id)
        if not Conf then
          return
        end
        if Conf["flash_stand_specialeffect_" .. SeatIdx] then
          SceneUtils.PlayerFlashSkillForSceneSeat(Player, NPC.viewObj, nil, function()
            SceneUtils.PlayerInterruptSceneSeat(Player, NPC.viewObj)
            SceneUtils.PlayerFlashToPoint(Player, Action.before_sit_point)
          end)
        elseif Conf["flash_stand_" .. SeatIdx] then
          SceneUtils.PlayerInterruptSceneSeat(Player, NPC.viewObj)
          SceneUtils.PlayerFlashToPoint(Player, Action.before_sit_point)
        else
          SceneUtils.PlayerLeaveSceneSeat(Player)
        end
      else
        SceneUtils.PlayerInterruptSceneSeat(Player, NPC.viewObj)
      end
    else
      local SitInfo = {}
      SitInfo.seat_idx = Action.seat_idx
      SitInfo.sit_npc_id = NPC.serverData.base.actor_id
      local SeatArray = {}
      local SeatInfo = {}
      if Player and Player.serverData then
        SeatInfo.seat_idx = Action.seat_idx
        SeatInfo.interact_avatar_id = Player.serverData.base.actor_id
      end
      table.insert(SeatArray, SeatInfo)
      NPCLuaUtils.SaveSeatNPCServerData(Player, NPC, SitInfo, SeatArray)
      local Conf = _G.DataConfigManager:GetRoleplayPropConf(NPC.config.id)
      if not Conf then
        return
      end
      local SpecialG6 = Conf["special_pos_" .. SeatIdx]
      local Immediately = SpecialG6 or Conf["flash_sit_" .. SeatIdx]
      local SeatSlot = string.format("Seat_%s", SeatIdx)
      if Conf["flash_sit_specialeffect_" .. SeatIdx] then
        SceneUtils.PlayerFlashSkillForSceneSeat(Player, NPC.viewObj, SpecialG6, function()
          SceneUtils.PlayerSitToSceneSeat(NPC, SeatSlot, Player, Immediately, SpecialG6)
        end)
      else
        SceneUtils.PlayerSitToSceneSeat(NPC, SeatSlot, Player, Immediately, SpecialG6)
      end
    end
  elseif Action.action_type == Enum.ActionType.ACT_HOME_SIT_LIE then
    local SeatConf = _G.DataConfigManager:GetSeatConf(NPC.config.id)
    if not SeatConf then
      return
    end
    if -1 == Action.seat_idx then
      if Action.is_client_req_leave_seat then
        local FurnitureID = NPC.FurnitureID
        if not FurnitureID then
          Log.Error("NPCLuaUtils=====OnSeatNPCNotify=======FurnitureID is nil====", Player.serverData.base.name)
          HomeUtils.PlayerInterruptSceneSeat(Player, SeatConf.is_home_lie)
        else
          local FurnitureView = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetFurnitureView, FurnitureID)
          if not FurnitureView then
            Log.Error("NPCLuaUtils=====OnSeatNPCNotify=======FurnitureView is nil====", Player.serverData.base.name)
            HomeUtils.PlayerInterruptSceneSeat(Player, SeatConf.is_home_lie)
          else
            HomeUtils.PlayerLeaveHomeSeat(Player, FurnitureView, Action.leave_point_idx, SeatConf.is_home_lie)
          end
        end
      else
        HomeUtils.PlayerInterruptSceneSeat(Player, SeatConf.is_home_lie)
      end
      local SitInfo = {}
      SitInfo.seat_idx = -1
      SitInfo.sit_npc_id = 0
      local SeatArray = {}
      local SeatInfo = {}
      if Player and Player.serverData and Player.serverData.avatar_interact then
        SeatInfo.seat_idx = Player.serverData.avatar_interact.sit_info.seat_idx
        SeatInfo.interact_avatar_id = 0
      end
      table.insert(SeatArray, SeatInfo)
      NPCLuaUtils.SaveSeatNPCServerData(Player, NPC, SitInfo, SeatArray)
    else
      local FurnitureID = NPC.FurnitureID
      if not FurnitureID then
        return
      end
      local FurnitureView = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetFurnitureView, FurnitureID)
      if not FurnitureView then
        return
      end
      local SitInfo = {}
      local SeatArray = {}
      local CurSeatIdx = -1
      if Player and Player.serverData and Player.serverData.avatar_interact then
        CurSeatIdx = Player.serverData.avatar_interact.sit_info.seat_idx
      end
      if -1 ~= CurSeatIdx then
        SitInfo.seat_idx = Action.seat_idx
        SitInfo.sit_npc_id = NPC.serverData.base.actor_id
        local SeatOne = {}
        local SeatTwo = {}
        if Player and Player.serverData then
          SeatOne.seat_idx = CurSeatIdx
          SeatOne.interact_avatar_id = 0
          SeatTwo.seat_idx = Action.seat_idx
          SeatTwo.interact_avatar_id = Player.serverData.base.actor_id
        end
        table.insert(SeatArray, SeatOne)
        table.insert(SeatArray, SeatTwo)
        HomeUtils.PlayerChangeHomeSeat(Player, FurnitureView, Action.seat_idx + 1)
      else
        SitInfo.seat_idx = Action.seat_idx
        SitInfo.sit_npc_id = NPC.serverData.base.actor_id
        local SeatInfo = {}
        if Player and Player.serverData then
          SeatInfo.seat_idx = Action.seat_idx
          SeatInfo.interact_avatar_id = Player.serverData.base.actor_id
        end
        table.insert(SeatArray, SeatInfo)
        HomeUtils.PlayerSitToHomeSeat(Player, FurnitureView, Action.seat_idx + 1, SeatConf.is_home_lie)
      end
      NPCLuaUtils.SaveSeatNPCServerData(Player, NPC, SitInfo, SeatArray)
    end
  end
end

function NPCLuaUtils.SaveSeatNPCServerData(Player, NPC, NewSitInfo, NewSeatInfo)
  if Player and Player and Player.serverData and Player.serverData.avatar_interact then
    Player.serverData.avatar_interact.sit_info = NewSitInfo
  end
  if NPC and NPC.serverData and NPC.serverData.npc_interact and NPC.serverData.npc_interact.seat_info then
    local SeatInfo = NPC.serverData.npc_interact.seat_info.seat_info
    for __, NewInfo in ipairs(NewSeatInfo) do
      for _, Info in pairs(SeatInfo) do
        if Info.seat_idx == NewInfo.seat_idx then
          Info.interact_avatar_id = NewInfo.interact_avatar_id
        end
      end
    end
  end
end

function NPCLuaUtils.DebugSceneSeatEQS(Result)
  if Result.AbsoluteResultLocations then
    local TotalPoints = Result.AbsoluteResultLocations:Num()
    for i = 1, TotalPoints do
      local Score = 1.0
      local Loc = Result.AbsoluteResultLocations:Get(i)
      local IsValid = Result.ItemSuccess:Get(i)
      local Desc = Result.FailedTestDescriptions:Get(i)
      local Color = IsValid and UE.FLinearColor(0, 1, 0, 0.5) or UE.FLinearColor(1, 0, 0, 0.3)
      Score = Result.Scores and Result.Scores:Get(i) or 1.0
      if "" ~= Desc then
        Score = Desc
      end
      UE.UKismetSystemLibrary.Abs_DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(Loc.X, Loc.Y, Loc.Z), 25, 12, Color, 50, 2)
      UE4.UKismetSystemLibrary.Abs_DrawDebugString(_G.UE4Helper.GetCurrentWorld(), Loc + UE4.FVector(50, 50, 0), Score, nil, UE4.FLinearColor(0, 0, 1, 1), 50)
    end
  end
end

NPCLuaUtils.BallResRefMap = {}
NPCLuaUtils.BallResHandlerMap = {}
NPCLuaUtils.BallResHandlerRefMap = {}

function NPCLuaUtils.BatchLoadBallRes(ball_id, ball_view, priority)
  if not UE.UObject.IsValid(ball_view) then
    return
  end
  local batchLoader = NPCLuaUtils.BallResHandlerMap[ball_id]
  if batchLoader and UE.UObject.IsValid(batchLoader) then
    if not NPCLuaUtils.BallResRefMap[ball_id] then
      NPCLuaUtils.BallResRefMap[ball_id] = {}
    end
    local RefMap = NPCLuaUtils.BallResRefMap[ball_id]
    RefMap[ball_view] = true
    return
  end
  local BatchLoader = NewObject(UE4.UASyncResourceRequestBatch, UE4.UNRCPlatformGameInstance.GetInstance())
  local BatchLoaderRef = UnLua.Ref(BatchLoader)
  ball_view:PreLoadResMap(BatchLoader, priority, "", false, nil, nil, nil, true)
  if not NPCLuaUtils.BallResRefMap[ball_id] then
    NPCLuaUtils.BallResRefMap[ball_id] = {}
  end
  local RefMap = NPCLuaUtils.BallResRefMap[ball_id]
  RefMap[ball_view] = true
  NPCLuaUtils.BallResHandlerMap[ball_id] = BatchLoader
  NPCLuaUtils.BallResHandlerRefMap[ball_id] = BatchLoaderRef
end

function NPCLuaUtils.BatchReleaseBallRes(ball_id, ball_view)
  local refMap = NPCLuaUtils.BallResRefMap[ball_id]
  if refMap then
    refMap[ball_view] = nil
  end
  if table.isEmpty(refMap) then
    NPCLuaUtils.BallResRefMap[ball_id] = nil
    local batchLoader = NPCLuaUtils.BallResHandlerMap[ball_id]
    local batchLoaderRef = NPCLuaUtils.BallResHandlerRefMap[ball_id]
    if UE.UObject.IsValid(batchLoader) then
      batchLoader:Cancel()
    end
    if UE4.UObject.IsValid(batchLoaderRef) then
      UnLua.Unref(batchLoaderRef)
    end
    NPCLuaUtils.BallResHandlerMap[ball_id] = nil
    NPCLuaUtils.BallResHandlerRefMap[ball_id] = nil
  end
end

function NPCLuaUtils.BindNpcViewObj(Npc, ViewObj)
  if Npc.viewObj or ViewObj.sceneCharacter then
    Log.Error("[PlaceableNpc] sceneNpc or viewNpc is not clear when placeable npc bind")
  end
  Npc:SetViewObj(ViewObj)
  if Npc.luaObj then
    Npc.luaObj:SetViewObj(ViewObj)
  end
  ViewObj:Init()
  ViewObj:SetSceneCharacter(Npc)
  ViewObj:LuaBeginPlay()
end

local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")

function NPCLuaUtils.SetCharacterAlpha(CharacterView, TargetAlpha, Duration, OnFinishedCallback)
  local Task = NPCLuaUtils.MakeSetAlphaTask(CharacterView, TargetAlpha, Duration)
  if Task then
    Task(OnFinishedCallback)
  elseif OnFinishedCallback then
    OnFinishedCallback(false, false)
  end
end

function NPCLuaUtils.MakeSetAlphaTask(CharacterView, TargetAlpha, Duration)
  if not (CharacterView and UE.UObject.IsValid(CharacterView) and CharacterView.SetMeshAlpha and TargetAlpha) or not Duration then
    return nil
  end
  local Task = a.task(function()
    if not UE.UObject.IsValid(CharacterView) then
      return false
    end
    local StartAlpha = CharacterView.alpha
    local CurAlpha = StartAlpha
    local Elapsed = 0
    local Dt = 0
    local Alpha2Set = 0
    while Elapsed <= Duration do
      if not UE.UObject.IsValid(CharacterView) then
        return false
      end
      Elapsed = Elapsed + Dt
      Alpha2Set = math.clamp(Elapsed / Duration, 0, 1)
      CurAlpha = LuaMathUtils.LerpWithAlpha(StartAlpha, TargetAlpha, Alpha2Set)
      CharacterView:SetMeshAlpha(CurAlpha)
      Dt = a.wait(au.NextTick())
    end
    CharacterView:SetMeshAlpha(TargetAlpha)
    return true
  end)
  return Task
end

function NPCLuaUtils.ResetPet(CharacterView, Duration, TargetPos, TargetRotation, OnTeleportedCallback)
  if not (CharacterView and UE.UObject.IsValid(CharacterView) and CharacterView.SetMeshAlpha) or not Duration then
    return
  end
  local TeleportTask = a.task(function()
    local SceneNpc = CharacterView.sceneCharacter
    if not (CharacterView and UE.UObject.IsValid(CharacterView)) or not SceneNpc then
      return
    end
    if SceneNpc.InteractionComponent then
      SceneNpc.InteractionComponent:SetInteractionEnable(false, NPCModuleEnum.NpcInteractDisableFlag.ANY, false)
    end
    if SceneNpc.AIComponent then
      SceneNpc.AIComponent:ForceLockForReason(true, false, _G.AIDefines.LockReason.HIDDEN)
    end
    a.wait(NPCLuaUtils.MakeSetAlphaTask(CharacterView, 1, Duration))
    if not (CharacterView and UE.UObject.IsValid(CharacterView)) or not SceneNpc then
      return
    end
    CharacterView:SetActorLocation(TargetPos or SceneNpc.serverPos)
    CharacterView:K2_SetActorRotation(TargetRotation or SceneNpc.serverDataRotate, false)
    if OnTeleportedCallback then
      OnTeleportedCallback()
    end
    if SceneNpc.AIComponent then
      SceneNpc.AIComponent:ForceLockForReason(false, false, _G.AIDefines.LockReason.HIDDEN)
    end
    a.wait(au.NextTick())
    a.wait(NPCLuaUtils.MakeSetAlphaTask(CharacterView, 0, Duration))
  end)
  return TeleportTask(function()
    local SceneNpc = CharacterView.sceneCharacter
    if not (CharacterView and UE.UObject.IsValid(CharacterView)) or not SceneNpc then
      return
    end
    if SceneNpc.InteractionComponent then
      SceneNpc.InteractionComponent:SetInteractionEnable(true, NPCModuleEnum.NpcInteractDisableFlag.ANY, false)
    end
    if SceneNpc.AIComponent then
      SceneNpc.AIComponent:ForceLockForReason(false, false, _G.AIDefines.LockReason.HIDDEN)
    end
  end)
end

function NPCLuaUtils.SetCustomDepth(Actor, Depth)
  if not UE4.UObject.IsValid(Actor) then
    return
  end
  local Comps = Actor:K2_GetComponentsByClass(UE.UMeshComponent)
  for _, Comp in tpairs(Comps) do
    if not Comp:IsA(UE.UWidgetComponent) then
      NPCLuaUtils.SetCompCustomDepth(Comp, Depth)
    end
  end
  local ChildActorComps = Actor:K2_GetComponentsByClass(UE.UChildActorComponent)
  for _, Comp in tpairs(ChildActorComps) do
    if Comp:IsA(UE.UChildActorComponent) then
      local childActor = Comp:GetChildActor()
      if UE4.UObject.IsValid(childActor) then
        NPCLuaUtils.SetCustomDepth(childActor, Depth)
      end
    end
  end
end

function NPCLuaUtils.SetCompCustomDepth(Comp, Depth)
  if not Comp or not UE.UObject.IsValid(Comp) then
    return
  end
  if nil == Depth then
    Comp:SetRenderCustomDepth(false)
    Comp:SetCustomDepthStencilValue(0)
    Comp:SetCastShadow(true)
  else
    Comp:SetRenderCustomDepth(true)
    Comp:SetCustomDepthStencilValue(Depth)
    Comp:SetCastShadow(false)
    Log.Debug("[NPCLuaUtils] SetCompCustomDepth", Depth)
  end
end

return NPCLuaUtils
