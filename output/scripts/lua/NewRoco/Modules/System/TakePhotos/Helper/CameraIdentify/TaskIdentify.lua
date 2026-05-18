local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local TaskIdentify = Class("TaskIdentify")
local EnumIdentifyFlags = {
  GameTime = 1,
  Location = 2,
  Rotation = 4,
  FOV = 8,
  Targets = 16
}
local EnumIdentifyFlagsAllMask = EnumIdentifyFlags.GameTime | EnumIdentifyFlags.Location | EnumIdentifyFlags.Rotation | EnumIdentifyFlags.FOV | EnumIdentifyFlags.Targets

function TaskIdentify:Ctor(Proxy)
  self.IdentifyProxy = Proxy
  self.Panel = Proxy.Panel
  self.bTrackingCameraTask = false
  self.CameraOverlaps = UE.TArray(UE.AActor)
  self.CameraViewBoxExtent = UE.FVector(0, 0, 0)
  self.CameraViewBoxCenter = UE.FVector(0, 0, 0)
  self.CameraFOV = UE.FVector2D(0, 0)
  self.World = UE4Helper.GetCurrentWorld()
  self.MaxiTaskIdentifyDistance = TakePhotosEnum.TPGlobalNum("takephoto_identify_distance_max")
  self.CandidateList = {}
  self.CandidateNum = 0
  self.CaptureCandidateMap = {}
  self.IdentifyParam = {
    IdentifyStaticMeshList = {},
    MemberViews = {},
    AnyMembersViews = {},
    AnyPetViews = {},
    IdentifyFlags = 0,
    BackIdentifyFlags = 0
  }
  self.bHasClearVisibleCache = false
  self.TempCollectionOverlap = {}
  self.TempVisibleIgnoreList = {}
  self.TempVisibleFixIgnoreList = {}
  self.TempTaskObject = nil
  self.FreePetOutlines = {}
  self.AllPetOutlines = {}
  self.UsingPetOutlines = {}
  self.UsingOverlapToOutline = {}
  
  function self.SortCandidateOverlap(A, B)
    return self:OnSortCandidateOverlap(A, B)
  end
end

function TaskIdentify:GetPlayer()
  return self.IdentifyProxy.Player
end

function TaskIdentify:GetBaseFov()
  return self.Panel.CurrMode:GetBaseFov()
end

function TaskIdentify:OnDestroy()
  self.OutlineClass = nil
  self:DestroyOutlines()
end

function TaskIdentify:OnOutlineClassLoaded(OutlineClass)
  self.OutlineClass = OutlineClass
end

function TaskIdentify:TryStopTaskIdentify()
  self:ReleaseAllPetOutlines()
  self.IdentifyParam.BackIdentifyFlags = self.IdentifyParam.IdentifyFlags
  self.IdentifyParam.IdentifyFlags = 0
end

function TaskIdentify:CaptureCandidates()
  self.CaptureCandidateMap = {}
  for i = 1, self.CandidateNum do
    self.CaptureCandidateMap[self.CandidateList[i]] = true
  end
end

function TaskIdentify:CancelCandidates()
  self.CaptureCandidateMap = {}
end

function TaskIdentify:TryTaskIdentify()
  local Player = self:GetPlayer()
  if Player then
    local PlayerCameraManager = Player.viewObj:GetController().PlayerCameraManager
    local CameraLocation, CameraRotation, ViewInfo, IdentifyCameraFOV = NRCModuleManager:DoCmd(TakePhotosModuleCmd.GetIdentifyLookViewInfo)
    if not CameraLocation then
      self:TryStopTaskIdentify()
      return
    end
    self.ViewInfo = ViewInfo
    self.IdentifyCameraFOV = IdentifyCameraFOV
    self.PlayerCameraManager = PlayerCameraManager
    self.CameraLocation = CameraLocation
    self.CameraRotation = CameraRotation
    self.CameraForward = UE.UKismetMathLibrary.GetForwardVector(CameraRotation)
    self.PlayerController = Player:GetUEController()
    for k, v in pairs(self.UsingPetOutlines) do
      self.UsingPetOutlines[k] = false
    end
    self.IdentifyParam.BackIdentifyFlags = self.IdentifyParam.IdentifyFlags
    self.IdentifyParam.IdentifyFlags = 0
    local bTrackingCameraTask = self:CheckIdentifyByTrack()
    if not self.bTrackingCameraTask and bTrackingCameraTask then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.tkt_camera_error_1, nil, nil, 2)
    end
    self.bTrackingCameraTask = bTrackingCameraTask
    for k, v in pairs(self.UsingPetOutlines) do
      if not v then
        self:ReleasePetOutline(k)
        self.UsingPetOutlines[k] = nil
      end
    end
    if self.bTrackingCameraTask then
      self.Panel.VerticalBox_Task:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Panel.VerticalBox_Task:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    self.bHasClearVisibleCache = false
    return self.bTrackingCameraTask
  end
  return false
end

function TaskIdentify:GetTaskCameraCondition(TaskObject)
  local TaskConf = TaskObject.Config
  if not TaskConf then
    return nil, 0
  end
  local CameraCondition, ConditionIndex
  for i, Condition in ipairs(TaskConf.task_condition) do
    if Condition.type == Enum.TaskKeyType.TKT_CAMERA and not TaskObject:CheckConditionDone(i) then
      CameraCondition = Condition
      ConditionIndex = i
      break
    end
  end
  return CameraCondition, ConditionIndex
end

function TaskIdentify:ReplaceBestTaskCondition(BestTaskObject, BestConditionIndex, SubTask, ConditionIndex)
  if not BestConditionIndex then
    return true
  end
  local TrackerA = BestTaskObject:GetTracker(BestConditionIndex)
  local TrackerB = SubTask:GetTracker(ConditionIndex)
  if TrackerA and TrackerB and TrackerA.Valid and TrackerB.Valid then
    local PA = TrackerA:GetPosition()
    local PB = TrackerB:GetPosition()
    local SqrA = (PA - self.CameraLocation):SizeSquared()
    local SqrB = (PB - self.CameraLocation):SizeSquared()
    if SqrA > SqrB then
      return true
    end
  end
  return false
end

