local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local PopupData = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupData")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleModuleCmd = require("NewRoco.Modules.Core.Battle.BattleModuleCmd")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local SkillAutoPerform = require("Common.LocalServer.SkillPerformAutoBattle")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local BagModuleEnum = reload("NewRoco.Modules.System.Bag.BagModuleEnum")
local JsonUtils = require("Common.JsonUtils")
local MapRegionArea = require("NewRoco.Modules.Core.Scene.Map.MapRegionArea")
local DebugTabBattle = Base:Extend("DebugTabBattle")

function DebugTabBattle:Ctor()
  Base.Ctor(self)
end

function DebugTabBattle:SetupTabs()
  self:Add("\230\137\147\229\188\128\230\183\177\230\139\183\232\180\157\228\191\157\229\173\152\230\136\152\230\150\151\229\189\149\229\131\143", self.EnableDeepCopyBattleReplay, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\181\139\232\175\149\230\156\128\231\187\136\230\136\152\233\128\128\229\135\186\230\136\152\230\150\151", self.TestFinalBattleOver, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\138\160\232\189\189\230\136\152\229\156\186\229\133\179\229\141\161", self.LoadBattleFieldLevel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\230\136\152\230\150\151\232\128\151\230\151\182\233\135\135\233\155\134", self.EnableBattleProfiler, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\229\129\135\230\149\176\230\141\174PVP\229\189\149\229\177\143\230\168\161\229\188\143", self.EnableFakePVPRecord, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\176\131\232\175\149\230\149\140\230\150\185\231\178\190\231\129\181\232\161\168\230\131\133", self.DebugEnemyExpression, self)
end

function DebugTabBattle:GetFastTitle()
  if _G.GlobalConfig.FastPlay then
    return "\230\129\162\229\164\141Battle\232\161\168\230\188\148"
  else
    return "\229\138\160\233\128\159Battle\232\161\168\230\188\148"
  end
end

function DebugTabBattle:ToggleSkillPrediction()
  BattleConst.ForceShowSkillPrediction = not BattleConst.ForceShowSkillPrediction
end

function DebugTabBattle:ToggleBattleHideScene()
  BattleConst.debugCloseHideScene = not BattleConst.debugCloseHideScene
end

function DebugTabBattle:DebugPetCameraBattleDis()
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerCameraManager = player:GetUEController().playerCameraManager
  if playerCameraManager then
    local cameraLocation = playerCameraManager:Abs_GetCameraLocation()
    local battleLocation = BattleManager.battleRuntimeData.NearbyValidBattleLocation
    local dis2D = UE4.UKismetMathLibrary.Distance2D(cameraLocation, battleLocation)
    local Ctx = DialogContext()
    Ctx:SetContent("\231\155\184\230\156\186\232\183\157\230\136\152\229\156\186\228\184\173\229\191\131\232\183\157\231\166\187" .. tostring(dis2D))
    Ctx:SetMode(DialogContext.Mode.OK)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  end
end

function DebugTabBattle:EnterBattleWithID(id, level)
  local req = ProtoMessage:newZoneGmCreateBattleReq()
  local PlayerLocation = BattleField.debugForceEnterLocation
  if not PlayerLocation then
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
    PlayerLocation.Z = PlayerLocation.Z - player:GetHalfHeight()
  end
  req.avatar_pt.pos.x = math.floor(PlayerLocation.X)
  req.avatar_pt.pos.y = math.floor(PlayerLocation.Y)
  req.avatar_pt.pos.z = math.floor(PlayerLocation.Z)
  if BattleField.debugForceForward then
    local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
    if BattleField then
      local offset = BattleField.OffsetTable
      if BattleField.debugForceForward > 0 and BattleField.debugForceForward <= #offset then
        req.avatar_pt.pos.x = req.avatar_pt.pos.x + offset[BattleField.debugForceForward].x
        req.avatar_pt.pos.y = req.avatar_pt.pos.y + offset[BattleField.debugForceForward].y
        req.avatar_pt.pos.z = req.avatar_pt.pos.z + offset[BattleField.debugForceForward].z
      end
    end
  end
  req.npc_pt.pos.x = math.floor(PlayerLocation.X)
  req.npc_pt.pos.y = math.floor(PlayerLocation.Y)
  req.npc_pt.pos.z = math.floor(PlayerLocation.Z)
  req.battle_conf_id = id
  req.npc_level = level
  Log.Dump(req, 2, "Show Enter Battle Req")
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_BATTLE_REQ, req, self, self.OnEnterBattle)
end

function DebugTabBattle:DebugPVPRsp(rsp)
end

function DebugTabBattle:PVPRandomDebug()
  local req = ProtoMessage:newZoneGmMatchStartReq()
  req.act_id = 307001
  req.team_aim_num = 1
  req.rand_pet = true
  req.pve = false
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_START_REQ, req, self, self.DebugPVPRsp)
end

function DebugTabBattle:PVPMatch()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenPVPMatch)
  self:ClosePanel()
end

function DebugTabBattle:OnOpenDebugPanel()
end

function DebugTabBattle:OnReloadBattleUI()
  HotFix.HotFixModifyFile(false)
  NRCModuleManager:ReloadModule("BattleUIModule")
end

