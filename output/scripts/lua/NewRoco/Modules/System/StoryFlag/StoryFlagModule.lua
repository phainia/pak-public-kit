local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local StoryFlagModuleEvent = require("NewRoco.Modules.System.StoryFlag.StoryFlagModuleEvent")
local StoryFlagPreloadLists = require("NewRoco.Modules.Core.Task.PreloadRes.StoryFlagPreloadLists")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local StoryFlagModule = NRCModuleBase:Extend("StoryFlagModule")

function StoryFlagModule:OnConstruct()
  _G.StoryFlagModuleCmd = reload("NewRoco.Modules.System.StoryFlag.StoryFlagModuleCmd")
  self.TagStateCache = {}
  self.PlotLevelName = {}
  self.PreloadedRequests = {}
  self.PreloadedRefs = {}
  self.LevelSwitchCache = false
  self.StoryFlagTimeHandler = nil
  self:RegisterCmd(_G.StoryFlagModuleCmd.GetCurrentStoryBgmState, self.GetCurrentStoryBgmState)
  self:RegisterCmd(_G.StoryFlagModuleCmd.GetLoadSceneList, self.GetLoadSceneList)
end

function StoryFlagModule:OnActive()
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.STORY_FLAG_CHANGE, self.UpdateStoryFlag)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.ON_HOME_OWNER_STORY_FLAG_CHANGED, self.UpdateHomeOwnerStoryFlag)
  _G.NRCEventCenter:RegisterEvent("NPCModule", self, SceneEvent.PreLoadMapStart, self.OnPreLoadMapStart)
  _G.NRCEventCenter:RegisterEvent("NPCModule", self, SceneEvent.BeforeLandPos, self.OnMapLoaded)
end

function StoryFlagModule:OnRelogin()
  self:UpdateStoryFlag()
end

function StoryFlagModule:OnDeactive()
  table.clear(self.PreloadedRequests)
  table.clear(self.PreloadedRefs)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.ON_HOME_OWNER_STORY_FLAG_CHANGED, self.UpdateHomeOwnerStoryFlag)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.STORY_FLAG_CHANGE, self.UpdateStoryFlag)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.PreLoadMapStart, self.OnPreLoadMapStart)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.BeforeLandPos, self.OnMapLoaded)
  self:RemoveStoryLevels()
end

function StoryFlagModule:OnDestruct()
end

function StoryFlagModule:OnPreLoadMapStart(SameSceneRes, bReconnecting, id)
  self.SameSceneRes = SameSceneRes
end

function StoryFlagModule:OnMapLoaded()
  Log.Debug("StoryFlagModule:OnMapLoaded")
  if not self.SameSceneRes then
    table.clear(self.PlotLevelName)
  end
  self:UpdateStoryFlag()
end

function StoryFlagModule:UpdateHomeOwnerStoryFlag(bFlag)
  self:UpdateStoryFlag()
  _G.NRCEventCenter:DispatchEvent(StoryFlagModuleEvent.OnHomeOwnerStoryFlagChange, bFlag)
end

