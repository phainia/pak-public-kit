local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local DebugTabNPCPressure = Base:Extend("DebugTabNPCPressure")

function DebugTabNPCPressure:Ctor()
  Base.Ctor(self)
end

function DebugTabNPCPressure:SetupTabs()
  self:Add("\230\150\176\229\162\158\229\164\154\228\186\186\229\144\140\229\177\143\229\142\139\229\138\155\230\181\139\232\175\149(10\228\186\186)", self.AvatarMergeTestStart10, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\150\176\229\162\158\229\164\154\228\186\186\229\144\140\229\177\143\229\142\139\229\138\155\230\181\139\232\175\149(20\228\186\186)", self.AvatarMergeTestStart20, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\164\154\228\186\186\229\144\140\229\177\143\229\142\139\229\138\155\230\181\139\232\175\149\230\154\130\229\129\156", self.AvatarMergeTestPause, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\164\154\228\186\186\229\144\140\229\177\143\229\142\139\229\138\155\230\181\139\232\175\149\231\187\167\231\187\173", self.AvatarMergeTestResume, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\229\162\158\229\138\160Avatar\229\144\136\229\185\182\230\181\139\232\175\149", self.AvatarMergeTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128Avatar\229\144\136\229\185\182\229\141\149\230\173\165\232\176\131\232\175\149", self.AvatarMergeSingleStepEnable, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173Avatar\229\144\136\229\185\182\229\141\149\230\173\165\232\176\131\232\175\149", self.AvatarMergeSingleStepDisable, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\167\232\161\140Avatar\229\144\136\229\185\182\228\184\139\228\184\128\230\173\165", self.AvatarMergeNextStep, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\231\164\186\229\189\147\229\137\141\229\134\133\229\173\152", self.PrintMemorySize, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\232\181\132\230\186\144\233\128\144\228\184\170\229\138\160\232\189\189", self.AsyncLoadingSingleStepEnable, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173\232\181\132\230\186\144\233\128\144\228\184\170\229\138\160\232\189\189", self.AsyncLoadingSingleStepDisable, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\138\160\232\189\189\228\184\139\228\184\128\228\184\170\232\181\132\230\186\144", self.AsyncLoadingNextStep, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\174\190\231\189\174Avatar\229\144\136\229\185\182GC\233\151\180\233\154\148(\230\172\161\230\149\176)", self.SetAvatarGCInterval, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabNPCPressure:CreateNPC(name, panel, InputText)
  local inputText
  if panel then
    panel:DoClose()
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local num = toNumber(inputText, 1)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.NPCPressureComponent:SpawnNPC(num)
end

function DebugTabNPCPressure:CreateAvatar(name, panel, InputText)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local value
  if panel then
    panel:DoClose()
    value = panel.InputBox:GetText()
  else
    value = InputText or 10
  end
  if "" == value then
    value = "10"
  end
  Log.Debug(value, tonumber(value))
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd LoadOtherPlayer " .. value, localPlayer:GetUEController())
end

function DebugTabNPCPressure:CreatePressureTestBus(name, panel)
  if panel then
    panel:DoClose()
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd LoadOtherPlayer 10", localPlayer:GetUEController())
  local miaomiao = 10014
  local shuilanlan = 10015
  local huohua = 10016
  localPlayer.NPCPressureComponent:SpawnFixNPCs(2, 5, miaomiao, 400)
  localPlayer.NPCPressureComponent:SpawnFixNPCs(2, 5, shuilanlan, 400)
  localPlayer.NPCPressureComponent:SpawnFixNPCs(2, 5, huohua, 400)
  localPlayer.NPCPressureComponent:SpawnFixNPCs(2, 5, 60307, 400)
end

function DebugTabNPCPressure:CreatePressureTestLake(name, panel)
  if panel then
    panel:DoClose()
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd LoadOtherPlayer 3", localPlayer:GetUEController())
  local miaomiao = 10014
  local shuilanlan = 10015
  local huohua = 10016
  localPlayer.NPCPressureComponent:SpawnNPCs(30, miaomiao, 4000)
  localPlayer.NPCPressureComponent:SpawnNPCs(30, shuilanlan, 4000)
  localPlayer.NPCPressureComponent:SpawnNPCs(30, huohua, 4000)
  localPlayer.NPCPressureComponent:SpawnNPCs(5, 60306, 4000)
end

function DebugTabNPCPressure:CreatePressureTestWood(name, panel)
  if panel then
    panel:DoClose()
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd LoadOtherPlayer 3", localPlayer:GetUEController())
  local miaomiao = 10014
  local shuilanlan = 10015
  local huohua = 10016
  localPlayer.NPCPressureComponent:SpawnNPCs(30, miaomiao, 4000)
  localPlayer.NPCPressureComponent:SpawnNPCs(30, shuilanlan, 4000)
  localPlayer.NPCPressureComponent:SpawnNPCs(30, huohua, 4000)
  localPlayer.NPCPressureComponent:SpawnNPCs(5, 60305, 4000)
end

function DebugTabNPCPressure:CreatePressureTest(name, panel, InputText)
  local parmStr
  if panel then
    parmStr = panel:GetInputString()
  else
    parmStr = InputText
  end
  local strs = string.Split(parmStr, " ")
  local distance = 8000
  local SpriteNum = 15
  local NpcNum = 5
  if 3 == #strs then
    distance = tonumber(strs[1])
    NpcNum = tonumber(strs[2])
    SpriteNum = tonumber(strs[3])
    if NpcNum > 60 then
      NpcNum = 60
    end
    if SpriteNum > 60 then
      SpriteNum = 60
    end
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerPos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  
  local function CreatePosition(index, num, dist)
    local angle = 0
    if 1 == index then
      angle = 0
    elseif 2 == index then
      angle = 1
    else
      local Max2Index = math.ceil(math.log(index, 2))
      local StartAngle = 1 / Max2Index
      local Diff = 1 / (Max2Index - 1)
      angle = StartAngle + (index - 2 ^ (Max2Index - 1) - 1) * Diff
    end
    local radius = 100
    if index > 1 then
      radius = 100 + (index - 1) * (dist - 100) / (num - 1)
    end
    local x = radius * math.sin(angle * math.pi)
    local y = radius * math.cos(angle * math.pi)
    return x, y
  end
  
  local NPCPool = {
    20000014,
    20000015,
    20000016,
    20000017,
    20000018,
    2201288,
    506006,
    506007,
    2200250,
    2200251,
    2201287,
    2201272,
    2201276,
    2200253,
    2200252,
    2200254,
    2201281,
    2201280,
    2201283,
    2201286,
    2400017,
    3600014,
    3600012,
    3600011,
    3600010,
    3600013,
    2201100,
    4000041,
    4000043,
    3600015,
    2200260,
    2200256,
    2200255,
    2200259,
    2200258,
    2201217,
    4000047,
    4000046,
    4000045,
    4000044,
    4000042,
    4000038,
    4000037,
    4000035,
    4000031,
    2201140,
    4000061,
    4000050,
    4000051,
    4000054,
    2201183,
    4000070,
    4000094,
    4000048,
    4000049,
    4000055,
    4000056,
    4000059,
    4000060,
    4000061
  }
  local SpritePool = {
    100001,
    100047,
    100003,
    100004,
    100005,
    100006,
    100007,
    100008,
    100009,
    100010,
    100011,
    100012,
    100013,
    100014,
    100016,
    100017,
    100019,
    100020,
    100078,
    100022,
    100023,
    100025,
    100028,
    100029,
    100030,
    100031,
    100033,
    100036,
    100038,
    100039,
    100041,
    100043,
    100045,
    100046,
    100050,
    100053,
    100076,
    100055,
    100057,
    100059,
    100061,
    100063,
    100064,
    100066,
    100067,
    100069,
    100070,
    100071,
    100073,
    100075,
    100080,
    100085,
    100087,
    100089,
    100091,
    100093,
    100096,
    100098,
    100099,
    100103
  }
  for i = 1, NpcNum do
    local Point = ProtoMessage:newPoint()
    local offset_x, offset_y = CreatePosition(i, NpcNum, distance)
    Point.pos.x = math.round(playerPos.X + offset_x)
    Point.pos.y = math.round(playerPos.Y + offset_y)
    Point.pos.z = math.round(playerPos.Z + 1000)
    Point.dir.z = 1
    Point.dir.x = 0
    Point.dir.y = 0
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.content_cfg_id = NPCPool[i]
    req.npc_pos = Point
    req.only_test = false
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, false)
  end
  for i = 1, SpriteNum do
    local Point = ProtoMessage:newPoint()
    local offset_x, offset_y = CreatePosition(i, SpriteNum, distance)
    Point.pos.x = math.round(playerPos.X + offset_x)
    Point.pos.y = math.round(playerPos.Y + offset_y)
    Point.pos.z = math.round(playerPos.Z + 1000)
    Point.dir.z = 1
    Point.dir.x = 0
    Point.dir.y = 0
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.content_cfg_id = SpritePool[i]
    req.npc_pos = Point
    req.only_test = false
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, false)
  end
  if panel then
    panel:DoClose()
  end