function DebugTabBattle:OnReloadBattle()
  HotFix.HotFixModifyFile(false)
  NRCModuleManager:ReloadModule("BattleModule")
end

function DebugTabBattle:PlayCutFsm()
  local OpenBlackScreenAction = reload("NewRoco.Modules.Core.Battle.Fsm.Actions.OpenBlackScreenAction")
  local CloseBlackScreenAction = reload("NewRoco.Modules.Core.Battle.Fsm.Actions.CloseBlackScreenAction")
  local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
  local FsmState = require("NewRoco.Modules.Core.Fsm.FsmState")
  local FsmDelayAction = require("NewRoco.Modules.Core.Fsm.Actions.FsmDelayAction")
  local fsm = Fsm("BattleCutScreenTest")
  local NormalEnterState = FsmState("NormalEnter")
  NormalEnterState:AddAction(OpenBlackScreenAction("OpenBlackScreenAction"))
  NormalEnterState:AddAction(FsmDelayAction("BattleNormalEnterAction", {PlayTime = 2.0}))
  NormalEnterState:AddAction(CloseBlackScreenAction("CloseBlackScreenAction"))
  fsm:AddState(NormalEnterState)
  fsm:SetInitState(NormalEnterState)
  fsm:Play()
end

function DebugTabBattle:ExportFsm(Name, Panel, fsmPath)
  local FsmSerializeUtils = require("NewRoco.Modules.Core.Fsm.FsmSerializeUtils")
  local FsmPath
  if Panel then
    FsmPath = Panel.InputBox:GetText()
  else
    FsmPath = fsmPath
  end
  local Fsm = reload(string.IsNilOrEmpty(FsmPath) and "NewRoco.Modules.Core.Battle.Fsm.BattleFsm" or FsmPath)
  local Instance = Fsm()
  local DumpResult = FsmSerializeUtils:ToFlowchart(Instance, "LR")
  Log.Debug(DumpResult)
  UE4.UNRCStatics.ClipboardCopy(DumpResult)
end

function DebugTabBattle:EnterBattle(Name, Panel, battleId, npcLevel)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:StopRide(true, nil)
  end
  local Input, Splatted, BattleID, NpcLevel
  if Panel then
    Input = Panel.InputBox:GetText()
    Splatted = string.Split(Input, ";")
    BattleID = tonumber(Splatted[1] or "399005", 10) or 399005
    NpcLevel = tonumber(Splatted[2] or "1", 10) or 1
  else
    BattleID = tonumber(battleId) or 399005
    NpcLevel = tonumber(npcLevel) or 1
  end
  self:EnterBattleWithID(BattleID, NpcLevel)
end

function DebugTabBattle:EnterNearbyBattle(Name, Panel)
  self:EnterBattle(Name, Panel)
end

function DebugTabBattle:OnEnterBattle(rsp)
  Log.Debug("DebugTabBattle:OnEnterBattle:", table.tostring(rsp))
  self:ClosePanel()
  if 0 == rsp.ret_info.ret_code then
    return
  end
  local Context = DialogContext()
  Context:SetTitle("Oops"):SetContent(string.format("\232\191\155\229\133\165\230\136\152\230\150\151\229\164\177\232\180\165:%d", rsp.ret_info.ret_code)):SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function DebugTabBattle:FakeEnemyEscape(Name, Panel)
  local StateName = _G.BattleManager:GetCurrentStateName()
  if StateName ~= BattleEnum.StateNames.RoundSelect then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\232\191\155\229\133\165\230\140\135\228\187\164\233\152\182\230\174\181\228\187\165\229\144\142\229\134\141\231\148\168\229\144\167.\229\189\147\229\137\141\233\152\182\230\174\181:%s", StateName))
    return
  end
  _G.BattleManager.battleRuntimeData.battleExitParam.IsEnemyEscape = true
  _G.BattleNetManager:SendEscapeReq()
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabBattle:ForceEvolution()
  _G.DebugForceEvolution = true
end

function DebugTabBattle:ForceLeaderFight()
  local BattleID = 304002
  local NpcLevel = 1
  self:EnterBattleWithID(BattleID, NpcLevel)
end

function DebugTabBattle:ShowSkillStatus(Name, Panel)
  local Pet = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local SkillComp = Pet.skillComponent
  local Skills = SkillComp:GetDisplaySkills()
  local Global = SkillComp:GetSkillWithType(_G.Enum.SkillActiveType.SAT_GLOBAL)
  local op = {}
  for i, Skill in ipairs(Skills) do
    table.insert(op, string.format("S,%d,%s,%s", i, Skill.config.name, Skill:CanCast() and "\229\143\175\233\135\138\230\148\190" or "\228\184\141\229\143\175\233\135\138\230\148\190"))
  end
  for i, Skill in ipairs(Global) do
    table.insert(op, string.format("G,%d,%s,%s", i, Skill.config.name, Skill:CanCast() and "\229\143\175\233\135\138\230\148\190" or "\228\184\141\229\143\175\233\135\138\230\148\190"))
  end
  local Total = table.concat(op, "\n")
  Log.Debug(Total)
  local Context = DialogContext()
  Context:SetTitle("\230\138\128\232\131\189\231\138\182\230\128\129"):SetContent(Total):SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function DebugTabBattle:ShoutLeft(Name, Panel)
  local PawnManager = _G.BattleManager.battlePawnManager
  local Pet = PawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
    BattleEnum.InfoPopupType.UseEffect,
    Pet.player,
    Pet.card,
    1006011
  })
  _G.DelayManager:DelaySeconds(1.0, function()
    _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, Pet.player)
  end)