function TaskIdentify:SelectTaskConditionForIdentify()
  local TrackObject = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTrackTask)
  if not TrackObject then
    self.TempTaskObject = nil
    return false
  end
  local CameraCondition, ConditionIndex = self:GetTaskCameraCondition(TrackObject)
  local BestCondition = CameraCondition
  local BestTaskObject = TrackObject
  local BestConditionIndex = ConditionIndex
  local SubTasks = TrackObject.TrackSubTasks
  if SubTasks and #SubTasks > 0 then
    for i, SubTask in ipairs(SubTasks) do
      CameraCondition, ConditionIndex = self:GetTaskCameraCondition(SubTask)
      if CameraCondition and self:ReplaceBestTaskCondition(BestTaskObject, BestConditionIndex, SubTask, ConditionIndex) then
        BestCondition = CameraCondition
        BestTaskObject = SubTask
        BestConditionIndex = ConditionIndex
      end
    end
  end
  if not BestCondition then
    self.TempTaskObject = nil
    return false
  end
  local bChanged = BestTaskObject ~= self.TempTaskObject or BestConditionIndex ~= self.TempTaskConditionIndex or BestCondition ~= self.TempTaskCondition
  self.TempTaskObject = BestTaskObject
  self.TempTaskConditionIndex = BestConditionIndex
  self.TempTaskCondition = BestCondition
  return bChanged
end

function TaskIdentify:TryUploadCondition()
  if self.TempTaskObject and self.IdentifyParam.bIdentifySuccess then
    Log.Warning("UploadCameraCondition:", self.TempTaskObject.Config.id, self.TempTaskConditionIndex, self.TempTaskObject:GetDescText(self.TempTaskConditionIndex))
    if not self.IdentifyParam.bNeedShare then
      NRCModuleManager:DoCmd(TaskModuleCmd.TriggerTaskCondition, self.TempTaskObject.Config.id, self.TempTaskConditionIndex)
    end
  end
end

function TaskIdentify:GetTaskIdentifyInfo()
  if self.TempTaskObject and self.IdentifyParam.bIdentifySuccess then
    return {
      TaskObject = self.TempTaskObject,
      TaskConditionIndex = self.TempTaskConditionIndex,
      bNeedShare = self.IdentifyParam.bNeedShare
    }
  end
end

function TaskIdentify:OnShared(PhotoData)
  local TaskIdentifyInfo = PhotoData:GetTaskIdentifyInfo()
  if TaskIdentifyInfo then
    local TaskObject = TaskIdentifyInfo.TaskObject
    local TaskConditionIndex = TaskIdentifyInfo.TaskConditionIndex
    local bNeedShare = TaskIdentifyInfo.bNeedShare
    if bNeedShare then
      Log.Debug("[TakePhoto] OnShared Task", TaskObject.Config.id, TaskConditionIndex)
      NRCModuleManager:DoCmd(TaskModuleCmd.TriggerTaskCondition, TaskObject.Config.id, TaskConditionIndex)
    end
  end
end

