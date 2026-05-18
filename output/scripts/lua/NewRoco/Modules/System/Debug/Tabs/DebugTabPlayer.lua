local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local ScenePlayerMessageBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMessageBuff")
local MagicMessageUtils = require("NewRoco.Modules.System.MagicMessage.MagicMessageUtils")
local DebugTabPlayer = Base:Extend("DebugTabPlayer")

function DebugTabPlayer:Ctor()
  Base.Ctor(self)
end

function DebugTabPlayer:SetupTabs()
  self:Add("\230\137\147\229\141\176\231\142\169\229\174\182\229\133\137\230\160\135\230\160\135\232\174\176", self.OutPutCousorLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\231\137\181\230\137\139", self.TestLink, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\150\173\229\188\128\229\144\140\232\161\140", self.UnTogether, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\142\169\229\174\182\229\142\187\229\147\170\228\186\134\239\188\159", self.WhereAreYou, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\176\157\232\175\149\228\184\187\232\167\146\232\180\180\229\156\176", self.LandPlayer, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\164\169\230\176\148\231\147\182\231\137\185\230\149\136", self.PlayWeatherBottleEffect, self)
  self:Add("\229\177\143\232\148\189\228\189\141\231\189\174\233\157\158\230\179\149\229\188\185\231\170\151", self.BanPosInvalidOutOfStuck, self)
  self:Add("\229\188\186\229\136\182\233\154\143\230\156\186\229\165\151\232\163\133Relax\232\161\168\230\188\148", self.ForceSuitRelax, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("AnyTest", self.AnyTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\136\155\232\167\146\229\133\179\229\141\161\228\191\161\230\129\175", self.GetCreatePlayerInfo, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\176\131\232\175\149\231\142\169\229\174\182\233\170\145\228\185\152\230\140\130\231\130\185\228\191\161\230\129\175", self.DebugPlayerHudData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\135\141\229\187\186\229\157\144\230\160\135\229\142\159\231\130\185", self.SetNewWorldOrigin, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\144\175\231\148\168\231\156\160\230\158\173\229\186\135\230\138\164\230\137\128\230\151\165\229\191\151", self.EnableShelterLog, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\229\136\155\229\187\186Actor", self.TestSpawnActor, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\190\231\164\186\231\149\153\232\168\128\233\157\162\230\157\191id", self.GetMagicMessageFeedId, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\190\231\164\186\231\149\153\232\168\128\233\157\162\230\157\191\231\172\172N\228\184\170\232\175\132\232\174\186id", self.GetMagicMessageCommentId, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\144\175or\231\166\129\231\148\168\229\174\162\230\136\183\231\171\175\231\187\159\228\184\128\229\138\159\232\131\189\229\177\143\232\148\189", self.GmSkipFuncBlocking, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\156\141\229\138\161\229\153\168\229\138\159\232\131\189\229\177\143\232\148\189\230\149\176\230\141\174", self.GetSvrFuncBlockingDebugData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\148\159\230\136\144\228\189\141\231\189\174\230\160\135\232\174\176", self.AddLocationMarker, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\148\128\230\175\129\230\137\128\230\156\137\230\160\135\232\174\176", self.RemoveLocationMarker, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\228\191\174\230\148\185JumpZVelocity(\232\190\131\229\164\167\233\171\152\232\183\179)", self.ChangeJumpZVelocity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\228\191\174\230\148\185GravityScale(\230\158\129\229\176\143\233\171\152\232\183\179,\232\180\159\230\149\176\233\163\158\229\164\169)", self.ChangeGravityScale, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabPlayer:TestSpawnActor()
  Log.Warning("DebugTabPlayer:TestSpawnActor")
  local actorClassPath = UE4.UClass.Load("Blueprint'/Game/ArtRes/Effects/BP/BattleMagic/BloodDoubled/BP_BloodDoubledScene00401.BP_BloodDoubledScene00401_C'")
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local fTransfom = Player:GetActorTransform()
  fTransfom.Scale3D = UE4.FVector(0.1, 0.1, 0.1)
  local params = {}
  local actor = UE4Helper.GetCurrentWorld():Abs_SpawnActor(actorClassPath, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, params)
end

function DebugTabPlayer:SlanText(Name, Panel)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocation()
  local Rot = Player:GetActorRotation()
  local outText = string.format("%d;%d;%d\t%d;%d;%d", math.round(Pos.X), math.round(Pos.Y), math.round(Pos.Z), self:GetAngle(Rot.Roll), self:GetAngle(Rot.Pitch), self:GetAngle(Rot.Yaw))
  UE4.UNRCStatics.ClipboardCopy(outText)
end

function DebugTabPlayer:GetAngle(num)
  if num < 0 then
    return math.round(num % 360)
  elseif num > 360 then
    return math.round(num % 360)
  else
    return math.round(num)
  end
end

function DebugTabPlayer:OutPutCousorLog()
  local UEController = UE.UGameplayStatics.GetPlayerController(UE4Helper.GetCurrentWorld(), 0)
  if UEController then
    UEController:DumpCursor()
  else
    Log.Error("UE4Helper.ToggleCursor ", "No UE Controller")
  end
end

function DebugTabPlayer:ShowRay()
  ScenePlayerMessageBuff:SetTrajectory(true)
  MagicMessageUtils.SetTrajectory(true)
end

function DebugTabPlayer:CloseRay()
  ScenePlayerMessageBuff:SetTrajectory(false)
  MagicMessageUtils.SetTrajectory(false)
end

function DebugTabPlayer:ReportCurrentPos()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local txt = "\229\189\147\229\137\141\231\142\169\229\174\182\228\189\141\231\189\174" .. string.format("%f, %f, %f\n", playerLocation.X, playerLocation.Y, playerLocation.Z)
  if BattleManager.isInBattle then
    txt = txt .. "\229\189\147\229\137\141\229\156\168\230\136\152\230\150\151\228\184\173\n" .. "\228\184\138\230\172\161\232\191\155\230\136\152\230\150\151\229\133\165\229\143\163\228\189\141\231\189\174" .. string.format("%f, %f, %f", BattleField.debugLastEnterBattlePoint.X, BattleField.debugLastEnterBattlePoint.Y, BattleField.debugLastEnterBattlePoint.Z)
    UE4.UNRCStatics.ClipboardCopy(string.format("(X=%f,Y=%f,Z=%f)", BattleField.debugLastEnterBattlePoint.X, BattleField.debugLastEnterBattlePoint.Y, BattleField.debugLastEnterBattlePoint.Z))
  else
    UE4.UNRCStatics.ClipboardCopy(string.format("(X=%f,Y=%f,Z=%f)", playerLocation.X, playerLocation.Y, playerLocation.Z))
  end
  local Ctx = DialogContext()
  Ctx:SetContent(txt)
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabPlayer:DumpStatusInfo()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local localPlayer = playerModule.playerModuleData.localPlayer
  if localPlayer then
    Log.PrintScreenMsg("============= WORLD PLAYER STATUS BEGIN =============")
    for status, have in pairs(localPlayer.statusComponent._statusDic) do
      Log.PrintScreenMsg(table.getKeyName(Enum.WorldPlayerStatusType, status) .. " " .. have)
    end
    Log.PrintScreenMsg("=============  WORLD PLAYER STATUS END  =============")
  end
end

function DebugTabPlayer:DebugStatusInfo()
  GlobalConfig.DebugStatusInfo = not GlobalConfig.DebugStatusInfo
end

function DebugTabPlayer:ShutDownSafeReload()
  _G.bShutDownSafeReload = true
end

function DebugTabPlayer:ToggleStatusSync()
  GlobalConfig.SyncPlayerStatus = not GlobalConfig.SyncPlayerStatus
end

function DebugTabPlayer:ToggleDCPSmooth()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local localPlayer = playerModule.playerModuleData.localPlayer
  if localPlayer then
    local movementComponent = localPlayer.viewObj.CharacterMovement
    movementComponent.bEnableDCPSmooth = not movementComponent.bEnableDCPSmooth
  end
end

function DebugTabPlayer:SetSurfaceTemp(name, panel, id)
  if panel then
    self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    self._Player.TemperatureComponent.isGMSurface = true
    local value = tonumber(panel.InputBox:GetText())
    if value then
      self._Player.TemperatureComponent.surfaceDebugValue = value
    end
  elseif id then
    self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    self._Player.TemperatureComponent.isGMSurface = true
    local value = id
    if value then
      self._Player.TemperatureComponent.surfaceDebugValue = value
    end
  end
end

function DebugTabPlayer:CancelSetSurfaceTemp(name, panel)
  self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self._Player.TemperatureComponent.isGMSurface = false
end

function DebugTabPlayer:ToggleMantle()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player.viewObj.ToggleMantle ~= nil then
    player.viewObj.ToggleMantle = not player.viewObj.ToggleMantle
  end
end

function DebugTabPlayer:PrintBlockInfo()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local movementComp = player.viewObj.CharacterMovement
    if movementComp.CurrentFloor.bBlockingHit then
      local floorActor = movementComp.CurrentFloor.HitResult.Actor
      if floorActor then
        local msg = string.format("\229\189\147\229\137\141\231\171\153\231\171\139\231\154\132\229\156\176\232\161\168\230\152\175\239\188\154%s", floorActor:GetFullName())
        UE4Helper.PrintScreenMsg(msg)
      else
        UE4Helper.PrintScreenMsg("\230\178\161\230\159\165\232\175\162\229\136\176Actor\228\191\161\230\129\175")
      end
    end
    local ForwardHit
    ForwardHit = movementComp:DetectForwardHit(ForwardHit)
    if ForwardHit.bBlockingHit then
      local blockActor = ForwardHit.Actor
      if blockActor then
        local msg = string.format("\229\137\141\230\150\185\231\154\132\233\152\187\230\140\161\231\137\169\230\152\175\239\188\154%s", blockActor:GetFullName())
        UE4Helper.PrintScreenMsg(msg)
      elseif ForwardHit.Component then
        local msg = string.format("\229\137\141\230\150\185\231\154\132\233\152\187\230\140\161\231\137\169\230\152\175\239\188\154%s", ForwardHit.Component:GetFullName())
        UE4Helper.PrintScreenMsg(msg)
      else
        UE4Helper.PrintScreenMsg("\230\178\161\230\159\165\232\175\162\229\136\176\229\137\141\230\150\185\233\152\187\230\140\161\228\191\161\230\129\175")
      end
    end
  end
end

function DebugTabPlayer:PrintCrouchInfo()
  GlobalConfig.DebugCrouchStatus = not GlobalConfig.DebugCrouchStatus
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    player:SendEvent(PlayerModuleEvent.ON_PLAYER_WILL_OUT_OFF_CONTROL)
  end
end

function DebugTabPlayer:PlayerLightToggle()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.viewObj then
    player.viewObj.BP_PlayerLightComponent:SetPlayerLightActivity(true)
  end
end

function DebugTabPlayer:TogglePlayerInertial()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.viewObj then
    player:ToggleRootMotion(not player.viewObj.UseRMLocomotion)
  end
end

function DebugTabPlayer:TogglePause()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    player:Pause(not player.isPaused)
  end
end

function DebugTabPlayer:DumpConditionTypes(name, panel)
  FunctionBanManager:DumpConditionTypes()
end

function DebugTabPlayer:DumpFunctionStates(name, panel)
  FunctionBanManager:DumpFunctionStates()
end

function DebugTabPlayer:ClearAllConditions()
  FunctionBanManager:ClearAllConditions()
end

function DebugTabPlayer:AddPlayerCondition(name, panel, id)
  if panel then
    local value = tonumber(panel.InputBox:GetText())
    if value then
      FunctionBanManager:AddPlayerConditionType(value)
    end
  elseif id then
    local value = id
    if value then
      FunctionBanManager:AddPlayerConditionType(value)
    end
  end
end

function DebugTabPlayer:RemovePlayerCondition(name, panel, id)
  if panel then
    local value = tonumber(panel.InputBox:GetText())
    if value then
      FunctionBanManager:RemovePlayerConditionType(value)
    end
  elseif id then
    local value = id
    if value then
      FunctionBanManager:RemovePlayerConditionType(value)
    end
  end
end

function DebugTabPlayer:ToggleClientEevent(name, panel)
  FunctionBanManager.ReportEvtToServer = not FunctionBanManager.ReportEvtToServer
  Log.Error("ReportEvtToServer", FunctionBanManager.ReportEvtToServer)
end

function DebugTabPlayer:ToggleClimb()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local canClimb = player.viewObj.CharacterMovement.bEnableClimb
  player.viewObj.CharacterMovement.bEnableClimb = not canClimb
end

function DebugTabPlayer:ChangeGenderLocal()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local gender = 1
  if 1 == player.gender then
    gender = 2
  end
  GlobalConfig.ForceLocalMode = true
  player:SetCharacterGender(gender)
  GlobalConfig.ForceLocalMode = false
end

function DebugTabPlayer:LockIdle()
  NRCModuleManager:DoCmd(PlayerModuleCmd.LockLocalPlayerRelaxIdle, true)
end

function DebugTabPlayer:OnAltKey(action_type, action_name)
  Log.DebugFormat("On AltKey %d", action_type)
  local Player = self:GetPlayer()
  local Controller = Player:GetUEController()
  Controller.bShowMouseCursor = not Controller.bShowMouseCursor
end

function DebugTabPlayer:MouseMoveX(axis_value)
  Log.DebugFormat("On MouseMoveX %f", axis_value)
end

function DebugTabPlayer:SwitchPCMode()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  Instance:SetPCMode(not Instance:IsPCMode())
end

function DebugTabPlayer:TestPlayFx(Name, Panel, InputText)
  _G.DelayManager:DelaySeconds(4, function(player)
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local rocoFx = Player.viewObj:GetComponentByClass(UE4.URocoFXComponent)
    local effPath
    if Panel then
      effPath = Panel.InputBox:GetText()
    else
      effPath = InputText
    end
    if string.IsNilOrEmpty(effPath) then
      effPath = "Common/Xibiejiaohu/Lig/Lig_XBJH_Hit.Lig_XBJH_Hit"
    end
    local effPathFull = "NiagaraSystem'/Game/ArtRes/Effects/Particle/'" .. effPath
    local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
    local headSocket = BattleUtils.GetAttachPointNameByType(UE4.EFXAttachPointType.Head)
    rocoFx:PlayFxByPath_Name(effPathFull, headSocket, true, true)
  end)
end

function DebugTabPlayer:TestPlaySkill(Name, Panel, SkillPath)
  _G.DelayManager:DelaySeconds(4, function()
    self:PlayTestSkill(Panel, SkillPath)
  end)
end

function DebugTabPlayer:PlayTestSkill(panel, SkillPath)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local SkillComp = Player:GetSkillComponent()
  local skillPath
  if panel then
    skillPath = panel.InputBox:GetText()
  else
    skillPath = SkillPath
  end
  if string.IsNilOrEmpty(skillPath) then
    skillPath = "Example/G6_MoBan/G6_MB_CamFx"
  end
  local Klass = _G.NRCResourceManager:LoadForDebugOnly("/Game/ArtRes/Effects/G6Skill/" .. skillPath)
  local Skill = SkillComp:FindOrAddSkillObj(Klass)
  Skill:SetCaster(Player.viewObj)
  SkillComp:PlaySkill(Skill)
  self:TestPlaySkill("", panel)
end

function DebugTabPlayer:AvatarSuitShop()
  local AppearanceLocalUtils = require("NewRoco.Modules.System.Appearance.AppearanceLocalUtils")
end

function DebugTabPlayer:AvatarBeautyShop()
  local AppearanceLocalUtils = require("NewRoco.Modules.System.Appearance.AppearanceLocalUtils")
  AppearanceLocalUtils.OpenSalon()
end

function DebugTabPlayer:TogglePerceptionAll()
  GlobalConfig.bRidePerceptionAll = not GlobalConfig.bRidePerceptionAll
end

function DebugTabPlayer:SetPlayerAttr(Name, Panel, inputText)
  local InputText
  if Panel then
    InputText = Panel.InputBox:GetText()
  else
    InputText = inputText
  end
  if nil == InputText or "" == InputText then
    Log.Error("Need Input: AttrType(from common_data.proto) Numer")
    return
  end
  local Params = {}
  for w in string.gmatch(InputText, "%S+") do
    table.insert(Params, w)
  end
  if #Params < 2 then
    Log.Error("Need Input: AttrType(from common_data.proto) Numer")
    return
  end
  local AttrType = tonumber(Params[1]) or 0
  local Number = tonumber(Params[2]) or 10
  if 0 == AttrType then
    Log.Error("Need Input: AttrType(from common_data.proto) Numer")
    return
  end
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = ProtoEnum.SceneGmType.SGT_ATTR
  Req.gm_op_type = ProtoEnum.SceneGmOpType.SGOT_SET
  Req.uin = 0
  Req.param1 = AttrType
  Req.param2 = Number
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, nil, false, false)
end

function DebugTabPlayer:SwitchCameraControlMode()
  if 0 == GlobalConfig.TurnAccMode then
    GlobalConfig.TurnAccMode = 1
    Log.Warning("\229\136\135\230\141\162\232\135\179\232\183\157\231\166\187\229\138\160\233\128\159\230\168\161\229\188\143")
  elseif 1 == GlobalConfig.TurnAccMode then
    GlobalConfig.TurnAccMode = 2
    Log.Warning("\229\136\135\230\141\162\232\135\179\233\128\159\229\186\166\229\138\160\233\128\159\230\168\161\229\188\143")
  elseif 2 == GlobalConfig.TurnAccMode then
    GlobalConfig.TurnAccMode = 0
    Log.Warning("\229\136\135\230\141\162\232\135\179\233\187\152\232\174\164\230\168\161\229\188\143")
  end
end

function DebugTabPlayer:SwitchDebugCameraControlMode()
  GlobalConfig.DebugTurnAccMode = not GlobalConfig.DebugTurnAccMode
end

function DebugTabPlayer:AddLevelStoryFlag()
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo()
  table.insert(PlayerInfo.story_flag_info.story_flags, 7303)
  _G.DataModelMgr.PlayerDataModel:SendEvent(ENUM_PLAYER_DATA_EVENT.STORY_FLAG_CHANGE, 7303)
end

function DebugTabPlayer:RemoveLevelStoryFlag()
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo()
  if table.contains(PlayerInfo.story_flag_info.story_flags, 7303) and table.isArray(PlayerInfo.story_flag_info.story_flags) then
    table.removeValue(PlayerInfo.story_flag_info.story_flags, 7303)
  end
  _G.DataModelMgr.PlayerDataModel:SendEvent(ENUM_PLAYER_DATA_EVENT.STORY_FLAG_CHANGE)
end

function DebugTabPlayer:DumpCollisionFlag()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player then
    Player:DumpCollisionFlag()
  end
end

function DebugTabPlayer:QuickQuitBattle()
  local req = _G.ProtoMessage:newZoneGmBattleEndReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_BATTLE_END_REQ, req, self, self.QuickQuitBattleRsp)
end

function DebugTabPlayer:ChangeIntoInvincible(name, panel, num, InputText)
  if type(num) ~= "number" then
    num = 1
  end
  local req = _G.ProtoMessage:newZoneGmPlayerInvincibleManageReq()
  local strInPanel
  if panel then
    strInPanel = panel:GetInputString()
  else
    strInPanel = InputText
  end
  local numInPanel = tonumber(strInPanel)
  local state
  if numInPanel then
    state = numInPanel
  else
    state = num
  end
  req.open_or_close = state
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_PLAYER_INVINCIBLE_MANAGE_REQ, req, self, self.ChangeIntoInvincibleRsp)
end