end

function DebugTabBattle:ShoutRight(Name, Panel)
  local PawnManager = _G.BattleManager.battlePawnManager
  local Pet = PawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
    BattleEnum.InfoPopupType.UseEffect,
    Pet.player,
    Pet.card,
    1006011
  })
  _G.DelayManager:DelaySeconds(1.0, function()
    _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, Pet.player)
  end)
end

function DebugTabBattle:ShowIdleButton(Name, Panel)
  local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
  BattleConst.ForceShowIdle = true
end

function DebugTabBattle:HideIdleButton(Name, Panel)
  local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
  BattleConst.ForceShowIdle = false
end

function DebugTabBattle:OnPetDie()
  _G.BattleManager.battlePawnManager.playerTeam.pets[1]:PlayDieSkill()
end

function DebugTabBattle:OnTestNiubilityEnemy(Name, Panel)
  local BattleID = 301100
  local NpcLevel = 99
  self:EnterBattleWithID(BattleID, NpcLevel)
end

function DebugTabBattle:ShowPopupStrong(Name, Panel, PopupSubShowType)
  if not _G.BattleManager.isInBattle then
    return
  end
  local Pet = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local Damage = math.random(0, 9999)
  local Popup = PopupData.MakePopup(tostring(Damage), _G.ProtoEnum.AddIcon.AI_DAMAGE)
  Popup:SetPower(4)
  if Panel then
    Popup.popupSubShowType = Panel:GetInputNumber(BattleEnum.PopupShowType.Normal)
  else
    Popup.popupSubShowType = tonumber(PopupSubShowType)
  end
  Pet.buffAEffectPopupComponent:PopupImmediately(Popup)
  Panel:DoClose()
end

function DebugTabBattle:ShowPopup(Name, Panel, PopupSubShowType)
  if not _G.BattleManager.isInBattle then
    return
  end
  local Pet = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local Damage = math.random(0, 9999)
  local Popup = PopupData.MakePopup(tostring(Damage), _G.ProtoEnum.AddIcon.AI_DAMAGE)
  if Panel then
    Popup.popupSubShowType = Panel:GetInputNumber(BattleEnum.PopupShowType.Normal)
  else
    Popup.popupSubShowType = tonumber(PopupSubShowType)
  end
  Pet.buffAEffectPopupComponent:PopupImmediately(Popup)
  Panel:DoClose()
end

function DebugTabBattle:TestCloseEscape(Name, Panel)
  _G.BattleManager.EscapeContext:Close()
end

function DebugTabBattle:AddBloodEffect(Name, Panel)
  local PlayerHPNotify = ProtoMessage:newZonePlayerPetHpChangeNotify()
  PlayerHPNotify.pet_info = {}
  PlayerHPNotify.total_change_hp = 100
  PlayerHPNotify.change_reason = ProtoEnum.PetHpChangeReason.PHCR_IN_SAFE_ZONE
  self:GetPlayer():PlayBloodAddEffect(PlayerHPNotify)
  local AddEnergy = ProtoMessage:newZonePlayerAddRoleEnergyNotify()
  AddEnergy.config_add_val = 5
  AddEnergy.real_add_val = 1
  self:GetPlayer():PlayEnergyAddEffect(AddEnergy)
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabBattle:ShowCatchRate(Name, Panel)
  if not _G.BattleManager.isInBattle then
    return
  end
  local Pet = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  local Probs = Pet:GetCard().petInfo.battle_inside_pet_info.catch_info.catch_prob_list
  self:Inspect(Probs, "\230\141\149\230\141\137\230\166\130\231\142\135")
end

function DebugTabBattle:DoOverrideCatchRate(Name, Panel)
  BattleConst.OverrideCatchRate = Panel:GetInputNumber(0)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\230\141\149\230\141\137\230\166\130\231\142\135\228\191\174\230\148\185\228\184\186%f", BattleConst.OverrideCatchRate))
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabBattle:RayCheck(Name, Panel)
  if not _G.BattleManager.isInBattle then
    Log.Error("\228\184\141\229\156\168\230\136\152\230\150\151\228\184\173\239\188\129\239\188\129\239\188\129")
    return
  end
  local World = UE4Helper.GetCurrentWorld()
  local Controller = UE4.UGameplayStatics.GetPlayerController(self:GetPlayer().viewObj, 0)
  self:TraceTeam(World, Controller, _G.BattleManager.battlePawnManager:GetTeam(BattleEnum.Team.ENUM_TEAM))
  self:TraceTeam(World, Controller, _G.BattleManager.battlePawnManager:GetTeam(BattleEnum.Team.ENUM_ENEMY))
end

function DebugTabBattle:TraceTeam(World, Controller, Team)
  if not Team then
    return
  end
  local Pets = Team.pets
  if not Pets then
    return
  end
  if 0 == #Pets then
    return
  end
  for _, Pet in ipairs(Pets) do
    self:TracePet(World, Controller, Pet)
  end