function StoryFlagModule:UpdateStoryFlag()
  local StoryFlags = _G.DataModelMgr.PlayerDataModel:GetStoryFlags()
  local HomeOwnerFlags = _G.DataModelMgr.PlayerDataModel:GetHomeOwnerStoryFlags()
  local RawConfs = _G.DataConfigManager:GetAllByName("FUNCTION_STORY_FLAG_CONF")
  local World = _G.UE4Helper.GetCurrentWorld()
  self.TaskBGMState = nil
  self.TaskBGMStateID = 0
  local TodLockFlags = {}
  local SceneResConf = SceneUtils.GetSceneResConf()
  for ID, Conf in pairs(RawConfs) do
    local HasFlag = false
    if _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(ID) then
      HasFlag = table.contains(StoryFlags, ID)
    else
      HasFlag = table.contains(HomeOwnerFlags, ID)
    end
    local ActionType = Conf.story_flag_action_type
    if ActionType == Enum.StoryFlagAction.SFA_ACTOR_TAG_OPEN then
      self:ToggleActorWithFlags(World, Conf.action_string_param, HasFlag)
    elseif ActionType == Enum.StoryFlagAction.SFA_ACTOR_TAG_CLOSE then
      self:ToggleActorWithFlags(World, Conf.action_string_param, not HasFlag)
    elseif ActionType == Enum.StoryFlagAction.SFA_AIR_WALL_OPEN then
    elseif ActionType == Enum.StoryFlagAction.SFA_AIR_WALL_CLOSE then
    elseif ActionType == Enum.StoryFlagAction.SFA_TASK_BGM then
      if HasFlag and ID > self.TaskBGMStateID then
        self.TaskBGMState = Conf.action_string_param
        self.TaskBGMStateID = ID
      end
    elseif ActionType == Enum.StoryFlagAction.SFA_LOAD_LEVEL then
      if HasFlag then
        if not table.contains(self.PlotLevelName, Conf.action_string_param) then
          UE4.UNRCStatics.ImmediateLoadPlotStreamingLevel(Conf.action_string_param)
          table.insert(self.PlotLevelName, Conf.action_string_param)
        end
      else
        for i, v in ipairs(self.PlotLevelName) do
          if v == Conf.action_string_param then
            UE4.UNRCStatics.ImmediateRemovePlotStreamingLevel(Conf.action_string_param)
            table.removeValue(self.PlotLevelName, Conf.action_string_param)
            break
          end
        end
      end
    elseif ActionType == Enum.StoryFlagAction.SFA_OPEN_LIGHT_LEVEL then
      local SceneIDs = Conf.action_int_param
      for _, SceneID in ipairs(SceneIDs) do
        if not self.LevelSwitchCache then
          self.LevelSwitchCache = {}
        end
        self.LevelSwitchCache[SceneID] = Conf
        if SceneID == SceneResConf.id and HasFlag then
          _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.SwitchDynamicLevel, Conf.action_string_param)
        end
      end
    elseif ActionType == Enum.StoryFlagAction.SFA_TASK_PRELOAD then
      self:TogglePreload(HasFlag, ID)
    elseif ActionType == Enum.StoryFlagAction.SFA_TOD_LOCK then
      local SceneID = Conf.action_int_param[1]
      if SceneID == SceneResConf.id and HasFlag then
        if not TodLockFlags or not TodLockFlags[1] then
          TodLockFlags = {}
          TodLockFlags[1] = ID
        elseif ID > TodLockFlags[1] then
          table.insert(TodLockFlags, 1, ID)
        else
          table.insert(TodLockFlags, ID)
        end
      end
    end
  end
  if TodLockFlags and TodLockFlags[1] then
    local Conf = _G.DataConfigManager:GetFunctionStoryFlagConf(TodLockFlags[1])
    local SceneID = Conf.action_int_param[1]
    local LockTime = Conf.action_int_param[2] / 3600
    if self.StoryFlagTimeHandler then
      if self.StoryFlagTimeHandler.SceneID ~= SceneID or self.StoryFlagTimeHandler.FlagID ~= TodLockFlags[1] then
        _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ReleaseTime, self.StoryFlagTimeHandler)
        self.StoryFlagTimeHandler = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTime, LockTime)
        self.StoryFlagTimeHandler.SceneID = SceneID
        self.StoryFlagTimeHandler.FlagID = TodLockFlags[1]
      end
    else
      self.StoryFlagTimeHandler = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTime, LockTime)
      self.StoryFlagTimeHandler.SceneID = SceneID
      self.StoryFlagTimeHandler.FlagID = TodLockFlags[1]
    end
    if table.len(TodLockFlags) > 1 then
      self:ShowTodLockDebugPopup(TodLockFlags, SceneID)
    end
  elseif self.StoryFlagTimeHandler then
    _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ReleaseTime, self.StoryFlagTimeHandler)
    self.StoryFlagTimeHandler = nil
  end
  if not string.IsNilOrEmpty(self.TaskBGMState) then
    self.TaskBGMState = string.format("Task_Music;Task_Music;%s", self.TaskBGMState)
  end
  table.clear(self.TagStateCache)
  _G.NRCEventCenter:DispatchEvent(StoryFlagModuleEvent.OnStoryFlagChange)
end