function DebugTabPlayer:ChangeIntoInvincibleRsp(rsp)
end

function DebugTabPlayer:ForceVisibleAllPlayer()
  local playerModule = _G.NRCModuleManager:GetModule("PlayerModule")
  if playerModule then
    playerModule:ForceShowAllPlayer()
  end
end

function DebugTabPlayer:SetPlayerMagicLevel(name, panel, level)
  local req = ProtoMessage:newZoneGmClientSetPlayerLevelReq()
  local num = tonumber(level)
  local SetLevel
  if panel then
    SetLevel = panel:GetInputNumber()
  else
    SetLevel = num
  end
  req.level = SetLevel
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_SET_PLAYER_LEVEL_REQ, req, self, self.GetRsp)
end

function DebugTabPlayer:GetRsp()
end

function DebugTabPlayer:SetPlayerStarLevel(name, panel, level)
  local req = ProtoMessage:newZoneGmClientSetWorldLevelReq()
  local num = tonumber(level)
  local SetLevel
  if panel then
    SetLevel = panel:GetInputNumber()
  else
    SetLevel = num
  end
  req.level = SetLevel
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_SET_WORLD_LEVEL_REQ, req, self, self.GetRsp)
end

function DebugTabPlayer:PlayWeatherBottleEffect(Name, Panel)
  local Player = self:GetPlayer()
  Player:PlayPostBattleCollectEffect("/Game/ArtRes/Effects/G6Skill/SceneCaiji/G6_Scene_Collected_Bottle")