end

function DebugTabBattle:TracePet(World, Controller, Pet)
  if not Pet then
    return
  end
  local Model = Pet.model
  if not Model then
    return
  end
  Log.Error("Show Collision Profile Names", Pet.card.name, Model.Mesh:GetCollisionProfileName(), Model.HeadWidget:GetCollisionProfileName(), Model.ActionArea:GetCollisionProfileName())
  local ScreenPos = UE4.FVector2D()
  UE4.UGameplayStatics.Abs_ProjectWorldToScreen(Controller, Model:Abs_K2_GetActorLocation(), ScreenPos, true)
  local WorldPos = UE4.FVector()
  local WorldDir = UE4.FVector()
  if not UE4.UGameplayStatics.Abs_DeprojectScreenToWorld(Controller, ScreenPos, WorldPos, WorldDir) then
    Log.Error("Project for pet error")
    return
  end
  local Results, Hit = UE4.UKismetSystemLibrary.Abs_LineTraceMulti(World, WorldPos, WorldPos + WorldDir * 1000, UE4.ETraceTypeQuery.TraceTypeQuery3, true)
  if Hit then
    for Index, Result in tpairs(Results) do
      Log.Error(Pet.card.name, "hitting", Index, Result.Actor.Object:GetName())
    end
  else
    Log.Error(Pet.card.name, "Hits nothing...")
  end
end