end

function DebugTabNPCPressure:AvatarMergeTest(name, panel, InputText)
  local parmStr
  if panel then
    panel:DoClose()
    parmStr = panel:GetInputString()
  else
    parmStr = InputText
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar Start " .. parmStr, localPlayer:GetUEController())
end

function DebugTabNPCPressure:AvatarMergeTestStart10(name, panel)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar Start 10", localPlayer:GetUEController())
end

function DebugTabNPCPressure:AvatarMergeTestStart20(name, panel)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar Start 20", localPlayer:GetUEController())
end

function DebugTabNPCPressure:AvatarMergeTestPause(name, panel)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar pause ", localPlayer:GetUEController())
end

function DebugTabNPCPressure:AvatarMergeTestResume(name, panel)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd TestAvatar resume ", localPlayer:GetUEController())
end

function DebugTabNPCPressure:AvatarMergeSingleStepEnable(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "AvatarMerge.SingleStepMode 1")
end

function DebugTabNPCPressure:AvatarMergeSingleStepDisable(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "AvatarMerge.SingleStepMode 0")
end

function DebugTabNPCPressure:AvatarMergeNextStep(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "AvatarMerge.NextStep 1")
end

function DebugTabNPCPressure:PrintMemorySize(name, panel)
  UE4.UNRCStatics.StatMemory("AvatarMergeMemory after all")