end

function DebugTabPlayer:BanPosInvalidOutOfStuck()
  local req = ProtoMessage:newZoneGmStopPosCheckReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_STOP_POS_CHECK_REQ, req, self, self.GetRsp)
end

function DebugTabPlayer:ForceSuitRelax()
  GlobalConfig.ForceSuitRelax = not GlobalConfig.ForceSuitRelax
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local animIns = player.viewObj.AnimComponent:GetAnimInstance("RM_LocoMotion")
  if animIns then
    animIns.bForceSuitRelax = GlobalConfig.ForceSuitRelax
  end
end

function DebugTabPlayer:AnyTest()
  local Player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetInputEnable(self, false)
  Player.inputComponent:SetInputEnable(self, false, "Test")
end

function DebugTabPlayer:GetCreatePlayerInfo()
  local levelData = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetLevelData)
  Log.Error("123")
end

function DebugTabPlayer:CreateMagicDrawDebug(name, panel)
  local Module = _G.NRCModuleManager:GetModule("MagicCreationModule")
  if not Module then
    return
  end
  if Module.bDrawDebugFlag == nil then
    Module.bDrawDebugFlag = false
  end
  Module.bDrawDebugFlag = not Module.bDrawDebugFlag
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\229\136\155\233\128\160\233\173\148\230\179\149\231\154\132debug\231\138\182\230\128\129\239\188\154%s", tostring(Module.bDrawDebugFlag)), 1, nil, 5)
end