function DebugTabBattle:YouThere(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  if string.IsNilOrEmpty(Content) then
    Content = "ABP_BattlePlayerBase_C"
  end
  UE4.UNRCStatics.DumpFClassDesc(Content)
end

function DebugTabBattle:LoadBattleData(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  Log.Debug("LoadBattleData:", Content)
  BattleReplayCachePool:LoadBattleData(Content)
end

function DebugTabBattle:TestReplay(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  Log.Debug("BattleManager.battleRuntimeData:GetBattleID():", Content)
  BattleReplayManager:DoReplayRound(BattleManager.battleRuntimeData:GetBattleID(), tonumber(Content) or 1)
end

function DebugTabBattle:ForceTestSkill()
  if _G.ZoneServer.isLocalServer then
    return
  end
  _G.ZoneServer.isLocalServer = true
  local zoneServer = _G.ZoneServer
  local localServer = require("Common.LocalServer.LocalServer")
  _G.ZoneServer.SendWithHandler = localServer.SendWithHandler
  _G.ZoneServer.Send = localServer.Send
  _G.ZoneServer.OnTick = localServer.OnTick
  _G.ZoneServer.SetRSPTable = localServer.SetRSPTable
  _G.UpdateManager:Register(_G.ZoneServer)
  _G.ZoneServer:SetRSPTable(require("Common.LocalServer.LocalGeneralRSPTable"))
  local skillId = 700001
  local petId = 1
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl cast skill:", skillId, petId)
  local SkillConf = _G.DataConfigManager:GetSkillConf(skillId, true)
  self.LastSkillPath = SkillConf.res_id
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
end

function DebugTabBattle:ShowDistanceBetween2Pet()
  BattleAIManager:DebugShowPetDistanceBetween()
end

function DebugTabBattle:ActivatePlayerFollow()
  BattleConst.PlayerFollowPet = true
end

function DebugTabBattle:DeactivatePlayerFollow()
  BattleConst.PlayerFollowPet = false
end

function DebugTabBattle:CheckIsAttackable()
  BattleAIManager:TestCheckIsAttackable()
end

function DebugTabBattle:TestEnemyMoveToValidPos()
  BattleAIManager:TestMoveToValidPos()
  self:ClosePanel()
end

function DebugTabBattle:TestMoveToValidPos()
  BattleAIManager:TestMoveToValidPos1()
  self:ClosePanel()
end

function DebugTabBattle:TestRotatePet()
  local BattlePet1 = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local BattlePet2 = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  local aPos = BattlePet1.model:Abs_K2_GetActorLocation()
  local bPos = BattlePet2.model:Abs_K2_GetActorLocation()
  local dir = bPos - aPos
  dir.Z = 0
  Log.Debug("show me rot:", dir)
  local Rot = dir:ToRotator():Clamp()
  if Rot then
    BattlePet1.model:K2_SetActorRotation(Rot, false)
  end
  local aPos = BattlePet2.model:Abs_K2_GetActorLocation()
  local bPos = BattlePet1.model:Abs_K2_GetActorLocation()
  local dir = bPos - aPos
  dir.Z = 0
  Log.Debug("show me rot:", dir)
  local Rot = dir:ToRotator():Clamp()
  if Rot then
    BattlePet2.model:K2_SetActorRotation(Rot, false)
  end
  self:ClosePanel()
end

function DebugTabBattle:TestCatch()
  local skillPath = BattleConst.TeamBloodEnterCatch
  BattleResourceManager:LoadClassAsync(self, skillPath, self.OnCatchClassLoad)
end

function DebugTabBattle:OnCatchClassLoad(class)
  if not class then
    return
  end
  local Boss = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  if not Boss or not Boss.model then
    Log.Warning("There is no model in Boss !!!")
    return
  end
  Boss.PerformTeamCatch = true
  local skillComponent = Boss.model.RocoSkill
  local skill = skillComponent:FindOrAddSkillObj(class)
  if not skill then
    self:SkillFinish()
    return
  end
  local characters = BattleManager.battlePawnManager:GetAllPawnActorForSkill()
  local blackBoard = skill:GetBlackboard()
  if blackBoard then
    local bossType = Boss.card:GetPetType()
    local key = "0"
    if bossType and bossType[1] then
      key = tostring(bossType[1] - 1)
    end
    blackBoard:SetValueAsString(key, key)
  end
  skill:SetPassive(true)
  skill:SetCaster(Boss.model)
  skill:SetTargets({
    Boss.model
  })
  skill:SetCharacters(characters)
  skill:RegisterEventCallback("PreEnd", self, self.TestFinish)
  skill:RegisterEventCallback("End", self, self.TestFinish)
  skillComponent:PlaySkill(skill)
end

function DebugTabBattle:TestEscape()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Jineng/Magic/G6_Magic_Run.G6_Magic_Run"
  BattleResourceManager:LoadClassAsync(self, skillPath, self.OnEscapeClassLoad)
end

function DebugTabBattle:OnEscapeClassLoad(class)
  if not class then
    return
  end
  local Target = BattleManager.battlePawnManager.TeamatePlayer
  local skillComponent = Target.model.RocoSkill
  local skill = skillComponent:FindOrAddSkillObj(class)
  if not skill then
    self:SkillFinish()
    return
  end
  skill:SetPassive(false)
  skill:SetCaster(Target.model)
  skillComponent:PlaySkill(skill)
  self:ClosePanel()
end

function DebugTabBattle:TestEscapeLocal()
end

function DebugTabBattle:OpenBattleDebug()
  BattlePerformDebug.EnableLog(true)
end

function DebugTabBattle:CloseBattleDebug()
  BattlePerformDebug.EnableLog(false)
end

function DebugTabBattle:DownBattleData()
  UE.UNRCStatics.DownBattleRecord()
end

function DebugTabBattle:SaveBattleData()
  BattleReplayCachePool:SaveBattleData()
end

function DebugTabBattle:SaveCurBattleData()
  BattleReplayCachePool:SaveCurBattleData()
end

function DebugTabBattle:ReportCurBattleData()
  BattleReplayCachePool:UploadBattleDataTOCrashSight("\230\181\139\232\175\149\233\152\178\229\141\161\230\173\187" .. debug.traceback())
end

function DebugTabBattle:ReplayBattleGM(Name, Panel, fileName)
  if string.IsNilOrEmpty(fileName) then
    return false
  end
  Log.WarningFormat("ReplayBattleGM: %s", fileName)
  _G.UseNearbyLocationInsteadOfRealLocation = false
  local loadResult = BattleReplayCachePool:LoadBattleData(fileName)
  if not loadResult then
    return false
  end
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  BattleReplayManager:DoReplayBattle(battleID)
  BattleReplayCachePool:DumpBattleDataToString(battleID, false)
  return true
end

function DebugTabBattle:TestReplayBattle(Name, Panel, FileName)
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = tostring(FileName)
  end
  if string.IsNilOrEmpty(fileName) then
    Log.Error("TestReplayBattle: fileName is empty")
    return
  end
  local result = self:ReplayBattleGM(Name, Panel, fileName)
  if result then
    self:ClosePanel()
  else
    Log.Error("ReplayBattleGM failed")
  end
end

function DebugTabBattle:TestReplayBattleNearby(Name, Panel, FileName)
  _G.UseNearbyLocationInsteadOfRealLocation = true
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = tostring(FileName)
  end
  if "" == fileName then
    fileName = "03-16_22_13_11_4611729092654399566"
  end
  BattleReplayCachePool:LoadBattleData(fileName)
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  BattleReplayManager:DoReplayBattle(battleID)
  BattleReplayCachePool:DumpBattleDataToString(battleID, false)
  self:ClosePanel()
end

function DebugTabBattle:TestLeaveBattle(Name, Panel)
  BattleManager.stateFsm:SendEvent(BattleEvent.EnterNormalOver)
end

function DebugTabBattle:TranslateBattleData(Name, Panel, FileName)
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = tostring(FileName)
  end
  if "" == fileName then
    fileName = "03-03_15_04_18_4611729139899039821"
  end
  BattleReplayCachePool:LoadBattleData(fileName)
  local battleID = BattleReplayCachePool:TryGetBattleIDByName(fileName)
  Log.Debug("debugba  TranslateBattleData:", fileName, battleID, type(battleID))
  BattleReplayCachePool:DumpBattleDataToString(battleID, true)
end

function DebugTabBattle:DoReplayBattle(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  BattleReplayManager:DoReplayBattle(tonumber(Content))
end

function DebugTabBattle:AutoPlayBattleRecords(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  BattleAutoTest:StartAutoPlayBattleRecords(Content)
end

function DebugTabBattle:AutoReplayBattle(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  BattleAutoTest:StartAutoBattle(Content)
end

function DebugTabBattle:LogAutoBattleState(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  Log.Debug("LogAutoBattleState ", string.format("IsAutoBattle:%s IsStartBattle:%s RemainCount:%s", BattleAutoTest.IsAutoBattle, BattleAutoTest.IsStartBattle, #BattleAutoTest.CommandsOutBattle))
end

function DebugTabBattle:AutoBattle(Name, Panel, content)
  local Content
  if Panel then
    Content = Panel:GetInputString()
  else
    Content = tostring(content)
  end
  BattleAutoTest:LoadBattleTest(true, Content)
end

function DebugTabBattle:StartMultiPlayerPVEBattle(Name, Panel)
  local req = ProtoMessage:newZoneGmMatchStartReq()
  req.pve = true
  req.team_aim_num = 2
  req.act_id = 399006
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_START_REQ, req, self, self.MultiPlayerRsp)
end

function DebugTabBattle:StartMultiPetPVPBattle(Name, Panel)
  local req = ProtoMessage:newZoneGmMatchStartReq()
  req.pve = false
  req.team_aim_num = 1
  req.act_id = 307002
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_START_REQ, req, self, self.MultiPlayerRsp)
end

function DebugTabBattle:StartPlayerPVPBattle(Name, Panel)
  local req = ProtoMessage:newZoneGmMatchStartReq()
  req.act_id = 307001
  req.team_aim_num = 1
  req.rand_pet = false
  req.pve = false
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_START_REQ, req, self, self.MultiPlayerRsp)
end

function DebugTabBattle:SimulateNormalBattle(name, panel)
  SkillPerformAutoBattleUtils:SimulateNormalBattle()
end

function DebugTabBattle:Simulate2V2Battle(name, panel)
  SkillPerformAutoBattleUtils:Simulate2V2Battle()
end

function DebugTabBattle:SimulateBossBattle(name, panel)
  SkillPerformAutoBattleUtils:SimulateBossBattle()
end

function DebugTabBattle:UpdateLocalProtocol(name, panel)
  SkillPerformAutoBattleUtils:UpdateLocalProtocol()
end

function DebugTabBattle:AutoPerformCopingSkill(name, panel)
  SkillPerformAutoBattleUtils:AutoPerformCopingSkill()
end

function DebugTabBattle:AutoPerformBattle(name, panel)
  SkillPerformAutoBattleUtils:AutoPerformBattle()
end

function DebugTabBattle:ShowAutoPerformBattleUI(name, panel)
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenLocalBattleDebug)
end

function DebugTabBattle:ToggleEnemyHPVisibility()
  BattleConst.DebugFlags.ShowPetHP = not BattleConst.DebugFlags.ShowPetHP
end

function DebugTabBattle:MultiPlayerRsp()
end

function DebugTabBattle:ShowAIDebug()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenAIVisible)
end

function DebugTabBattle:SwitchNpcAutoEscape1()
  BattleConst.NpcAutoEscapeSkillDebug = 1
end

function DebugTabBattle:SwitchNpcAutoEscape2()
  BattleConst.NpcAutoEscapeSkillDebug = 2
end

function DebugTabBattle:ShowCatchRates()
  local Ctx = DialogContext()
  local ret = ""
  for _, rateClient in ipairs(_G.BattleManager.battleRuntimeData.catchInfo.lastCatchRatesClient) do
    local name1 = _G.DataConfigManager:GetBagItemConf(rateClient.ballConfID).name
    local tmp = string.format("\231\155\174\230\160\135\239\188\154%s, \229\146\149\229\153\156\231\144\131\239\188\154 %s, GUID\239\188\154%d", rateClient.name, name1, rateClient.guid)
    ret = ret .. tmp .. "\n"
    local tmp1 = string.format("\229\174\162\230\136\183\231\171\175\230\166\130\231\142\135\239\188\154%d ", math.floor(rateClient.rate * 10000))
    ret = ret .. tmp1 .. "\n"
    local isServerFound = false
    if _G.BattleManager.battleRuntimeData.catchInfo.lastCatchRatesServer then
      for _, rateServer in ipairs(_G.BattleManager.battleRuntimeData.catchInfo.lastCatchRatesServer) do
        if rateServer.guid == rateClient.guid then
          local tmp2 = string.format("\230\156\141\229\138\161\229\153\168\230\166\130\231\142\135\239\188\154%d", rateServer.rate)
          ret = ret .. tmp2 .. "\n"
          isServerFound = true
          break
        end
      end
    end
    if not isServerFound then
      local tmp3 = "\230\156\141\229\138\161\229\153\168\230\166\130\231\142\135\232\191\152\230\156\170\232\174\161\231\174\151"
      ret = ret .. tmp3 .. "\n"
    end
  end
  Ctx:SetContent(ret)
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabBattle:OnEnterTestBattleScene()
  BattleConst.CanBattleEverywhere = true
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  local inputText = "111"
  if string.IsNilOrEmpty(inputText) then
    Log.Warning("Please input teleport target")
    return
  end
  local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
  teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  local sceneCfgIdSepPos = string.find(inputText, ";")
  local firstPosVecSepPos = string.find(inputText, ",")
  if sceneCfgIdSepPos or not firstPosVecSepPos then
    if sceneCfgIdSepPos then
      teleReq.to_scene_cfg_id = tonumber(string.sub(inputText, 1, sceneCfgIdSepPos - 1))
      inputText = string.sub(inputText, sceneCfgIdSepPos + 1)
    else
      teleReq.to_scene_cfg_id = tonumber(inputText)
      inputText = ""
    end
  end
  local posVecs = string.split(inputText, ",")
  local posVecsLen = #posVecs
  local toPoint = teleReq.to_point
  if posVecsLen >= 2 then
    toPoint.pos.x = tonumber(posVecs[1])
    toPoint.pos.y = tonumber(posVecs[2])
  end
  if posVecsLen >= 3 then
    toPoint.pos.z = tonumber(posVecs[3])
  end
  if posVecsLen >= 4 then
    toPoint.dir = UE.FVector(0, 0, tonumber(posVecs[4]))
  end
  Log.DebugFormat("Teleport, toSceneCfgId:%s, toPos:(%s,%s,%s), toDirZ:%s", teleReq.to_scene_cfg_id, toPoint.x, toPoint.y, toPoint.z, teleReq.to_point.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, self.OnTestPureBattle, false, true)
end

function DebugTabBattle:OnTestPureBattle(rsp)
  Log.Debug("Debugtabbattle ontestpurebattle")
  Log.Dump(rsp, 3, "OnTestPureBattle:")
  BattleConst.CanBattleEverywhere = true
  _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), 1)
end

function DebugTabBattle:OnTestWaterBattle()
  local req = ProtoMessage:newZoneGmCreateBattleReq()
  req.battle_conf_id = 399019
  req.npc_level = 1
  req.avatar_pt.pos.x = 421970
  req.avatar_pt.pos.y = 682063
  req.avatar_pt.pos.z = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_BATTLE_REQ, req, self, self.OnEnterBattle)
end

function DebugTabBattle:OnEnableWaterBattleReflection()
  local BP_Reflection = _G.NRCResourceManager:LoadForDebugOnly("/Game/ArtRes/Temp/adrianhe/BP_WaterBattleReflection.BP_WaterBattleReflection")
  local reflection = UE4.UGameplayStatics.GetActorOfClass(_G.UE4Helper.GetCurrentWorld(), BP_Reflection)
  if nil == reflection then
    local params = {}
    local fTransform = UE4.FTransform(UE4.FQuat(), UE.FVector(0, 0, 0))
    reflection = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(BP_Reflection, fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, params)
  end
  if nil ~= reflection then
    reflection:Enable()
  end
end

function DebugTabBattle:OnDisableWaterBattleReflection()
  local BP_Reflection = _G.NRCResourceManager:LoadForDebugOnly("/Game/ArtRes/Temp/adrianhe/BP_WaterBattleReflection.BP_WaterBattleReflection")
  local reflection = UE4.UGameplayStatics.GetActorOfClass(_G.UE4Helper.GetCurrentWorld(), BP_Reflection)
  if reflection then
    reflection:Disable()
  end
end

function DebugTabBattle:OpenBattlePosition()
  _G.BattlePosition = false
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SET_BATTLE_POS)
end