function TaskIdentify:CheckIdentifyByTrack()
  local bNeedUpdateIdentifyParam = self:SelectTaskConditionForIdentify()
  if not self.TempTaskObject then
    return
  end
  if bNeedUpdateIdentifyParam then
    local CameraCondition = self.TempTaskCondition
    local Params1 = CameraCondition.data1
    local Params2 = CameraCondition.data2
    local Params3 = CameraCondition.data3
    local Params4 = CameraCondition.data4
    local Params5 = CameraCondition.data5
    self.IdentifyParam.bNeedShare = Params5 and 1 == math.tointeger(Params5)
    self.IdentifyParam.bEnableLineTrace = Params1 and Params1[1]
    if Params1 then
      local X = Params1[2]
      local Y = Params1[3]
      local Z = Params1[4]
      local RX = Params1[5]
      local RY = Params1[6]
      local RZ = Params1[7]
      local FOV = Params1[8]
      local r = Params1[9]
      local a = Params1[10]
      local f = Params1[11]
      local d = Params1[12]
      if X and Y and Z and (0 ~= X or 0 ~= Y or 0 ~= Y) then
        self.IdentifyParam.Location = UE.FVector(X, Y, Z)
      else
        self.IdentifyParam.Location = nil
      end
      if RX and RY and RZ and (0 ~= RX or 0 ~= RY or 0 ~= RZ) then
        self.IdentifyParam.Forward = UE.UKismetMathLibrary.GetForwardVector(UE.FRotator(RY, RZ, RX))
      else
        self.IdentifyParam.Forward = nil
      end
      self.IdentifyParam.FOV = FOV or 0
      self.IdentifyParam.FOVTolerance = f or 0
      self.IdentifyParam.DistanceTolerance = r or 0
      self.IdentifyParam.ForwardTolerance = a or 0
      self.IdentifyParam.IdentifyDistance = d and d > 0 and d or self.MaxiTaskIdentifyDistance
    else
      self.IdentifyParam.Location = nil
      self.IdentifyParam.Forward = nil
      self.IdentifyParam.FOV = 0
      self.IdentifyParam.FOVTolerance = 0
      self.IdentifyParam.DistanceTolerance = 0
      self.IdentifyParam.ForwardTolerance = 0
      self.IdentifyParam.IdentifyDistance = self.MaxiTaskIdentifyDistance
    end
    self.IdentifyParam.MembersRequire = 0
    self.IdentifyParam.AnyMembersRequire = 0
    self.IdentifyParam.AnyPetRequire = 0
    self.IdentifyParam.AnyPetNum = 0
    self.IdentifyParam.LeaderRequire = false
    self.IdentifyParam.ContentSet = {}
    self.IdentifyParam.ContentNums = {}
    self.IdentifyParam.ModelIdSet = {}
    self.IdentifyParam.ModelIdNums = {}
    self.IdentifyParam.NpcIdSet = {}
    self.IdentifyParam.NpcIdNums = {}
    self.IdentifyParam.IdentifyStaticMeshList = {}
    self.IdentifyParam.MemberViews = {}
    self.IdentifyParam.AnyMembersViews = {}
    self.IdentifyParam.AnyPetViews = {}
    local bHasNpcIdentify = false
    local bHasStaticMeshReq = Params4 and #Params4 > 0
    if Params2 then
      local i = 1
      while i < #Params2 do
        local Type, Id, Num = Params2[i], Params2[i + 1], Params2[i + 2]
        i = i + 3
        if 0 == Type then
          if -2 == Id then
            self.IdentifyParam.MembersRequire = self.IdentifyParam.MembersRequire + Num
          elseif -1 == Id then
            self.IdentifyParam.LeaderRequire = true
          elseif 0 == Id then
            self.IdentifyParam.AnyMembersRequire = self.IdentifyParam.AnyMembersRequire + Num
          end
        else
          bHasNpcIdentify = true
          if 1 == Type then
            self.IdentifyParam.NpcIdSet[Id] = (self.IdentifyParam.NpcIdSet[Id] or 0) + Num
          elseif 2 == Type then
            self.IdentifyParam.ContentSet[Id] = (self.IdentifyParam.ContentSet[Id] or 0) + Num
          elseif 3 == Type then
            self.IdentifyParam.ModelIdSet[Id] = (self.IdentifyParam.ModelIdSet[Id] or 0) + Num
          elseif 4 == Type then
            self.IdentifyParam.AnyPetRequire = self.IdentifyParam.AnyPetRequire + Num
          end
        end
      end
    end
    self.IdentifyParam.bHasNpcIdentify = bHasNpcIdentify
    if self.IdentifyParam.AnyMembersRequire > 0 then
      self.IdentifyParam.MembersRequire = 0
      self.IdentifyParam.LeaderRequire = false
    end
    if self.IdentifyParam.AnyPetRequire > 0 then
      self.IdentifyParam.ContentSet = {}
      self.IdentifyParam.ModelIdSet = {}
      self.IdentifyParam.NpcIdSet = {}
    end
    if Params3 then
      if #Params3 >= 3 then
        self.IdentifyParam.GameTime = {
          Params3[1],
          Params3[2],
          Params3[3]
        }
        self.IdentifyParam.GameTimeTolerance = {
          Params3[4],
          Params3[5],
          Params3[6]
        }
      else
        self.IdentifyParam.GameTime = nil
        self.IdentifyParam.GameTimeTolerance = nil
      end
    else
      self.IdentifyParam.GameTime = nil
      self.IdentifyParam.GameTimeTolerance = nil
    end
    if bHasStaticMeshReq then
      local Params4SubParamList = string.split(Params4, ";")
      self.IdentifyParam.StaticMeshRequire = math.tointeger(Params4SubParamList[1])
      self.IdentifyParam.StaticMeshReference = Params4SubParamList[2]
      self.IdentifyParam.StaticMeshAimOffset = UE.FVector(tonumber(Params4SubParamList[3]) or 0, tonumber(Params4SubParamList[4]) or 0, tonumber(Params4SubParamList[5]) or 0)
      local Scale = tonumber(Params4SubParamList[6]) or 1
      self.IdentifyParam.StaticMeshAimScale = Scale
    else
      self.IdentifyParam.StaticMeshRequire = nil
      self.IdentifyParam.StaticMeshReference = nil
      self.IdentifyParam.StaticMeshAimOffset = nil
      self.IdentifyParam.StaticMeshAimScale = 1
    end
    self.IdentifyParam.bEnableTargetCheck = self.IdentifyParam.StaticMeshRequire or self.IdentifyParam.LeaderRequire or self.IdentifyParam.MembersRequire > 0 or self.IdentifyParam.bHasNpcIdentify or self.IdentifyParam.AnyMembersRequire > 0
    self:InitUI()
  end
  if self.TempTaskObject:CheckConditionDone(self.TempTaskConditionIndex) then
    return false
  end
  if not self.IdentifyParam.GameTime or self:CheckIdentifyByTime() then
    self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.GameTime
  end
  self:CheckIdentifyByParams()
  if not self.IdentifyParam.bEnableTargetCheck or self:CheckIdentifyByTargets() then
    self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.Targets
  end
  self.IdentifyParam.bIdentifySuccess = self.IdentifyParam.IdentifyFlags == EnumIdentifyFlagsAllMask
  self:UpdateUI()
  return true
end

function TaskIdentify:GetIdentifyDistance()
  return DEBUG_TASK_IDENTIFY_DIST or self.IdentifyParam.IdentifyDistance
end