function DebugTabPlayer:LandPlayer()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player:OnPlayerBorn(Player:GetActorLocation(), true)
end

function DebugTabPlayer:DebugPlayerHudData(name, panel)
  local duration = 20
  if panel then
    local inputDuration = panel.InputBox:GetText()
    duration = tonumber(inputDuration) or duration
  end
  local players = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_ALL_PLAYER)
  if not players then
    return
  end
  for _, player in pairs(players) do
    if player.isLocal then
    else
      local hudComponent = player.hudComponent
      local debugHeadPos = hudComponent and hudComponent._debugHeadPos
      if not debugHeadPos then
      else
        local playerViewObj = player.viewObj
        if playerViewObj and UE.UObject.IsValid(playerViewObj) then
          UE.UKismetSystemLibrary.DrawDebugSphere(playerViewObj, debugHeadPos, 10, 8, UE.FLinearColor(0, 1, 0, 1), duration)
          local playerMesh = playerViewObj.Mesh
          if playerMesh and UE.UObject.IsValid(playerMesh) then
            local headPos = playerMesh:GetSocketLocation("Bip001-Head")
            UE.UKismetSystemLibrary.DrawDebugSphere(playerViewObj, headPos, 10, 8, UE.FLinearColor(1, 0, 0, 1), duration)
          end
        end
      end
    end
  end
  if panel then
    panel:DoClose()
  end