function DebugTabBattle:CloseBattlePosition()
  _G.BattlePosition = true
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SET_BATTLE_POS)
end

function DebugTabBattle:OpenBattleFsm()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleFsmUI, true)
end

function DebugTabBattle:CloseBattleFsm()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleFsmUI, false)
end

function DebugTabBattle:Switch1vNBattle()
  SceneUtils.EnableBattleExtraMemberFetching = not SceneUtils.EnableBattleExtraMemberFetching
  Log.Warning("\232\174\190\231\189\174\229\133\129\232\174\1841vx\232\191\155\230\136\152\239\188\154", SceneUtils.Enable1vXBattle)
end

function DebugTabBattle:LogToScreen(...)
end

function DebugTabBattle:DumpPerformPlayer(name, panel)
end

function DebugTabBattle:ForcePlayAllSkill(name, panel)
  local battlePet = _G.BattleManager.battlePawnManager:GetPetByGuid(1)
  local target = _G.BattleManager.battlePawnManager:GetPetByGuid(401)
  local RocoSkill = battlePet.model.RocoSkill
  local PlayOneSkill, PlayNext
  local conf = DataConfigManager:GetAllByName("SKILL_CONF")
  local lst = {}
  local isPlayed = {}
  for k, v in pairs(conf) do
    table.insert(lst, v.res_id)
  end
  local idx = 1
  local Temp = NRCClass()
  
  function Temp.PlayNext()
    Log.Debug("PlayNext:")
    idx = idx + 1
    if idx > #lst then
      Log.Error("done")
    elseif isPlayed[lst[idx]] then
      Temp.PlayNext()
    else
      Temp.PlayOneSkill(Temp, lst[idx])
    end
  end
  
  function Temp.PlayOneSkill(t, skillPath)
    local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
    local CastParam = CastSkillObject.Create()
    CastParam.skillID = skillID
    CastParam.SkillClass = _G.NRCResourceManager:LoadForDebugOnly(skillPath)
    CastParam:SetCaster(target.model):SetInterrupt(true):SetCallbackOwner(self)
    isPlayed[skillPath] = 1
    local _, skillObj = BattleSkillManager:PrepareSkill(target, RocoSkill, CastParam, false)
    Log.Debug("PlayOneSkill:", skillPath, CastParam.SkillClass)
    skillObj:RegisterEventCallback("End", Temp, Temp.PlayNext)
    BattleSkillManager:PlaySkill(skillObj)
  end
  
  Temp:PlayOneSkill(lst[idx])