end

function DebugTabNPCPressure:AsyncLoadingSingleStepEnable(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "s.AsyncLoadingSingleStepMode 1")
end

function DebugTabNPCPressure:AsyncLoadingSingleStepDisable(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "s.AsyncLoadingSingleStepMode 0")
end

function DebugTabNPCPressure:AsyncLoadingNextStep(name, panel)
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "s.AsyncLoadingNextStep 1")
end

function DebugTabNPCPressure:SetAvatarGCInterval(name, panel, InputNumber)
  local interval
  if panel then
    interval = panel:GetInputNumber(20)
  else
    interval = tonumber(InputNumber) or 20
  end
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "n.SwitchAvatarGCThreshold " .. interval)
end

function DebugTabNPCPressure:OnServerCreateDebugNPC(rsp)
end

function DebugTabNPCPressure:LocalModeCamTeleportToBus(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(440399.0, 669799.0, 1543.0))
end

function DebugTabNPCPressure:LocalModeCamTeleportToLake(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(436272.9, 641804, 700))
end

function DebugTabNPCPressure:LocalModeCamTeleportToWood(name, panel)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetActorLocation(UE4.FVector(403988, 624034.5, 800))
end

function DebugTabNPCPressure:TransToShopstreet(name, panel)
  self:SetPlayerLocation(440399.0, 669799.0, 1543.0, true)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ueController = localPlayer:GetUEController()
  if ueController then
    quat = UE4.FRotator()
    quat.Pitch = -16
    quat.Yaw = 337
    ueController:SetControlRotation(quat)
  end
end

function DebugTabNPCPressure:TransToLake(name, panel)
  self:SetPlayerLocation(438201, 652338, 1374, true)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ueController = localPlayer:GetUEController()
  if ueController then
    quat = UE4.FRotator()
    quat.Pitch = -13
    quat.Yaw = 328
    ueController:SetControlRotation(quat)
  end
end

function DebugTabNPCPressure:CreatePlayerPressureTest(name, panel, distance)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Distance
  if panel then
    Distance = panel:GetInputNumber(300)
  else
    Distance = tonumber(distance) or 300
  end
  UE4.UNRCStatics.ExecConsoleCommand("AvatarSystemCmd LoadOtherPlayer 1 " .. Distance .. " 0 1 10", localPlayer:GetUEController())
end