end

function DebugTabPlayer:SetNewWorldOrigin()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local gameWorld = UE4Helper.GetCurrentWorld()
  UE4.UNRCStatics.ForceWorldRebasing(gameWorld, playerLocation)
  Log.PrintScreenMsg("\229\188\186\229\136\182\229\157\144\230\160\135\233\135\141\229\187\186 \228\185\139\229\137\141\231\154\132\228\184\150\231\149\140\229\142\159\231\130\185 X:%d Y:%d Z:%d", gameWorld:GetWorldOriginX(), gameWorld:GetWorldOriginY(), gameWorld:GetWorldOriginZ())
end

function DebugTabPlayer:EnableShelterLog()
  local cmd = string.format("WorldTileTool.DebugLuaBegin 1")
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
  cmd = string.format("WorldTileTool.DebugActorBegin 1")
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
  cmd = string.format("WorldTileTool.DebugObjectBegin 1")
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
  cmd = string.format("WorldTileTool.SetDebugLuaBegin Owl BeginPlay")
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
  cmd = string.format("WorldTileTool.SetDebugActorBegin Owl BeginPlay")
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
  cmd = string.format("WorldTileTool.SetDebugObjectBegin Owl BeginPlay")
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
end

function DebugTabPlayer:GetMagicMessageFeedId()
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local showMessagePanel = mainUIModule:GetPanel("ShowMagicMessage")
  if showMessagePanel then
    local id = showMessagePanel.feed_id
    UE4.UNRCStatics.ClipboardCopy(id)
  else
    Log.PrintScreenMsg("\233\156\128\232\166\129\230\137\147\229\188\128\230\159\165\231\156\139\231\149\153\232\168\128\233\157\162\230\157\191\239\188\129")
  end