end

function DebugTabBattle:OpenArtCamera()
  _G.GlobalConfig.OpenArtCamera = true
end

function DebugTabBattle:CloseArtCamera()
  _G.GlobalConfig.OpenArtCamera = false
end

function DebugTabBattle:ExportCoping()
  local counterSkill, beCounterSkill = SkillPerformAutoBattleUtils:GetCoping()
  JsonUtils.DumpSaved("Counter_Skill", counterSkill)
  JsonUtils.DumpSaved("BeCounterSkill", beCounterSkill)
end

function DebugTabBattle:FastPlayBattle(Name, Panel)
  _G.GlobalConfig.FastPlay = not _G.GlobalConfig.FastPlay
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabBattle:EnableMainLayerPanel()
  NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
end

function DebugTabBattle:DisableMainLayerPanel()
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
end

function DebugTabBattle:OpenLobbyMain()
  NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenPanelLobbyMain)
end

function DebugTabBattle:CloseLobbyMain()
  NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ClosePanelLobbyMain)
end

function DebugTabBattle:OpenLegendPanel()
  NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.OpenLegendaryBattleClosePanel)
end

function DebugTabBattle:OpenLegendCatchPanel()
  NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.OpenLegendaryBattleCatchSuccPanel)
end

function DebugTabBattle:OpenLegendIFCatchPanel()
  local Ctx = DialogContext()
  local consumeTicket = DataConfigManager:GetLegendaryGlobalConfig("ticket_cost").num
  local tips = string.format(LuaText.legendary_battle_tips_1, consumeTicket)
  Ctx:SetContent(tips)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetConsumeItem(Enum.VisualItem.VI_LEGENDARY_COIN, consumeTicket)
  Ctx:SetButtonText()
  Ctx:SetCallbackOkOnly(self, function()
  end)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabBattle:AdaptJson(Name, Panel, FileName)
  local JsonUtils = require("Common.JsonUtils")
  local rapidjson = require("rapidjson")
  local fileName
  if Panel then
    fileName = Panel:GetInputString()
  else
    fileName = tostring(FileName)
  end
  if "" == fileName then
    return
  end
  local data = JsonUtils.LoadSaved(fileName, {})
  local Content = rapidjson.encode(data, {pretty = true, sort_keys = true})
  local File = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), fileName .. "Adapt")
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Success = UE4.UNRCStatics.WriteToFile(File, Content)
  self:ClosePanel()