function TaskIdentify:InitUI()
  local ItemDataList = {}
  self.FlagToIdentifyUIIndices = {}
  self.FlagToParamParsers = {}
  if self.IdentifyParam.GameTime then
    table.insert(ItemDataList, {
      EnableDesc = LuaText.tkt_camera_param_t1,
      DisableDesc = LuaText.tkt_camera_param_f1
    })
    self.FlagToIdentifyUIIndices[EnumIdentifyFlags.GameTime] = #ItemDataList
  end
  if self.IdentifyParam.Location then
    table.insert(ItemDataList, {
      EnableDesc = LuaText.tkt_camera_param_t2,
      DisableDesc = LuaText.tkt_camera_param_f2
    })
    self.FlagToIdentifyUIIndices[EnumIdentifyFlags.Location] = #ItemDataList
  end
  if self.IdentifyParam.Forward then
    table.insert(ItemDataList, {
      EnableDesc = LuaText.tkt_camera_param_t3,
      DisableDesc = LuaText.tkt_camera_param_f3
    })
    self.FlagToIdentifyUIIndices[EnumIdentifyFlags.Rotation] = #ItemDataList
  end
  if (self.IdentifyParam.FOV or 0) > 0 then
    table.insert(ItemDataList, {
      EnableDesc = LuaText.tkt_camera_param_t4,
      DisableDesc = LuaText.tkt_camera_param_f4
    })
    self.FlagToIdentifyUIIndices[EnumIdentifyFlags.FOV] = #ItemDataList
  end
  if self.IdentifyParam.bEnableTargetCheck then
    table.insert(ItemDataList, {
      EnableDesc = LuaText.tkt_camera_param_t5,
      DisableDesc = LuaText.tkt_camera_param_f5
    })
    self.FlagToIdentifyUIIndices[EnumIdentifyFlags.Targets] = #ItemDataList
    self.FlagToParamParsers[EnumIdentifyFlags.Targets] = function(bEnable)
      local IdentifyDistance = self:GetIdentifyDistance()
      local Scale = self.IdentifyCameraFOV / self:GetBaseFov()
      IdentifyDistance = IdentifyDistance / Scale
      return math.tointeger(IdentifyDistance // 100)
    end
  end
  local Desc = self.TempTaskObject:GetDescText(self.TempTaskConditionIndex)
  self.Panel.TxtTaskDesc:SetText(Desc)
  self.Panel.StateIcon:SetPath(TaskUtils.GetTaskStateIcon(self.TempTaskObject))
  if _G.RocoEnv.IS_EDITOR then
    table.insert(ItemDataList, {})
    self.FlagToIdentifyUIIndices[-1] = #ItemDataList
  end
  local ListView = self.Panel.List
  ListView:InitGridView(ItemDataList)
end

function TaskIdentify:UpdateUI()
  if self.IdentifyParam.BackIdentifyFlags ~= self.IdentifyParam.IdentifyFlags then
    local ListView = self.Panel.List
    for Flag, UIIndex in pairs(self.FlagToIdentifyUIIndices) do
      if -1 ~= Flag then
        local Enable = 0 ~= self.IdentifyParam.IdentifyFlags & Flag
        local UIItem = ListView:GetItemByIndex(UIIndex - 1)
        if UIItem then
          local Parser = self.FlagToParamParsers[Flag]
          if Parser then
            UIItem:SetCheckEnabled(Enable, Parser(Enable))
          else
            UIItem:SetCheckEnabled(Enable)
          end
        end
      end
    end
  elseif self.IdentifyParam.bEnableTargetCheck then
    local ListView = self.Panel.List
    local Flag = EnumIdentifyFlags.Targets
    local UIIndex = self.FlagToIdentifyUIIndices[Flag]
    local Enable = 0 ~= self.IdentifyParam.IdentifyFlags & Flag
    local UIItem = ListView:GetItemByIndex(UIIndex - 1)
    if UIItem then
      local Parser = self.FlagToParamParsers[Flag]
      if Parser then
        UIItem:SetCheckEnabled(Enable, Parser(Enable))
      else
        UIItem:SetCheckEnabled(Enable)
      end
    end
  end
  if _G.RocoEnv.IS_EDITOR then
    local ListView = self.Panel.List
    local UIIndex = self.FlagToIdentifyUIIndices[-1]
    if UIIndex then
      local UIItem = ListView:GetItemByIndex(UIIndex - 1)
      local Tracker = self.TempTaskObject:GetTracker(self.TempTaskConditionIndex)
      local Pos = Tracker and Tracker:GetPosition()
      Pos = Pos or self.IdentifyParam.Location
      if Pos and not DISABLE_TKT_CAMERA_DEBUG then
        local Dis = (Pos - self.CameraLocation):Size()
        local Time = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
        local H = Time // 3600
        local M = (Time - H * 3600) // 60
        local IdentifyDistance = self:GetIdentifyDistance()
        local Scale = self.IdentifyCameraFOV / self:GetBaseFov()
        IdentifyDistance = IdentifyDistance / Scale
        UIItem.GoalText:SetText(string.format("[\231\188\150\232\190\145\229\153\168]\232\183\157\231\166\187:%d \228\189\141\231\189\174:(%d,%d,%d) \230\156\157\229\144\145:(%d,%d,%d) FOV:%d Time:%02d,%02d \233\149\156\229\164\180:%d\231\177\179", math.floor(Dis + 0.5), math.floor(self.CameraLocation.X), math.floor(self.CameraLocation.Y), math.floor(self.CameraLocation.Z), math.floor(self.CameraRotation.Roll), math.floor(self.CameraRotation.Pitch), math.floor(self.CameraRotation.Yaw), math.floor(self.IdentifyCameraFOV), H, M, IdentifyDistance // 100))
        UIItem:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      else
        UIItem:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
  end
end

function TaskIdentify:CheckIdentifyByTime()
  local GameTimeTolerance = self.IdentifyParam.GameTimeTolerance
  local GameTime = self.IdentifyParam.GameTime
  local H = GameTime[1]
  local M = GameTime[2]
  local S = GameTime[3]
  local TimeStamp = H * 3600 + M * 60 + S
  local TH = GameTimeTolerance[1]
  local TM = GameTimeTolerance[2]
  local TS = GameTimeTolerance[3]
  local Duration = 0
  if TH then
    Duration = Duration + TH * 3600
  end
  if TM then
    Duration = Duration + TM * 60
  end
  if TS then
    Duration = Duration + TS
  end
  local Time = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
  if Duration >= math.abs(Time - TimeStamp) then
    return true
  end
  return false
end

function TaskIdentify:CheckIdentifyByParams()
  local Location = self.IdentifyParam.Location
  local DisTolerance = self.IdentifyParam.DistanceTolerance
  local Forward = self.IdentifyParam.Forward
  local AngleTolerance = self.IdentifyParam.ForwardTolerance
  local Fov = self.IdentifyParam.FOV
  local FovTolerance = self.IdentifyParam.FOVTolerance
  local CameraLocation = self.CameraLocation
  local CameraForward = self.CameraForward
  local PlayerCameraManager = self.PlayerCameraManager
  if Location then
    local DisDelta = (CameraLocation - Location):Size()
    if DisTolerance >= DisDelta then
      self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.Location
    end
  else
    self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.Location
  end
  if Forward then
    local CosDelta = CameraForward:Dot(Forward)
    if CosDelta >= math.cos(math.rad(AngleTolerance)) then
      self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.Rotation
    end
  else
    self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.Rotation
  end
  if Fov and 0 ~= Fov then
    local FovDelta = math.abs(PlayerCameraManager.FOV - Fov)
    if FovTolerance >= FovDelta then
      self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.FOV
    end
  else
    self.IdentifyParam.IdentifyFlags = self.IdentifyParam.IdentifyFlags | EnumIdentifyFlags.FOV
  end
end

function TaskIdentify:BoxOverlapMultiByChannel()
  UE.UNRCStatics.BoxOverlapMultiByChannel(self.World, self.CameraRotation:ToQuat(), self.CameraOverlaps, self.CameraViewBoxCenter, self.CameraViewBoxExtent, UE.ECollisionChannel.ECC_Camera)
end

function TaskIdentify:CheckIdentifyByTargets()
  local IdentifyDistance = self:GetIdentifyDistance()
  local Scale = self.IdentifyCameraFOV / self:GetBaseFov()
  local WorldOriginal = UE.FVector(self.World:GetWorldOriginX(), self.World:GetWorldOriginY(), self.World:GetWorldOriginZ())
  IdentifyDistance = IdentifyDistance / Scale / 2
  if UE.UNRCStatics.GetFrustumBoundingExtent(self.ViewInfo, 0, IdentifyDistance, self.CameraViewBoxExtent, self.CameraFOV) then
    self.CameraViewBoxCenter = self.CameraLocation + self.CameraForward * IdentifyDistance - WorldOriginal
  else
    return
  end
  self.CameraOverlaps:Clear()
  self.CandidateNum = 0
  self:BoxOverlapMultiByChannel()
  for i, Overlap in tpairs(self.CameraOverlaps) do
    if not Overlap.bHidden and (self.CaptureCandidateMap[Overlap] or Overlap:WasRecentlyRendered(0.2)) then
      local IdentifyPos = Overlap:Abs_K2_GetActorLocation()
      if self.IdentifyParam.StaticMeshAimOffset and Overlap:GetComponentByClass(UE.UStaticMeshComponent) then
        IdentifyPos = IdentifyPos + self.IdentifyParam.StaticMeshAimOffset
      end
      local bInView = UE.UNRCStatics.IsPointInCustomFrustumVolume(IdentifyPos - WorldOriginal, self.ViewInfo)
      if bInView then
        self.CandidateNum = self.CandidateNum + 1
        self.CandidateList[self.CandidateNum] = Overlap
      end
    end
  end
  self.CameraOverlaps:Clear()
  UE.UNRCStatics.BoxOverlapMultiByObjectType(self.World, self.CameraRotation:ToQuat(), self.CameraOverlaps, self.CameraViewBoxCenter, self.CameraViewBoxExtent, UE.EObjectTypeQuery.Character)
  for i, Overlap in tpairs(self.CameraOverlaps) do
    if Overlap.sceneCharacter and Overlap.sceneCharacter.GetLogicId then
      local IdentifyPos = Overlap:Abs_K2_GetActorLocation()
      local bInView = UE.UNRCStatics.IsPointInCustomFrustumVolume(IdentifyPos - WorldOriginal, self.ViewInfo)
      if bInView then
        self.CandidateNum = self.CandidateNum + 1
        self.CandidateList[self.CandidateNum] = Overlap
      end
    end
  end
  local bIdentifyStaticMeshSuc = not self.IdentifyParam.StaticMeshRequire or self:InternalIdentifyStaticMesh()
  local bDynamicIdentifySuc = self:InternalIdentifyCandidate(self.CandidateList, self.CandidateNum)
  return bIdentifyStaticMeshSuc and bDynamicIdentifySuc
end

function TaskIdentify:InternalIdentifyCandidate(CandidateList, CandidateNum)
  local ContentSet = self.IdentifyParam.ContentSet
  local ContentNums = self.IdentifyParam.ContentNums
  local ModelIdSet = self.IdentifyParam.ModelIdSet
  local ModelIdNums = self.IdentifyParam.ModelIdNums
  local NpcIdSet = self.IdentifyParam.NpcIdSet
  local NpcIdNums = self.IdentifyParam.NpcIdNums
  local bNeedSortOverlaps = false
  local bNeedCollectMembers = false
  local bNeedCollectAnyMembers = false
  local bNeedSortAnyPets = false
  for k, v in pairs(ContentNums) do
    ContentNums[k] = 0
  end
  for k, v in pairs(ModelIdNums) do
    ModelIdNums[k] = 0
  end
  for k, v in pairs(NpcIdNums) do
    NpcIdNums[k] = 0
  end
  local MembersRequire = self.IdentifyParam.MembersRequire
  local AnyMembersRequire = self.IdentifyParam.AnyMembersRequire
  local LeaderRequire = self.IdentifyParam.LeaderRequire
  local LocalUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local LeaderUin = LocalUin
  local Collection = self.TempCollectionOverlap
  if Collection and next(Collection) then
    table.clear(Collection)
  end
  if MembersRequire > 0 then
    self.IdentifyParam.MemberViewNum = 0
  end
  if AnyMembersRequire > 0 then
    self.IdentifyParam.AnyMemberNum = 0
  end
  if LeaderRequire then
    self.IdentifyParam.LeaderView = nil
  end
  local AnyPetRequire = self.IdentifyParam.AnyPetRequire
  if AnyPetRequire > 0 then
    self.IdentifyParam.AnyPetNum = 0
  end
  for i = 1, CandidateNum do
    local Overlap = CandidateList[i]
    local SceneCharacter = Overlap.sceneCharacter
    if AnyPetRequire > 0 then
      local isPet = SceneCharacter and SceneCharacter.IsPet and SceneCharacter:IsPet()
      if isPet then
        table.insert(Collection, Overlap)
        self.IdentifyParam.AnyPetNum = self.IdentifyParam.AnyPetNum + 1
        if self.IdentifyParam.AnyPetNum > self.IdentifyParam.AnyPetRequire then
          bNeedSortOverlaps = true
          bNeedSortAnyPets = true
        end
    end
    elseif (ModelIdSet or ContentSet or NpcIdSet) and SceneCharacter and SceneCharacter.config then
      if NpcIdSet then
        local NpcId = SceneCharacter and SceneCharacter.config and SceneCharacter.config.id
        if NpcId and NpcIdSet[NpcId] then
          NpcIdNums[NpcId] = (NpcIdNums[NpcId] or 0) + 1
          table.insert(Collection, Overlap)
          if NpcIdNums[NpcId] > NpcIdSet[NpcId] then
            bNeedSortOverlaps = true
          end
      end
      else
        if ContentSet then
          local ContentId = SceneCharacter.serverData.npc_base.npc_content_cfg_id
          if ContentId and ContentSet[ContentId] then
            ContentNums[ContentId] = (ContentNums[ContentId] or 0) + 1
            table.insert(Collection, Overlap)
            if ContentNums[ContentId] > ContentSet[ContentId] then
              bNeedSortOverlaps = true
            end
        end
        else
          if ModelIdSet then
            local ModelId = SceneCharacter and SceneCharacter.config and SceneCharacter.config.model_conf
            if ModelId and ModelIdSet[ModelId] then
              ModelIdNums[ModelId] = (ModelIdNums[ModelId] or 0) + 1
              table.insert(Collection, Overlap)
              if ModelIdNums[ModelId] > ModelIdSet[ModelId] then
                bNeedSortOverlaps = true
              end
          end
          elseif SceneCharacter and SceneCharacter.GetLogicId then
            local Uin = SceneCharacter:GetLogicId()
            if 0 ~= Uin then
              local bInCollection = false
              if LeaderRequire and Uin == LeaderUin then
                self.IdentifyParam.LeaderView = Overlap
                bInCollection = true
                table.insert(Collection, Overlap)
              end
              if MembersRequire > 0 and Uin ~= LocalUin then
                if not bInCollection then
                  bInCollection = true
                  table.insert(Collection, Overlap)
                end
                self.IdentifyParam.MemberViewNum = self.IdentifyParam.MemberViewNum + 1
                self.IdentifyParam.MemberViews[self.IdentifyParam.MemberViewNum] = Overlap
                if self.IdentifyParam.MemberViewNum > self.IdentifyParam.MembersRequire then
                  bNeedSortOverlaps = true
                  bNeedCollectMembers = true
                end
              end
              if AnyMembersRequire > 0 then
                if not bInCollection then
                  bInCollection = true
                  table.insert(Collection, Overlap)
                end
                self.IdentifyParam.AnyMemberNum = self.IdentifyParam.AnyMemberNum + 1
                self.IdentifyParam.AnyMembersViews[self.IdentifyParam.AnyMemberNum] = Overlap
                if self.IdentifyParam.AnyMemberNum > self.IdentifyParam.AnyMembersRequire then
                  bNeedSortOverlaps = true
                  bNeedCollectAnyMembers = true
                end
              end
            end
          end
        end
      end
    end
  end
  local bContentNumSuc = true
  if bContentNumSuc then
    for id, num in pairs(ContentSet) do
      local Num = ContentNums[id] or 0
      if num > Num then
        bContentNumSuc = false
        break
      end
    end
  end
  local bModelNumSuc = true
  if bModelNumSuc then
    for id, num in pairs(ModelIdSet) do
      local Num = ModelIdNums[id] or 0
      if num > Num then
        bModelNumSuc = false
        break
      end
    end
  end
  local bNpcIdNumSuc = true
  if bNpcIdNumSuc then
    for id, num in pairs(NpcIdSet) do
      local Num = NpcIdNums[id] or 0
      if num > Num then
        bNpcIdNumSuc = false
        break
      end
    end
  end
  local bIdentifyNumSuccess = bContentNumSuc and bModelNumSuc and bNpcIdNumSuc and (not LeaderRequire or self.IdentifyParam.LeaderView) and (not MembersRequire or 0 == MembersRequire or MembersRequire <= self.IdentifyParam.MemberViewNum) and (not AnyMembersRequire or 0 == AnyMembersRequire or AnyMembersRequire <= self.IdentifyParam.AnyMemberNum) and (not AnyPetRequire or 0 == AnyPetRequire or AnyPetRequire <= self.IdentifyParam.AnyPetNum)
  if bNeedSortOverlaps then
    table.sort(Collection, self.SortCandidateOverlap)
    if bNeedCollectMembers then
      self.IdentifyParam.MemberViewNum = 0
    end
    if bNeedCollectAnyMembers then
      self.IdentifyParam.AnyMemberNum = 0
    end
    if bNeedSortAnyPets then
      self.IdentifyParam.AnyPetNum = 0
    end
  end
  for k, v in pairs(ContentNums) do
    ContentNums[k] = nil
  end
  for k, v in pairs(ModelIdNums) do
    ModelIdNums[k] = nil
  end
  for k, v in pairs(NpcIdNums) do
    NpcIdNums[k] = nil
  end
  for i, Overlap in ipairs(Collection) do
    local config = Overlap.sceneCharacter.config
    if config then
      if AnyPetRequire > 0 and Overlap.sceneCharacter.IsPet and Overlap.sceneCharacter:IsPet() then
        if bNeedSortAnyPets then
          self.IdentifyParam.AnyPetNum = self.IdentifyParam.AnyPetNum + 1
          self.IdentifyParam.AnyPetViews[self.IdentifyParam.AnyPetNum] = Overlap
        end
      else
        local NpcId = Overlap.sceneCharacter.config.id
        local ModelId = Overlap.sceneCharacter.config.model_conf
        local ContentId = Overlap.sceneCharacter.serverData.npc_base.npc_content_cfg_id
        if NpcIdSet and NpcIdSet[NpcId] then
          if not NpcIdNums[NpcId] then
            NpcIdNums[NpcId] = {}
          end
          table.insert(NpcIdNums[NpcId], Overlap)
        elseif ContentSet and ContentSet[ContentId] then
          if not ContentNums[ContentId] then
            ContentNums[ContentId] = {}
          end
          table.insert(ContentNums[ContentId], Overlap)
        elseif ModelIdSet and ModelIdSet[ModelId] then
          if not ModelIdNums[ModelId] then
            ModelIdNums[ModelId] = {}
          end
          table.insert(ModelIdNums[ModelId], Overlap)
        end
      end
    else
      if bNeedCollectMembers then
        local Uin = Overlap.sceneCharacter:GetLogicId()
        if Uin ~= LocalUin then
          self.IdentifyParam.MemberViewNum = self.IdentifyParam.MemberViewNum + 1
          self.IdentifyParam.MemberViews[self.IdentifyParam.MemberViewNum] = Overlap
        end
      end
      if bNeedCollectAnyMembers then
        self.IdentifyParam.AnyMemberNum = self.IdentifyParam.AnyMemberNum + 1
        self.IdentifyParam.AnyMembersViews[self.IdentifyParam.AnyMemberNum] = Overlap
      end
    end
  end
  local bEnableLineTrace = self.IdentifyParam.bEnableLineTrace
  if bEnableLineTrace then
    if AnyPetRequire > 0 then
      local bSuc, Num = self:FilterVisibleList(self.IdentifyParam.AnyPetViews, self.IdentifyParam.AnyPetNum, self.IdentifyParam.AnyPetRequire)
      if not bSuc then
        bIdentifyNumSuccess = false
      end
      for i = 1, Num do
        self:InternalApplyNpcOutline(self.IdentifyParam.AnyPetViews[i])
      end
    else
      for k, v in pairs(NpcIdNums) do
        local bSuc, Num = self:FilterVisibleList(v, #v, NpcIdSet[k])
        if not bSuc then
          bIdentifyNumSuccess = false
        end
        for i = 1, Num do
          self:InternalApplyNpcOutline(v[i])
        end
      end
      for k, v in pairs(ContentNums) do
        local bSuc, Num = self:FilterVisibleList(v, #v, ContentSet[k])
        if not bSuc then
          bIdentifyNumSuccess = false
        end
        for i = 1, Num do
          self:InternalApplyNpcOutline(v[i])
        end
      end
      for k, v in pairs(ModelIdNums) do
        local bSuc, Num = self:FilterVisibleList(v, #v, ModelIdSet[k])
        if not bSuc then
          bIdentifyNumSuccess = false
        end
        for i = 1, Num do
          self:InternalApplyNpcOutline(v[i])
        end
      end
    end
    if AnyMembersRequire > 0 then
      local bSuc, Num = self:FilterVisibleList(self.IdentifyParam.AnyMembersViews, self.IdentifyParam.AnyMemberNum, self.IdentifyParam.AnyMembersRequire)
      if not bSuc then
        bIdentifyNumSuccess = false
      end
      for i = 1, Num do
        self:InternalApplyPlayerOutline(self.IdentifyParam.AnyMembersViews[i])
      end
    elseif MembersRequire > 0 then
      local bSuc, Num = self:FilterVisibleList(self.IdentifyParam.MemberViews, self.IdentifyParam.MemberViewNum, self.IdentifyParam.MembersRequire)
      if not bSuc then
        bIdentifyNumSuccess = false
      end
      for i = 1, Num do
        self:InternalApplyPlayerOutline(self.IdentifyParam.MemberViews[i])
      end
    end
  else
    if AnyPetRequire > 0 then
      local Num = math.min(self.IdentifyParam.AnyPetRequire, self.IdentifyParam.AnyPetNum)
      for i = 1, Num do
        self:InternalApplyNpcOutline(self.IdentifyParam.AnyPetViews[i])
      end
    else
      for k, v in pairs(NpcIdNums) do
        local Num = math.min(NpcIdSet[k], #v)
        for i = 1, Num do
          self:InternalApplyNpcOutline(v[i])
        end
      end
      for k, v in pairs(ContentNums) do
        local Num = math.min(ContentSet[k], #v)
        for i = 1, Num do
          self:InternalApplyNpcOutline(v[i])
        end
      end
      for k, v in pairs(ModelIdNums) do
        local Num = math.min(ModelIdSet[k], #v)
        for i = 1, Num do
          self:InternalApplyNpcOutline(v[i])
        end
      end
    end
    if AnyMembersRequire > 0 then
      local Num = math.min(self.IdentifyParam.AnyMemberNum, AnyMembersRequire)
      for i = 1, Num do
        self:InternalApplyPlayerOutline(self.IdentifyParam.AnyMembersViews[i])
      end
    elseif MembersRequire > 0 then
      local Num = math.min(self.IdentifyParam.MemberViewNum, MembersRequire)
      for i = 1, Num do
        self:InternalApplyPlayerOutline(self.IdentifyParam.MemberViews[i])
      end
    end
  end
  if 0 == AnyMembersRequire and self.IdentifyParam.LeaderView then
    self:InternalApplyPlayerOutline(self.IdentifyParam.LeaderView)
  end
  return bIdentifyNumSuccess
end

function TaskIdentify:FilterVisibleList(OverlapList, LoopLength, RequireNum, IdentifyOffset)
  if not self.bHasClearVisibleCache then
    self.bHasClearVisibleCache = true
    if next(self.TempVisibleFixIgnoreList) then
      table.clear(self.TempVisibleFixIgnoreList)
    end
    if next(self.TempVisibleIgnoreList) then
      table.clear(self.TempVisibleIgnoreList)
    end
  end
  local VisibleNum = 0
  local LoopIndex = 1
  local ListView = OverlapList
  local SkipIndex = 1
  while LoopLength >= LoopIndex do
    local Overlap = ListView[LoopIndex]
    local IdentifyPos = Overlap:Abs_K2_GetActorLocation()
    if IdentifyOffset then
      IdentifyPos = IdentifyPos + IdentifyOffset
    end
    if self:IsVisibleByPoint(IdentifyPos, self:AllocateVisibleIgnoreList(Overlap)) then
      if LoopIndex ~= SkipIndex then
        ListView[SkipIndex] = Overlap
      end
      VisibleNum = VisibleNum + 1
      if VisibleNum == RequireNum then
        break
      end
      LoopIndex = LoopIndex + 1
      SkipIndex = SkipIndex + 1
    else
      LoopIndex = LoopIndex + 1
    end
  end
  if VisibleNum == RequireNum then
    return true, VisibleNum
  end
  return false, VisibleNum
end

function TaskIdentify:OnSortCandidateOverlap(A, B)
  local VA = A:Abs_K2_GetActorLocation() - self.CameraLocation
  local VB = B:Abs_K2_GetActorLocation() - self.CameraLocation
  local DisA = VA:Size()
  local DisB = VB:Size()
  local WeightA = VA:Dot(self.CameraForward) / DisA
  local WeightB = VB:Dot(self.CameraForward) / DisB
  return WeightA > WeightB
end

function TaskIdentify:InternalIdentifyStaticMesh()
  local StaticMeshReference = self.IdentifyParam.StaticMeshReference
  local IdentifyStaticMeshList = self.IdentifyParam.IdentifyStaticMeshList
  if #IdentifyStaticMeshList > 0 then
    table.clear(IdentifyStaticMeshList)
  end
  assert(0 == #IdentifyStaticMeshList)
  for i = 1, self.CandidateNum do
    local Overlap = self.CandidateList[i]
    local MeshComponent = Overlap:GetComponentByClass(UE.UStaticMeshComponent)
    if MeshComponent then
      local StaticMesh = MeshComponent.StaticMesh
      if StaticMesh and StaticMesh:GetName() == StaticMeshReference then
        table.insert(IdentifyStaticMeshList, Overlap)
      end
    end
  end
  if #IdentifyStaticMeshList > self.IdentifyParam.StaticMeshRequire then
    table.sort(IdentifyStaticMeshList, self.SortCandidateOverlap)
  end
  local bSuc, Num = self:FilterVisibleList(IdentifyStaticMeshList, #IdentifyStaticMeshList, self.IdentifyParam.StaticMeshRequire, self.IdentifyParam.StaticMeshAimOffset)
  for i = 1, Num do
    self:InternalApplyStaticMeshOutline(IdentifyStaticMeshList[i])
  end
  return bSuc
end

function TaskIdentify:AllocateVisibleIgnoreList(Overlap)
  if not next(self.TempVisibleFixIgnoreList) and self.Panel and self.Panel.CurrMode and self.Panel.CurrMode.Mgr:Is1PMode() then
    local player = self:GetPlayer()
    table.insert(self.TempVisibleFixIgnoreList, player.viewObj)
    if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
      local Pet = player.viewObj.BP_RideComponent.RidePet
      if Pet then
        table.insert(self.TempVisibleFixIgnoreList, Pet)
      end
    end
  end
  for i, v in ipairs(self.TempVisibleFixIgnoreList) do
    self.TempVisibleIgnoreList[i] = v
  end
  self.TempVisibleIgnoreList[#self.TempVisibleFixIgnoreList + 1] = Overlap
  assert(#self.TempVisibleIgnoreList == #self.TempVisibleFixIgnoreList + 1, "logical error")
  return self.TempVisibleIgnoreList
end

function TaskIdentify:IsVisibleByPoint(Point, Ignores, Offset)
  local TargetLocation = Point
  local CameraLocation = self.CameraLocation
  local TargetHitResult, bTargetHit = UE.UKismetSystemLibrary.Abs_LineTraceSingle(self.World, Offset and TargetLocation + Offset or TargetLocation, CameraLocation, UE.ETraceTypeQuery.Visibility, false, Ignores, UE4.EDrawDebugTrace.None, nil, true, UE4.FLinearColor.Red, UE4.FLinearColor.Green, 0.1)
  if bTargetHit then
    return false
  end
  return true
end

function TaskIdentify:CanDisplayOutline()
  return self.IdentifyProxy:CanDisplayOutline()
end

function TaskIdentify:InternalApplyPlayerOutline(Overlap)
  if not self:CanDisplayOutline() then
    return
  end
  local PetOutline = self:AllocatePetOutline(Overlap)
  if PetOutline then
    PetOutline:SetOutlineEnabled(true, Overlap, 1)
  end
end

function TaskIdentify:InternalApplyNpcOutline(Overlap)
  if not self:CanDisplayOutline() then
    return
  end
  local PetOutline = self:AllocatePetOutline(Overlap)
  if PetOutline then
    PetOutline:SetOutlineEnabled(true, Overlap)
  end
end

function TaskIdentify:InternalApplyStaticMeshOutline(Overlap)
  if not self:CanDisplayOutline() then
    return
  end
  local PetOutline = self:AllocatePetOutline(Overlap)
  if PetOutline then
    local Offset = self.IdentifyParam.StaticMeshAimOffset
    local Scale = self.IdentifyParam.StaticMeshAimScale
    if DEBUG_STATIC_IDENTIFY_HEIGHT then
      Offset = UE.FVector(Offset.X, Offset.Y, DEBUG_STATIC_IDENTIFY_HEIGHT)
    end
    PetOutline:SetOutlineEnabled(true, Overlap, 2, Offset, Scale)
  end
end

function TaskIdentify:AllocatePetOutline(Overlap)
  if not self.FreePetOutlines then
    return
  end
  if not self.OutlineClass then
    return
  end
  local PetOutline = self.UsingOverlapToOutline[Overlap]
  if PetOutline then
    self.UsingPetOutlines[PetOutline] = true
    return PetOutline
  end
  if #self.FreePetOutlines > 0 then
    PetOutline = table.remove(self.FreePetOutlines)
  else
    PetOutline = self.World:SpawnActor(self.OutlineClass, UE.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    PetOutline:SetOutlineEnabled(false)
    PetOutline:SetActorEnableCollision(false)
    table.insert(self.AllPetOutlines, PetOutline)
  end
  self.UsingPetOutlines[PetOutline] = true
  self.UsingOverlapToOutline[Overlap] = PetOutline
  return PetOutline
end

function TaskIdentify:ReleasePetOutline(PetOutline)
  if not PetOutline._Parent then
    Log.Error("logical error!!!")
    return
  end
  table.insert(self.FreePetOutlines, PetOutline)
  self.UsingPetOutlines[PetOutline] = false
  self.UsingOverlapToOutline[PetOutline._Parent] = nil
  PetOutline:SetOutlineEnabled(false)
  PetOutline:RemoveFromParent()
end

function TaskIdentify:ReleaseAllPetOutlines()
  self.UsingOverlapToOutline = {}
  for PetOutline, bUsing in pairs(self.UsingPetOutlines) do
    if bUsing then
      self:ReleasePetOutline(PetOutline)
    end
  end
  self.UsingPetOutlines = {}
end

function TaskIdentify:DestroyOutlines()
  self.FreePetOutlines = nil
  for i, PetOutline in pairs(self.AllPetOutlines) do
    if UE.UObject.IsValid(PetOutline) then
      PetOutline:K2_DestroyActor()
    end
  end
  self.AllPetOutlines = nil
  self.UsingPetOutlines = nil
  self.UsingOverlapToOutline = nil
end

return TaskIdentify