end

function DebugTabPlayer:GetMagicMessageCommentId(name, panel, itemID, num)
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local showMessagePanel = mainUIModule:GetPanel("ShowMagicMessage")
  if showMessagePanel then
    if panel then
      local inputIndex = tonumber(panel.InputBox:GetText())
      if inputIndex then
        local pageIndex = math.ceil(inputIndex / 100) - 1
        local pageCommentList = showMessagePanel.commentList[pageIndex + 1]
        if pageCommentList then
          local commentIndex = inputIndex % 100
          if 0 == commentIndex then
            commentIndex = 100
          end
          local commentInfo = pageCommentList[commentIndex]
          if commentInfo then
            UE4.UNRCStatics.ClipboardCopy(commentInfo.feedback_id)
          else
            Log.PrintScreenMsg("\232\175\183\232\190\147\229\133\165\229\144\136\230\179\149\231\154\132\232\175\132\232\174\186\231\180\162\229\188\149\239\188\129")
          end
        else
          Log.PrintScreenMsg("\232\175\183\232\190\147\229\133\165\229\144\136\230\179\149\231\154\132\232\175\132\232\174\186\231\180\162\229\188\149\239\188\129")
        end
      else
        Log.PrintScreenMsg("\232\175\183\232\190\147\229\133\165\229\144\136\230\179\149\231\154\132\232\175\132\232\174\186\231\180\162\229\188\149\239\188\129")
      end
    end
  else
    Log.PrintScreenMsg("\233\156\128\232\166\129\230\137\147\229\188\128\230\159\165\231\156\139\231\149\153\232\168\128\233\157\162\230\157\191\239\188\129")
  end