end

function DebugTabBattle:GetAreaConf(Name, Panel)
  local areaConf = DataConfigManager:GetAreaConf(11030039)
  local mapArea = MapRegionArea()
  mapArea:Init(areaConf, nil)
end

function DebugTabBattle:QuickQuitBattle(name, panel, winFlag)
  local req = _G.ProtoMessage:newZoneGmBattleEndReq()
  local num = tonumber(winFlag)
  local WinFlagNum
  if panel then
    WinFlagNum = num or panel:GetInputNumber()
  else
    WinFlagNum = tonumber(num)
  end
  req.battle_result = WinFlagNum
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_BATTLE_END_REQ, req, self, self.QuickQuitBattleRsp)
end

function DebugTabBattle:QuickQuitBattleRsp(rsp)
end

function DebugTabBattle:OpenNPC()
  local req = _G.ProtoMessage:newZoneMageBookQueryReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_MAGE_BOOK_QUERY_REQ, req, self, self.OpenNPCRsp)
end

function DebugTabBattle:OpenNPCRsp(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.data.enabled == true then
    NRCModuleManager:DoCmd(BagModuleCmd.OpenNPCRoster, rsp.data.npcs)
  end
end

function DebugTabBattle:OpenGMAutoBattleTestPanel(Name, Panel)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenAutoBattleTestPanel)
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabBattle:EnableDeepCopyBattleReplay(Name, Panel)
  BattleReplayCachePool.isUsingStreaming = false
end

function DebugTabBattle:TestFinalBattleOver(Name, Panel)
  _G.BattleManager.stateFsm:SendEvent(BattleEvent.FinalBattleOver)
end

function DebugTabBattle:LoadBattleFieldLevel(Name, Panel)
  _G.NRCModeManager:DoCmd(BattleModuleCmd.LoadBattleFieldLevel)
end

function DebugTabBattle:EnableBattleProfiler(Name, Panel)
  BattleProfiler:SetEnable()
end

function DebugTabBattle:EnableFakePVPRecord()
  _G.EnableFakePVPRecord = not _G.EnableFakePVPRecord
end

function DebugTabBattle:DebugEnemyExpression()
  local Boss = _G.BattleManager.battlePawnManager:GetFirstPet(BattleEnum.Team.ENUM_ENEMY)
  if not Boss then
    self:ShowTips("Boss\228\184\141\229\173\152\229\156\168")
    return
  end
  if not Boss.model then
    self:ShowTips("Boss\230\168\161\229\158\139\228\184\141\229\173\152\229\156\168")
    return
  end
  Boss.model.DebugFacialExpression = true
  UE.UKismetSystemLibrary.ExecuteConsoleCommand(Boss.model, "p.ANSFacialExpressionDebug 1", nil)
end

return DebugTabBattle