function StoryFlagModule:ShowTodLockDebugPopup(flags, sceneResId)
  local Ctx = DialogContext()
  local flagTxt = ""
  for _, id in pairs(flags) do
    flagTxt = flagTxt .. tostring(id) .. ", "
  end
  local conf = _G.DataConfigManager:GetLocalizationConf("tod_lock_conflict")
  Ctx:SetContent(string.format(conf.msg, flagTxt, sceneResId))
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function StoryFlagModule:GetLoadSceneList(SceneID)
  if not SceneID then
    return nil
  end
  if not self.LevelSwitchCache then
    return nil
  end
  local Conf = self.LevelSwitchCache[SceneID]
  local Flag = Conf.id
  local bIsContain = false
  local StoryFlags = _G.DataModelMgr.PlayerDataModel:GetStoryFlags()
  local HomeOwnerFlags = _G.DataModelMgr.PlayerDataModel:GetHomeOwnerStoryFlags()
  if _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(Flag) then
    bIsContain = table.contains(StoryFlags, Flag)
  else
    bIsContain = table.contains(HomeOwnerFlags, Flag)
  end
  if bIsContain then
    return Conf
  end
  return nil
end

function StoryFlagModule:GetCurrentStoryBgmState()
  return self.TaskBGMState
end

function StoryFlagModule:RemoveStoryLevels()
  for i, v in ipairs(self.PlotLevelName) do
    UE4.UNRCStatics.ImmediateRemovePlotStreamingLevel(v)
  end
  table.clear(self.PlotLevelName)
end

function StoryFlagModule:ToggleAirWall(IDs, ResConf, Enable)
  if not IDs or #IDs < 2 then
    return
  end
  local Airwall = _G.NRCModuleManager:GetModule("AirWallModule")
  if not Airwall then
    return
  end
  local WallID = IDs[1] or 0
  local SceneRes = IDs[2] or 0
  if 0 == WallID or 0 == SceneRes then
    return
  end
  if Enable and ResConf.id == SceneRes then
    _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.CreateWall, WallID, false)
  else
    _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.DestroyWall, WallID)
  end
end

local SharedActorArray = UE.TArray(UE.AActor)

function StoryFlagModule:ToggleActorWithFlags(World, Tag, Enable)
  if not World then
    return
  end
  if string.IsNilOrEmpty(Tag) then
    return
  end
  local Cache = self.TagStateCache[Tag]
  if nil ~= Cache and Cache == Enable then
    Log.Debug("Skip tag", Tag, Enable)
    return
  end
  self.TagStateCache[Tag] = Enable
  UE.UGameplayStatics.GetAllActorsWithTag(World, Tag, SharedActorArray)
  if 0 == SharedActorArray:Length() then
    return
  end
  for _, Actor in tpairs(SharedActorArray) do
    if Actor:IsA(UE.AEnvSystemVolume) then
      Log.Debug("Toggle Volume", Tag, Enable)
      Actor.IsUsedVolume = Enable
      Actor.BlendWeight = Enable and 1 or 0
    else
    end
  end
  SharedActorArray:Clear()
end

function StoryFlagModule:TogglePreload(HasFlag, Flag)
  local List = StoryFlagPreloadLists[Flag]
  if not List then
    return
  end
  if HasFlag then
    for Key, Value in pairs(List) do
      if self.PreloadedRequests[Key] then
      else
        local Res = _G.NRCBigWorldPreloader:Get(Key)
        if Res then
        else
          local Req = _G.NRCResourceManager:LoadResAsync(self, Value, 100, 0, self.PreloadFinish, self.PreloadFailed)
          self.PreloadedRequests[Key] = Req
        end
      end
    end
  else
    for Key, _ in pairs(List) do
      local Req = self.PreloadedRequests[Key]
      if Req then
        _G.NRCResourceManager:UnLoadRes(Req)
        self.PreloadedRequests[Key] = nil
      end
      local Ref = self.PreloadedRefs[Key]
      if Ref then
        self.PreloadedRefs[Key] = nil
      end
    end
  end
end

function StoryFlagModule:PreloadFinish(req, asset)
  self.PreloadedRefs[req.assetPath] = asset and UnLua.Ref(asset)
  Log.Debug("storyflag\233\162\132\229\138\160\232\189\189\230\136\144\229\138\159", req.assetPath)
end

function StoryFlagModule:PreloadFailed(req, errMsg)
  Log.Error("\230\151\160\230\179\149\233\162\132\229\138\160\232\189\189", errMsg)
  _G.NRCResourceManager:UnLoadRes(req)
end

return StoryFlagModule