end

function DebugTabPlayer:GmSkipFuncBlocking(name, panel)
  local skip = not _G.FunctionBanManager.gmSkipFuncBlocking
  _G.FunctionBanManager:GmSkipFuncBlocking(skip)
  if skip then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\231\166\129\231\148\168\229\174\162\230\136\183\231\171\175\231\187\159\228\184\128\229\138\159\232\131\189\229\177\143\232\148\189!")
  else
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\188\128\229\144\175\229\174\162\230\136\183\231\171\175\231\187\159\228\184\128\229\138\159\232\131\189\229\177\143\232\148\189!")
  end
end

function DebugTabPlayer:GetSvrFuncBlockingDebugData(name, panel)
  self:Inspect(_G.FunctionBanManager:GetSvrFuncBlockingDebugData(), "SvrFuncBlockingDebugData")
end

function DebugTabPlayer:AddLocationMarker()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local NPC = NPCModule:CreateLocalNPC(50183, {
    x = playerLocation.X,
    y = playerLocation.Y,
    z = playerLocation.Z - 80
  }, 0)
  NPC.Name = "\230\160\135\232\174\176\231\130\185"
  NPCModule:AddGMMarkerPointNPC(NPC)
end

function DebugTabPlayer:RemoveLocationMarker()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:ClearGMMarkerPointNPC()
end