function DebugTabNPCPressure:CreatePlayerPetTest(name, panel, InputNumber)
  local huohua
  if panel then
    huohua = panel:GetInputNumber(10016)
  else
    huohua = tonumber(InputNumber) or 10016
  end
  local AvatarSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UAvatarSubsystem)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerPos = localPlayer:GetActorLocation()
  local NPC = localPlayer.NPCPressureComponent:SpawnNPCAtLocation(huohua, playerPos.X + 100, playerPos.Y - 150)
  NPC.AIComponent:ForceLock(true)
  for i, actor in tpairs(AvatarSubsystem.OtherPlayers) do
    local playerPos = actor:Abs_K2_GetActorLocation()
    local NPC = localPlayer.NPCPressureComponent:SpawnNPCAtLocation(huohua, playerPos.X + 100, playerPos.Y - 150)
    NPC.AIComponent:ForceLock(true)
  end
end

function DebugTabNPCPressure:CreatePlayerRideTest(name, panel, InputNumber)
  local rideID
  if panel then
    rideID = panel:GetInputNumber(3012)
  else
    rideID = tonumber(InputNumber) or 3012
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ScenePet = ScenePlayerPet(nil, rideID, -ProtoEnum.SceneRideAllCustomGid.SRCG_Pressure, localPlayer)
  local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
  local helper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL)
  helper:HandleStatus(localPlayer, ScenePet)
  local AvatarSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UAvatarSubsystem)
  for i, actor in tpairs(AvatarSubsystem.OtherPlayers) do
    actor:TestRide(rideID)
  end
end

function DebugTabNPCPressure:MovePlayerTestOn(name, panel, InputNumber)
  local tblMoveContext = {}
  tblMoveContext.tblSource = {}
  tblMoveContext.tblTarget = {}
  local Distance
  if panel then
    Distance = panel:GetInputNumber(300)
  else
    Distance = tonumber(InputNumber) or 300
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local inputComponent = localPlayer.viewObj.BP_PlayerInputHandleCompnent
  inputComponent:UpdateDirection()
  tblMoveContext.right = inputComponent.right
  tblMoveContext.forward = inputComponent.forward
  local playerPos = localPlayer:GetActorLocation()
  local rightX = inputComponent.right.X
  local rightY = inputComponent.right.Y
  tblMoveContext.orgLocation = UE4.FVector(playerPos.X, playerPos.Y, playerPos.Z)
  tblMoveContext.tblSource.X = playerPos.X - rightX * Distance
  tblMoveContext.tblSource.Y = playerPos.Y - rightY * Distance
  tblMoveContext.tblTarget.X = playerPos.X + rightX * Distance
  tblMoveContext.tblTarget.Y = playerPos.Y + rightY * Distance
  local MovePlayer = _G.TimerManager:CreateTimer(tblMoveContext, "DebugTabNPCPressure.MovePlayer", 9999999, function(tblMoveContext)
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local inputComponent = localPlayer.viewObj.BP_PlayerInputHandleCompnent
    local playerPos = localPlayer:GetActorLocation()
    local TargetX = tblMoveContext.tblTarget.X
    local TargetY = tblMoveContext.tblTarget.Y
    local DirectionX = TargetX - playerPos.X
    local DirectionY = TargetY - playerPos.Y
    local Direction = UE4.FVector(DirectionX, DirectionY, 0)
    local orgX = TargetX - tblMoveContext.tblSource.X
    local orgY = TargetY - tblMoveContext.tblSource.Y
    if Direction.X * orgX + Direction.Y * orgY <= 0 then
      local Location = tblMoveContext.tblTarget
      tblMoveContext.tblTarget = tblMoveContext.tblSource
      tblMoveContext.tblSource = Location
    else
      local Y = -UE4.UKismetMathLibrary.Dot_VectorVector(Direction, tblMoveContext.forward)
      local X = UE4.UKismetMathLibrary.Dot_VectorVector(Direction, tblMoveContext.right)
      localPlayer.inputComponent:OnInputMove(UE4.FVector2D(X, Y), 1)
    end
  end, nil, 0.0)
  tblMoveContext.MovePlayer = MovePlayer
  self.tblMoveContext = tblMoveContext
end

function DebugTabNPCPressure:MovePlayerTestOff(name, panel)
  if self.tblMoveContext and self.tblMoveContext.MovePlayer then
    _G.TimerManager:RemoveTimer(self.tblMoveContext.MovePlayer)
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    localPlayer:SetActorLocation(self.tblMoveContext.orgLocation)
    self.tblMoveContext = nil
  end
end

return DebugTabNPCPressure