function DebugTabPlayer:ChangeJumpZVelocity(Name, Panel)
  local targetValue
  if Panel then
    if string.IsNilOrEmpty(Panel.InputBox:GetText()) then
      targetValue = 600
    else
      targetValue = Panel.InputBox:GetText()
    end
  else
    targetValue = 600
  end
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local movementComponent = player.viewObj.CharacterMovement
  movementComponent.JumpZVelocity = targetValue
  if 600 == targetValue then
    Log.Error("JumpZVelocity\229\183\178\233\135\141\231\189\174\229\155\158\233\187\152\232\174\164\229\128\188600")
  else
    local text = string.format("JumpZVelocity\229\183\178\232\174\190\231\189\174\228\184\186%s    \229\189\147\228\191\174\230\148\185\228\184\186\232\190\131\229\164\167\229\128\188\230\151\182\229\141\179\229\143\175\233\171\152\232\183\179", targetValue)
    Log.Error(text)
  end
end

function DebugTabPlayer:ChangeGravityScale(Name, Panel)
  local targetValue
  if Panel then
    if string.IsNilOrEmpty(Panel.InputBox:GetText()) then
      targetValue = 2
    else
      targetValue = Panel.InputBox:GetText()
    end
  else
    targetValue = 2
  end
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local movementComponent = player.viewObj.CharacterMovement
  movementComponent.GravityScale = targetValue
  if 2 == targetValue then
    Log.Error("GravityScale\229\183\178\233\135\141\231\189\174\229\155\158\233\187\152\232\174\164\229\128\1882")
  else
    local text = string.format("GravityScale\229\183\178\232\174\190\231\189\174\228\184\186%s    \229\189\147\228\191\174\230\148\185\228\184\186\230\158\129\229\176\143\229\141\179\229\143\175\233\171\152\232\183\179,\232\180\159\230\149\176\229\141\179\229\143\175\233\163\158\229\164\169", targetValue)
    Log.Error(text)
  end
end

function DebugTabPlayer:TestLink()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND) then
    player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
    return
  end
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P) then
    player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
    return
  end
  local TempArray = UE.TArray(UE.AActor)
  player.viewObj.ActionArea:GetOverlappingActors(TempArray, UE.ARocoPlayerBase)
  for idx, actor in tpairs(TempArray) do
    local sceneActor = actor.sceneCharacter
    if sceneActor then
      local otherUin = sceneActor:GetLogicId()
      local localUin = player:GetLogicId()
      if otherUin ~= localUin then
        local custom_params = ProtoMessage.newPlayerStatusCustomParams()
        custom_params.player_interact_param.interact_id = nil
        custom_params.player_interact_param.player_uin1 = localUin
        custom_params.player_interact_param.player_uin2 = otherUin
        player.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND, nil, nil, custom_params)
        return
      end
    end
  end
end

function DebugTabPlayer:UnTogether()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.InviteComponent then
    player.InviteComponent:InteractCancel()
  end
end

function DebugTabPlayer:ChangeTogether()
end

function DebugTabPlayer:AddStarlight(name, panel)
  local num = 0
  if panel then
    num = panel:GetInputNumber()
  end
  _G.NRCModuleManager:DoCmd(_G.WishCrystalModuleCmd.GMAddStarlight, num)
end

function DebugTabPlayer:WhereAreYou(name, Panel, InputNumber)
  local uin
  if Panel then
    uin = Panel:GetInputNumber()
  else
    uin = tonumber(InputNumber)
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if uin and 0 ~= uin then
    player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, uin)
  end
  if not player then
    Log.Error("\231\142\169\229\174\182" .. uin .. "\228\184\141\229\173\152\229\156\168")
  else
    local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
    Log.Error("\231\142\169\229\174\182" .. uin .. "\231\154\132\228\189\141\231\189\174\230\152\175X:" .. playerLocation.X .. "\239\188\140Y:" .. playerLocation.Y .. "\239\188\140Z:" .. playerLocation.Z)
    local playerHidden = player.viewObj:GetActorHidden()
    Log.Error("\231\142\169\229\174\182" .. uin .. "\231\154\132HiddenBits\230\152\175" .. tostring(playerHidden) .. "")
    if playerHidden then
      for i = 0, 31 do
        if player.viewObj:GetMaskHidden(i) then
          Log.Error("\231\142\169\229\174\182" .. uin .. "\231\154\132HiddenBits\231\154\132\231\172\172" .. i .. "\228\189\141\230\152\1751")
        end
      end
    end
  end
end

return DebugTabPlayer
