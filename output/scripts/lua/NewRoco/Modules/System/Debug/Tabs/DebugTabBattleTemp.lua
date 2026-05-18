local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleCraneCameraDefine = require("NewRoco.Modules.Core.Battle.CraneCamera.BattleCraneCameraDefine")
local Base = DebugTabBase
local DebugTabBattleTemp = Base:Extend("DebugTabBattleTemp")

function DebugTabBattleTemp:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleTemp:SetupTabs()
  self:Add("\230\184\133\233\153\164\230\156\128\231\187\136\230\136\152\230\149\153\231\168\139\232\174\176\229\189\1491", self.ClearFinalBattleTutorial1, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\184\133\233\153\164\230\156\128\231\187\136\230\136\152\230\149\153\231\168\139\232\174\176\229\189\1492", self.ClearFinalBattleTutorial2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\190\231\164\186\230\136\152\230\150\151\231\178\190\231\129\181\231\154\132\229\177\158\230\128\167", self.ShowAttributesByBattlePet, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\230\136\152\230\150\151\231\178\190\231\129\181\231\154\132\229\177\158\230\128\167", self.CloseAttributesByBattlePet, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\190\231\164\186\230\138\128\232\131\189\230\160\143id", self.SwitchSKillIdInSkillPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\152\230\150\151\230\137\147\229\188\128\233\162\157\229\164\150\228\191\161\230\129\175\231\149\140\233\157\162", self.OpenBattleAdditionalTarget, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\152\230\150\151\229\133\179\233\151\173\233\162\157\229\164\150\228\191\161\230\129\175\231\149\140\233\157\162", self.CloseBattleAdditionalTarget, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\228\188\160\233\128\129\229\136\176\233\166\150\233\162\134\230\136\152\230\150\151\229\137\175\230\156\172", self.SilhouetteCombatSimulation, self, nil, nil, nil, nil, "", "")
  self:Add("\230\137\147\229\188\128PVP\231\187\147\231\174\151\229\185\182\230\181\139\232\175\149\230\146\173\230\148\190\229\138\168\231\148\187", self.OpenPvpDanGradingAndPlayAnim, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173PVP\231\187\147\231\174\151\231\149\140\233\157\162", self.ClosePvpDanGradingAndPlayAnim, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\187\147\231\174\151\231\149\140\233\157\162\230\174\181\228\189\141\229\138\168\231\148\187\230\168\161\230\139\159", self.SettlementRankAnimationSimulation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\229\137\170\229\189\177\231\161\174\232\174\164\233\166\150\229\143\145\231\149\140\233\157\162", self.OpenLevelFirstPublishPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\229\137\170\229\189\177\231\161\174\232\174\164\233\166\150\229\143\145\231\149\140\233\157\162", self.CloseLevelFirstPublishPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151\228\184\187\231\149\140\233\157\162\229\138\160\232\189\189", self.TestLoadBattleMainWin, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151\232\167\146\232\137\178\229\138\160\232\189\189", self.TestLoadBattlePlayer, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151npc\229\138\160\232\189\189", self.TestLoadNPC, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151\231\178\190\231\129\181\229\138\160\232\189\189", self.TestLoadBattlePet, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151NPC\232\191\155\229\133\165\231\149\140\233\157\162", self.LoadBattleEnterSkill, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151NPC\232\191\155\229\133\165\231\149\140\233\157\162\230\137\128\231\148\168UI", self.LoadBattleEnterSkillUI, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\148\185\229\143\152\232\141\137\229\156\176", self.TestChangeGrass, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\136\135\230\141\162\230\152\175\229\144\166\229\144\175\231\148\168\230\142\146\228\189\141\232\181\155\229\140\185\233\133\141\229\141\149\233\128\137\230\161\134", self.TogglePvpRankCheckBox, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\181\139\232\175\149\229\144\145\231\178\190\231\129\181\231\188\150\233\152\159\228\184\173\230\183\187\229\138\160\233\154\143\230\156\186\231\178\190\231\129\181\230\149\176\230\141\174", self.TestInjectRandomPetDataInTeam, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\181\139\232\175\149\230\136\152\230\150\151\228\184\173\229\138\168\230\128\129\228\191\174\230\148\185\229\155\180\232\167\130 NPC", self.TestModifyBattleOnLookerAtRuntime, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\181\139\232\175\149\230\138\128\232\131\189\233\161\186\229\186\143\228\186\164\230\141\162", self.TestBattleSkillChange, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\233\162\134\229\156\176\232\175\149\231\187\131\229\164\135\230\136\152\229\140\186->\232\167\130\230\136\152\229\140\186", self.TestTerritoryPrepareToBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\233\162\134\229\156\176\232\175\149\231\187\131\228\187\147\229\186\147\229\140\186->\229\164\135\230\136\152\229\140\186", self.TestTerritoryBagToPrepare, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\229\145\168\233\170\140\232\175\129\231\142\169\230\179\149\232\131\156\229\136\169\231\187\147\231\174\151\231\149\140\233\157\162", self.TestWeeklyTestSettlePanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\229\145\168\233\170\140\232\175\129\231\142\169\230\179\149\232\131\156\229\136\169\231\187\147\231\174\151\231\149\140\233\157\162", self.CloseWeeklyTestSettlePanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128NPC\232\191\155\229\133\165\230\136\152\230\150\151\233\149\156\229\164\180\231\188\169\230\148\190", self.EnablePveBattleStandAnim, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\228\188\160\232\175\180\231\178\190\231\129\181CG\230\181\139\232\175\149", self.EnableBeastCG, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\179\233\151\173\228\188\160\232\175\180\231\178\190\231\129\181CG\230\181\139\232\175\149", self.DisableBeastCG, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\128\167\232\131\189\230\181\139\232\175\149-\229\156\186\230\153\175\230\155\191\230\141\162\228\184\186\229\145\168\230\181\139\232\175\149", self.ReplaceToWeekBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\128\167\232\131\189\230\181\139\232\175\149-\229\156\186\230\153\175\230\155\191\230\141\162\228\184\186\231\169\186\229\156\186\230\153\175", self.ReplaceToEmptyScene, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\128\167\232\131\189\230\181\139\232\175\149-\232\191\152\229\142\159\229\156\186\230\153\175\230\181\139\232\175\149\230\157\161\228\187\182", self.ReplaceToTeamScene, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\145\168\233\170\140\232\175\129\231\142\169\230\179\149--\230\181\139\232\175\149\230\136\152\230\150\151", self.WeeklyBattleTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\152\229\156\186\229\143\175\232\167\134\229\140\150\233\133\141\231\189\174--\232\153\154\230\158\132\230\136\152\229\156\186", self.CreateBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\136\152\229\156\186\229\143\175\232\167\134\229\140\150\233\133\141\231\189\174--\232\191\155\229\133\165\230\136\152\230\150\151", self.SimulateBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("B1\230\156\128\231\187\136\230\136\152\230\137\147\229\188\128\228\184\164\231\178\190\231\129\181\229\175\185\232\175\157\233\149\156\229\164\180", self.OpenTwoPetDialogueCamera, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("B1\230\156\128\231\187\136\230\136\152\229\133\179\233\151\173\228\184\164\231\178\190\231\129\181\229\175\185\232\175\157\233\149\156\229\164\180", self.CloseTwoPetDialogueCamera, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\156\172\229\156\176\230\138\128\232\131\189\230\146\173\230\148\190", self.TestSkillByPath, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\188\128\229\167\139\230\136\152\230\150\151\230\149\153\229\173\166\230\140\135\229\188\149", self.OnBattleTutorialGuide, self, nil, nil, nil, nil, "", "", "OnBattleTutorialGuide")
  self:Add("\230\184\133\233\153\164\230\136\152\230\150\151\230\149\153\229\173\166\230\140\135\229\188\149", self.ClearBattleTutorialGuide, self, nil, nil, nil, nil, "", "", "ClearBattleTutorialGuide")
  self:Add("\229\136\183\230\150\176\230\136\152\230\150\151\230\149\153\229\173\166\230\140\135\229\188\149\230\149\176\230\141\174", self.RefreshBattleTutorialGuide, self, nil, nil, nil, nil, "", "", "RefreshBattleTutorialGuide")
end

function DebugTabBattleTemp:ModifyComboAttackDelay(Name, Panel, id)
  if Panel then
    local num = Panel:GetInputNumber()
    if num then
      BattleConst.MultiplayerBattle.ComboAttackDelay = num
    end
  elseif id then
    local num = id
    if num then
      BattleConst.MultiplayerBattle.ComboAttackDelay = num
    end
  end
end

function DebugTabBattleTemp:ForceTestEvolution(Name, Panel)
  local player = BattleEvolutionPlayer()
  local node = BattlePerformNode()
  player:Play(node)
end

function DebugTabBattleTemp:ForceLoadSkillRes()
  BattleSkillManager:SpawnSkillComponent()
end

function DebugTabBattleTemp:TestBattleDepthCam()
  BattleManager.vBattleField.BattleDepthCam:Update()
end

function DebugTabBattleTemp:OnTestCastSkill(Name, Panel)
  local skill_cast = {}
  skill_cast.caster_id = 1
  skill_cast.target_id = {401}
  skill_cast.skill_id = 7050091
  local CastSkillParam = CastSkillObject.FromPerformInfoToSkill(skill_cast)
  local Caster = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_TEAM)
  local Target = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
  CastSkillParam:SetCaster(Caster.model)
  CastSkillParam:SetTargets({
    Target.model
  })
  local battlePet1 = BattleManager.battlePawnManager:GetPetByGuid(1)
  local skillCOmponent, skillObj = battlePet1:PrepareSkill(CastSkillParam)
  Log.Debug("play skill:", skillCOmponent, skillObj)
  skillCOmponent:PlaySkill(skillObj)
end

function DebugTabBattleTemp:OnSelectPetByLinetrace(Name, Panel)
  _G.EnableDebugSelectPet = true
end

function DebugTabBattleTemp:CheckIsAttackable()
  BattleAIManager:TestCheckIsAttackable(true)
end

function DebugTabBattleTemp:CheckIsAttackable2()
  BattleAIManager:TestCheckIsAttackable(false)
end

function DebugTabBattleTemp:ForceTestSkill()
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
  local skillId = 702003
  local petId = 1
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = _G.ProtoMessage:newZoneBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  req.feature_data = _G.NRCSDKManager:GetLightFeaturePacket()
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl cast skill:", skillId, petId)
  local SkillConf = _G.DataConfigManager:GetSkillConf(skillId, true)
  self.LastSkillPath = SkillConf.res_id
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
end

function DebugTabBattleTemp:teestevent()
  NRCEventCenter:RegisterEvent("tttt", self, "testevent", self.ontestevent)
end

function DebugTabBattleTemp:teestunevent()
  NRCEventCenter:UnRegisterEvent(self, "testevent", self.ontestevent)
end

function DebugTabBattleTemp:teestdisevent()
  NRCEventCenter:DispatchEvent("testevent")
end

function DebugTabBattleTemp:ontestevent()
  Log.Warning("ontesteventontesteventontesteventontesteventontestevent")
end

function DebugTabBattleTemp:InterDebugCreateNPC(Name, Panel)
  local id = 10012
  local num = num or 1
  Log.Debug("show me id num:", id, num)
  for i = 1, num do
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local Pos = Player:GetActorLocationFrameCache()
    local Rot = Player:GetActorRotationFrameCache()
    local Point = ProtoMessage:newPoint()
    Pos = Pos + Rot:RotateVector(FVectorOne * 300)
    Point.pos.x = math.round(Pos.X)
    Point.pos.y = math.round(Pos.Y)
    Point.pos.z = math.round(Pos.Z)
    Point.dir = UE.FVector(0, 0, math.round((Rot.Yaw or 0) * 10))
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.npc_cfg_id = id
    req.npc_pos = Point
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, self, self.OnServerCreateDebugNPC)
  end
end

function DebugTabBattleTemp:PrintMaterialInfo(Name, Panel)
  local AllPawns = _G.BattleManager.battlePawnManager:GetAllPawn()
  for _, Pawn in ipairs(AllPawns) do
    local Actor = Pawn.model
    if Actor then
      Log.Debug("Show Battle Pawn Mat Info", UE.UObject.GetName(Actor))
    end
    local Comp = Actor and Actor.RocoMaterial
    if Comp then
      Comp:PrintDebugInfo()
    end
  end
end

function DebugTabBattleTemp:OnSetGlobalTime(Name, Panel, id)
  if Panel then
    local value = Panel.InputBox:GetText()
    if value then
      value = tonumber(value)
    else
      value = 1
    end
    _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), value)
  elseif id then
    local value = id
    if value then
      value = tonumber(value)
    else
      value = 1
    end
    _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), value)
  end
end

function DebugTabBattleTemp:OnMarkPoint(Name, Panel)
  BattleLogger:Log("test")
end

function DebugTabBattleTemp:OnSaveLog(Name, Panel)
  BattleLogger:Save()
end

function DebugTabBattleTemp:OnClearLog(Name, Panel)
  BattleLogger:Clear()
end

function DebugTabBattleTemp:OnShowPerformPlayer(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, BattleManager.turnPlayer.performPlayer, Name or "Root")
end

function DebugTabBattleTemp:OnForceTestWaterSurfaceBattle()
  _G.ForceWaterBattle = true
end

function DebugTabBattleTemp:OnCreateWaterPlaform()
  _G.NeedCreateWaterPlaform = true
end

function DebugTabBattleTemp:OnWaterPlaformFollowBattlePet()
  _G.NeedWaterPlatformFollowBattlePet = true
end

function DebugTabBattleTemp:OpenPlayerSkill()
  _G.IsOpenPlayerSkill = true
end

function DebugTabBattleTemp:ClosePlayerSkill()
  _G.IsOpenPlayerSkill = false
end

function DebugTabBattleTemp:TestWeeklyTestSettlePanel(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%d+") do
    table.insert(params, w)
  end
  local SettleData = {
    pve_add_info = {
      challenge_level_id = 1000,
      activity_id = 1000,
      cheer_point = params[1] and tonumber(params[1]) or 8,
      cheer_point_this_week = params[2] and tonumber(params[2]) or 12
    }
  }
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  DelayManager:DelaySeconds(2, function()
    _G.NRCModeManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.OpenWeeklyChallengeSettlement, SettleData, true)
  end)
end

function DebugTabBattleTemp:CloseWeeklyTestSettlePanel()
  _G.NRCModeManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.CloseWeeklyChallengeSettlement)
end

function DebugTabBattleTemp:EnableAdaptiveBattlePetPos()
  _G.enableAdaptiveBattlePetPos = not _G.enableAdaptiveBattlePetPos
end

function DebugTabBattleTemp:OnShowAdaptiveLine()
  _G.ShowAdaptiveLine = true
end

function DebugTabBattleTemp:SetGlobalTimeDilation()
  _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), 1.0)
end

function DebugTabBattleTemp:OpenChallengeDialog(name, panel)
  _G.NRCModeManager:DoCmd(_G.TeamBattleModuleCmd.OpenTeamBattleStartConfirmTips, true)
  if panel then
    panel:DoClose()
  end
end

function DebugTabBattleTemp:OpenCraneCameraDebugLine()
  local battleCraneCamera = BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera then
    battleCraneCamera.ShowDebugLine = true
  end
end

function DebugTabBattleTemp:CloseCraneCameraDebugLine()
  local battleCraneCamera = BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera then
    battleCraneCamera.ShowDebugLine = false
  end
end

function DebugTabBattleTemp:OpenCraneCameraDepth()
  local battleCraneCamera = BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera then
    battleCraneCamera.confData:ResetEnableDepthOfField(true, 0.25)
    battleCraneCamera:CheckDepthCfg()
  else
    _G.BattleManager:OpenDepthCfg(0.25)
  end
  _G.BattleManager.IsOpenDepth = true
end

function DebugTabBattleTemp:CloseCraneCameraDepth()
  local battleCraneCamera = BattleManager.vBattleField.battleCraneCamera
  if battleCraneCamera then
    battleCraneCamera.confData:ResetEnableDepthOfField(false, 0)
    battleCraneCamera:CheckDepthCfg()
  else
    _G.BattleManager:CloseDepthCfg()
  end
  _G.BattleManager.IsOpenDepth = false
end

function DebugTabBattleTemp:SprintCraneCameraCurTag()
  local battleCraneCamera = _G.BattleManager.vBattleField.battleCraneCamera
  if _G.BattleManager.vBattleField and battleCraneCamera then
    local curTag = battleCraneCamera.confData:GetCurCameraTag()
    local battleType = _G.BattleManager.battleRuntimeData and _G.BattleManager.battleRuntimeData.battleType or 0
    local jsonName = battleCraneCamera.confData:GetJsonNameByCameraTag(curTag)
    Log.Debug("CraneCamera \229\189\147\229\137\141\230\156\186\228\189\141Id=", curTag, "\229\175\185\229\186\148\230\156\186\228\189\141\233\133\141\231\189\174\230\150\135\228\187\182=", jsonName, "\230\136\152\230\150\151\231\177\187\229\158\139=", battleType)
  end
end

function DebugTabBattleTemp:OpenBattlePet()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenPetCatchPanel, true)
end

function DebugTabBattleTemp:CloseBattlePet()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenPetCatchPanel, false)
end

function DebugTabBattleTemp:OpenRecordSkillList()
  _G.OpenRecordSkillList = true
end

function DebugTabBattleTemp:CloseRecordSkillList()
  _G.OpenRecordSkillList = false
end

function DebugTabBattleTemp:OpenPVP_PreparePanel()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenPVP_PreparePanel)
end

function DebugTabBattleTemp:OpenPVPAnimalTest()
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  local bPanelOpen = _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleEntryHudVS, nil, nil, nil, function(widget, teamPlayerMode, enemyPlayerMode1, enemyPlayerMode2)
  end)
end

function DebugTabBattleTemp:ClosePVPAnimalTest()
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.CloseBattleEntryHudVS)
end

function DebugTabBattleTemp:OpenPVPMatchTeam()
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenPVPMatchTeam)
end

function DebugTabBattleTemp:OpenDirectAngleDefault()
  _G.OpenDirectAngleZero = true
end

function DebugTabBattleTemp:Testshowcheckobj()
  local AllPlayerTeam = BattleManager.battlePawnManager.AllPlayerTeam
  if AllPlayerTeam then
    for _, v in pairs(AllPlayerTeam) do
      v.player:CheckObj()
    end
  end
end

function DebugTabBattleTemp:OnStartRspWatcher()
  _G.StartRspWatcher = true
end

function DebugTabBattleTemp:OnStopRspWatcher()
  _G.StartRspWatcher = false
end

function DebugTabBattleTemp:CloseDirectAngleDefault()
  _G.OpenDirectAngleZero = false
end

function DebugTabBattleTemp:ClearFinalBattleTutorial1()
  local List = ProtoMessage:newPointList()
  local point = ProtoMessage:newPoint()
  point.pos.x = 0
  table.insert(List.points, point)
  _G.DataModelMgr.RemoteStorage:Set("WishPowerTutorial", ".Next.PointList", List, self, self.OnPutResult)
end

function DebugTabBattleTemp:ClearFinalBattleTutorial2()
  local List = ProtoMessage:newPointList()
  local point = ProtoMessage:newPoint()
  point.pos.x = 0
  table.insert(List.points, point)
  _G.DataModelMgr.RemoteStorage:Set("FinalBattleTutorial", ".Next.PointList", List, self, self.OnPutResult)
end

function DebugTabBattleTemp:OnPutResult(rsp)
end

function DebugTabBattleTemp:ShowAttributesByBattlePet(Name, Panel)
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.SwitchDebugEntryBattle)
end

function DebugTabBattleTemp:CloseAttributesByBattlePet(Name, Panel)
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.CloseDebugEntryBattle)
end

function DebugTabBattleTemp:SwitchSKillIdInSkillPanel(Name, Panel)
  _G.ShowSKillIdInSkillPanel = not _G.ShowSKillIdInSkillPanel
end

function DebugTabBattleTemp:OpenBattleAdditionalTarget(Name, Panel)
end

function DebugTabBattleTemp:CloseBattleAdditionalTarget(Name, Panel)
end

function DebugTabBattleTemp:SilhouetteCombatSimulation()
  local req = ProtoMessage:newZoneChallengeCreateBattleReq()
  req.source_data = ProtoMessage:newSourceData()
  req.source_data.source_type = ProtoEnum.EClientBattleSourceType.ECBST_BOSS_CHALLENGE
  req.source_data.activity_id = 3002
  req.source_data.challenge_level_id = 1001
  req.dungeon_id = 410101
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CHALLENGE_CREATE_BATTLE_REQ, req, self, self.OnBattleRsp, false, false)
end

function DebugTabBattleTemp:OnBattleRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
  end
end

function DebugTabBattleTemp:OpenPvpDanGradingAndPlayAnim(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%d+") do
    table.insert(params, w)
  end
  local index = params[1] or 1
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenPVPDanGradingPanel, nil, index)
end

function DebugTabBattleTemp:ClosePvpDanGradingAndPlayAnim(name, panel)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ClosePVPDanGradingPanel)
end

function DebugTabBattleTemp:OpenLevelFirstPublishPanel(name, panel)
  NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.OpenPVPRankedMatch)
end

function DebugTabBattleTemp:CloseLevelFirstPublishPanel(name, panel)
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenLoading)
  NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.ForceCloseLoading)
end

function DebugTabBattleTemp:TestLoadBattleMainWin()
  BattleManager:OpenBattleMainWindow()
end

function DebugTabBattleTemp:TestLoadBattlePlayer(name, panel)
  local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
  local modelConf = _G.DataConfigManager:GetModelConf(1010001)
  local modelPath = modelConf.path
  Log.Error("show me modelpath:", modelPath)
  local params = {}
  params.index = 1
  params.team = BattleEnum.Team
  params.player = nil
  params.inBattle = true
  local req = _G.BattleResourceManager:LoadActorAsyncWithParam(self, modelPath, nil, params, self.PawnPlayerOver, self.PawnPetFailed, nil, nil, nil, nil, nil)
end

function DebugTabBattleTemp:PawnPlayerOver(model)
  Log.Error("DebugTabBattleTemp PawnPlayerOver")
  local fashionIds = {
    10700101,
    10800101,
    10900101,
    11000101,
    11100101,
    11200101,
    11300101,
    32500101
  }
  local salonIds = {
    {color_wear_id = 0, item_wear_id = 153},
    {color_wear_id = 0, item_wear_id = 1},
    {color_wear_id = 0, item_wear_id = 33},
    {color_wear_id = 0, item_wear_id = 58},
    {color_wear_id = 0, item_wear_id = 157},
    {color_wear_id = 0, item_wear_id = 64}
  }
  model:SetDefaultSuit(model.Mesh, 1, fashionIds, salonIds, self.PawnBattlePlayerOverAndSuited, self)
end

function DebugTabBattleTemp:PawnBattlePlayerOverAndSuited()
  Log.Error("DebugTabBattleTemp PawnBattlePlayerOverAndSuited")
end

function DebugTabBattleTemp:TestLoadNPC(name, panel)
  local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
  local modelConf = _G.DataConfigManager:GetModelConf(17024)
  local modelPath = modelConf.path
  Log.Error("show me modelpath:", modelPath)
  local params = {}
  params.index = 1
  params.team = BattleEnum.Team
  params.player = nil
  params.inBattle = true
  local req = _G.BattleResourceManager:LoadActorAsyncWithParam(self, modelPath, nil, PriorityEnum.Passive_Battle_Default, params, self.PawnNPCOver, self.PawnPetFailed, nil, nil, nil, nil, nil)
end

function DebugTabBattleTemp:PawnNPCOver()
  Log.Error("DebugTabBattleTemp PawnNPCOver")
end

function DebugTabBattleTemp:TestLoadBattlePet()
  local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
  local modelConf = _G.DataConfigManager:GetModelConf(14046)
  local modelPath = modelConf.path
  Log.Error("show me modelpath:", modelPath)
  local params = {}
  params.index = 1
  params.team = BattleEnum.Team
  params.player = nil
  params.inBattle = true
  local req = _G.BattleResourceManager:LoadActorAsyncWithParam(self, modelPath, nil, PriorityEnum.Passive_Battle_Default, params, self.PawnPetOver, self.PawnPetFailed, nil, nil, nil, nil, nil)
end

function DebugTabBattleTemp:PawnPetOver()
  Log.Error("DebugTabBattleTemp PawnPetOver")
end

function DebugTabBattleTemp:LoadBattleEnterSkill()
  local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
  self.resList = {
    BattleConst.PveEnter.TwoPlayerSkill_C,
    BattleConst.PveEnter.TwoEnemySkill_C
  }
  BattleSkillManager:PreLoadRes(self.resList, true)
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
end

function DebugTabBattleTemp:OnBattleEvent(e)
  local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
  if e == BattleEvent.OnSkillResLoaded then
    Log.Error("DebugTabBattleTemp OnBattleEvent res loaded")
  end
end

function DebugTabBattleTemp:LoadBattleEnterSkillUI()
  local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
  local hudRes = "/Game/NewRoco/Modules/Core/Battle/entryHud.entryHud_C"
  _G.BattleResourceManager:LoadWidgetAsync(self, hudRes, UE4.UGameplayStatics:GetPlayerController(0), function(caller, widget)
    Log.Error("hud done")
  end, self.Finish)
end

function DebugTabBattleTemp:SettlementRankAnimationSimulation(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%d+") do
    table.insert(params, w)
  end
  local old_pvp_rank_star = params[1] and tonumber(params[1]) or 1
  local new_pvp_rank_star = params[2] and tonumber(params[2]) or 2
  local new_pvp_rank_order = params[3] and tonumber(params[3]) or 220
  local old_pvp_rank_order = params[4] and tonumber(params[4]) or 110
  local info = {}
  info.old_pvp_rank_star = old_pvp_rank_star
  info.new_pvp_rank_star = new_pvp_rank_star
  info.old_pvp_rank_order = old_pvp_rank_order
  info.new_pvp_rank_order = new_pvp_rank_order
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.OpenPVPDanGradingPanel, info)
end

function DebugTabBattleTemp:TestBattleSkillChange(name, panel)
  local a = require("Common.Coroutine.async")
  local au = require("Common.Coroutine.async_util")
  au.Launch(a.task(function()
    local assetPath = "/Game/NewRoco/Modules/System/BattleUI/Res/Skill/UMG_Battle_Skill_Item_2.UMG_Battle_Skill_Item_2_C"
    local asset, assetRef
    do
      local ok, request, assetOrMessage = a.wait(au.LoadResource(assetPath, 255, 255))
      if ok then
        asset = assetOrMessage
        assetRef = UnLua.Ref(asset)
      end
    end
    if not asset then
      Log.Error("brk DebugTabBattleTemp:TestBattleSkillChange asset is nil")
      return
    end
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenBattleTestSkillListWidget)
    a.wait(au.WaitUntilCondition(function()
      local skillList = _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.GetBattleTestSkillListWidget)
      return skillList and skillList.isFullyConstructed
    end))
    local skillList = _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.GetBattleTestSkillListWidget)
    local BattleChangeSkillPositionPlayer = require("NewRoco.Modules.Core.Battle.Players.BattleChangeSkillPositionPlayer")
    local player = BattleChangeSkillPositionPlayer(skillList, asset)
    player.isTestMode = true
    player:Play()
    UnLua.Unref(assetRef)
  end))
end

function DebugTabBattleTemp:EnablePveBattleStandAnim(Name, Panel)
  _G.IsEnablePveBattleStandAnim = true
end

function DebugTabBattleTemp:TestChangeGrass(Name, Panel)
  local a = require("Common.Coroutine.async")
  local au = require("Common.Coroutine.async_util")
  au.Launch(a.task(function()
    a.wait(au.DelaySeconds(1))
    local UKismetSystemLibrary = UE4.UKismetSystemLibrary
    local FVector = UE4.FVector
    local TArray = UE4.TArray
    local TMap = UE4.TMap
    local UNRCStatics = UE4.UNRCStatics
    local absPlayerPos = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER).viewObj:Abs_K2_GetActorLocation()
    local playerPos = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER).viewObj:K2_GetActorLocation()
    local searchExtent = FVector(250, 250, 750)
    local World = _G.UE4Helper.GetCurrentWorld()
    local foliageActors = UE4.UGameplayStatics.GetAllActorsOfClass(World, UE.AInstancedFoliageActor)
    local landscapeProxies = UE4.UGameplayStatics.GetAllActorsOfClass(World, UE.ALandscapeProxy)
    local validHismFromFoliageActors = TArray(UE.UHierarchicalInstancedStaticMeshComponent)
    local validHismFromLandscapeProxies = TArray(UE.UHierarchicalInstancedStaticMeshComponent)
    local sourcePathToTargetPath = TMap("", "")
    for i, v in ipairs(BattleConst.GrassChangeTypes) do
      sourcePathToTargetPath:Add(v.sourceSmPath, v.targetSmPath)
    end
    UNRCStatics.CollectNearbyBattleGrassHism(playerPos, absPlayerPos, searchExtent, sourcePathToTargetPath, foliageActors, landscapeProxies, validHismFromFoliageActors, validHismFromLandscapeProxies)
    local foliageHismToTargetStaticMeshPath = TMap(UE.UHierarchicalInstancedStaticMeshComponent, "")
    local landscapeHismToTargetStaticMeshPath = TMap(UE.UHierarchicalInstancedStaticMeshComponent, "")
    UNRCStatics.CollectNearbyBattleGrassInfo(sourcePathToTargetPath, validHismFromFoliageActors, validHismFromLandscapeProxies, foliageHismToTargetStaticMeshPath, landscapeHismToTargetStaticMeshPath)
    local foliageHismToTargetStaticMeshPathTable = foliageHismToTargetStaticMeshPath:ToTable()
    local landscapeHismToTargetStaticMeshPathTable = landscapeHismToTargetStaticMeshPath:ToTable()
    local targetStaticMeshPathSet = {}
    for k, v in pairs(foliageHismToTargetStaticMeshPathTable) do
      targetStaticMeshPathSet[v] = true
    end
    for k, v in pairs(landscapeHismToTargetStaticMeshPathTable) do
      targetStaticMeshPathSet[v] = true
    end
    local cacheAssets = {}
    Log.Error("brk start load grass asset")
    for k, v in pairs(targetStaticMeshPathSet) do
      Log.Error("brk loading static mesh: ", k)
      local ok, request, assetOrMessage = a.wait(au.LoadResource(k, 255, 255))
      if ok then
        cacheAssets[k] = assetOrMessage
      end
    end
    local foliageHismToTargetStaticMesh = TMap(UE.UHierarchicalInstancedStaticMeshComponent, UE.UStaticMesh)
    local landscapeHismToTargetStaticMesh = TMap(UE.UHierarchicalInstancedStaticMeshComponent, UE.UStaticMesh)
    local changedFoliageHism = {}
    for k, v in pairs(foliageHismToTargetStaticMeshPathTable) do
      local staticMesh = cacheAssets[v]
      if staticMesh then
        table.insert(changedFoliageHism, k)
        foliageHismToTargetStaticMesh:Add(k, staticMesh)
      end
    end
    for k, v in pairs(landscapeHismToTargetStaticMeshPathTable) do
      local staticMesh = cacheAssets[v]
      if staticMesh then
        landscapeHismToTargetStaticMesh:Add(k, staticMesh)
      end
    end
    local cachedHismAndStaticMeshFromLandscape = TMap(UE.UHierarchicalInstancedStaticMeshComponent, UE.UStaticMesh)
    Log.ErrorFormat("brk set battle grass, %s HISM from foliage, %s HISM from landscape", tostring(foliageHismToTargetStaticMesh:Length()), tostring(landscapeHismToTargetStaticMesh:Length()))
    UNRCStatics.SetBattleGrassTypeWithHism(foliageHismToTargetStaticMesh, landscapeHismToTargetStaticMesh, cachedHismAndStaticMeshFromLandscape)
    a.wait(au.DelaySeconds(5))
    UNRCStatics.ResetBattleGrassTypeWithHism(foliageActors, changedFoliageHism, cachedHismAndStaticMeshFromLandscape)
  end))
end

function DebugTabBattleTemp:EnableSpeedUpNpcBattle()
  _G.EnableSpeedUpEnterBattle = true
end

function DebugTabBattleTemp:DisableSpeedUpNpcBattle()
  _G.EnableSpeedUpEnterBattle = false
end

function DebugTabBattleTemp:DisableSpeedUpBattleLoad()
  _G.DisableSpeedUpBattleLoad = true
end

function DebugTabBattleTemp:EnableSpeedUpBattleLoad()
  _G.DisableSpeedUpBattleLoad = false
end

function DebugTabBattleTemp:EnableSpeedUpPVPBattleLoad()
  _G.EnableSpeedUpEnterPVPBattle = true
end

function DebugTabBattleTemp:DisableSpeedUpPVPBattleLoad()
  _G.EnableSpeedUpEnterPVPBattle = false
end

function DebugTabBattleTemp:EnableBeastCG(Name, Panel)
  _G.DebugBeastCG = true
end

function DebugTabBattleTemp:DisableBeastCG(Name, Panel)
  _G.DebugBeastCG = false
end

function DebugTabBattleTemp:ReplaceToWeekBattle(Name, Panel)
  _G.DebugTeamScenePath = "/Game/ArtRes/Level/Editor/Indoor/A2/L_Indoor_A2_04_LM"
end

function DebugTabBattleTemp:ReplaceToEmptyScene(Name, Panel)
  _G.DebugTeamScenePath = ""
end

function DebugTabBattleTemp:ReplaceToTeamScene(Name, Panel)
  _G.DebugTeamScenePath = nil
end

function DebugTabBattleTemp:WeeklyBattleTest(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.SendZoneWeeklyChallengeCreateBattleReq)
end

function DebugTabBattleTemp:CreateBattle(Name, Panel)
  if Panel then
    local inputText = Panel.InputBox:GetText()
    if nil == inputText then
      return
    end
    local BattleId = tonumber(inputText)
    local BattleCenterDebugManager = require("NewRoco/Editor/BattleCenterDebug/BattleCenterDebugManager")
    if BattleCenterDebugManager then
      BattleCenterDebugManager.StartDebugBattleCenter(BattleId)
    end
  end
end

function DebugTabBattleTemp:SimulateBattle(Name, Panel)
  if Panel then
    local inputText = Panel.InputBox:GetText()
    if nil == inputText then
      return
    end
    local BattleId = tonumber(inputText)
    local BattleCenterDebugManager = require("NewRoco/Editor/BattleCenterDebug/BattleCenterDebugManager")
    if BattleCenterDebugManager then
      BattleCenterDebugManager.SimulateBattle(BattleId)
    end
  end
end

function DebugTabBattleTemp:OpenTwoPetDialogueCamera(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.B1FinalBattleModuleCmd.OpenTwoPetDialogueCamera)
end

function DebugTabBattleTemp:CloseTwoPetDialogueCamera(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.B1FinalBattleModuleCmd.ClearDialogueCamera)
end

function DebugTabBattleTemp:TestInjectRandomPetDataInTeam(Name, Panel)
  if Panel then
    local inputText = Panel.InputBox:GetText()
    if nil == inputText then
      inputText = "0"
    end
    local stringList = string.Split(inputText, " ")
    local petTeamInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
    local PetUtils = require("NewRoco.Utils.PetUtils")
    local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petTeamInfoList, Enum.PlayerTeamType.PTT_PVP_BATTLE_4)
    if teamInfo then
      local mainTeamIndex = teamInfo and (teamInfo.main_team_idx or 0) + 1
      local petTeamInfo = teamInfo and teamInfo.teams[mainTeamIndex]
      local petInfoList = petTeamInfo and petTeamInfo.pet_infos or {}
      local petInfoListWithOutRandomPet = {}
      for i, petInfo in ipairs(petInfoList) do
        local petTypeInfoType = petInfo and petInfo.type and petInfo.type.type
        if petTypeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
        else
          table.insert(petInfoListWithOutRandomPet, petInfo)
        end
      end
      if petTeamInfo then
        petTeamInfo.pet_infos = petInfoListWithOutRandomPet
      end
      petInfoList = petTeamInfo and petTeamInfo.pet_infos or {}
      for i, bloodString in ipairs(stringList) do
        local bloodId = tonumber(bloodString)
        local petInfoItem = {
          type = {
            type = ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM,
            param = bloodId
          }
        }
        if #petInfoList < 6 then
          table.insert(petInfoList, petInfoItem)
        end
      end
    end
  end
end

function DebugTabBattleTemp:TestModifyBattleOnLookerAtRuntime(Name, Panel)
  local inputText = "0"
  if Panel and Panel.isshowabbrevia then
    inputText = Panel and Panel.AbbreInputBox:GetText() or "0"
  else
    inputText = Panel and Panel.InputBox:GetText() or "0"
  end
  local inputNumber = tonumber(inputText)
  local BattlePawnManager = _G.BattleManager.battlePawnManager
  local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
  local BattleNpc = require("NewRoco.Modules.Core.Battle.Entity.BattleNpc")
  local initInfo = BattleUtils.GetBattleInitInfo()
  if not initInfo.onlooker_a then
    initInfo.onlooker_a = {}
  end
  if not initInfo.onlooker_b then
    initInfo.onlooker_b = {}
  end
  local battleOnLookerListA = initInfo.onlooker_a
  local battleOnLookerListB = initInfo.onlooker_b
  local onLookerDataList = {}
  for i, battleOnLooker in ipairs(battleOnLookerListB) do
    local battleOnLookerCopy = {}
    table.copy(battleOnLooker, battleOnLookerCopy)
    battleOnLookerCopy.id = battleOnLookerCopy.id + os.time() * 20 + i + #battleOnLookerListA
    local attachPoint = BattleNpc.IndexToAttachPointEnumB[i]
    local npcData = {
      type = BattleNpc.Type.SingleOnLooker,
      npcInfo = battleOnLookerCopy
    }
    local onLookerData = {
      type = BattlePawnManager.BattleOnLookerType.Npc,
      npcData = npcData,
      attachPoint = attachPoint
    }
    table.insert(onLookerDataList, onLookerData)
  end
  local appearanceInfo1 = {
    fashion_id = {},
    salon_item_data = {}
  }
  local fashionInfo1 = {
    uin = 10001,
    pos = 1,
    gender = ProtoEnum.ESexValue.SEX_MALE,
    appearance_info = appearanceInfo1
  }
  local fashionIds = {
    2070220101,
    21002201,
    21102201,
    21302201,
    20802201,
    21202201,
    32500101
  }
  local salonIds = {
    {color_wear_id = 0, item_wear_id = 77},
    {color_wear_id = 0, item_wear_id = 109},
    {color_wear_id = 0, item_wear_id = 134},
    {color_wear_id = 0, item_wear_id = 157},
    {color_wear_id = 0, item_wear_id = 141},
    {color_wear_id = 0, item_wear_id = 153}
  }
  local appearanceInfo2 = {fashion_id = fashionIds, salon_item_data = salonIds}
  local fashionInfo2 = {
    uin = 10002,
    pos = 2,
    gender = ProtoEnum.ESexValue.SEX_FEMALE,
    appearance_info = appearanceInfo2
  }
  local appearanceInfo3 = {
    fashion_id = {},
    salon_item_data = {}
  }
  local fashionInfo3 = {
    uin = 10003,
    pos = 3,
    gender = ProtoEnum.ESexValue.SEX_FEMALE,
    appearance_info = appearanceInfo3
  }
  local fashionInfoList = {}
  if 1 == inputNumber then
    fashionInfoList = {fashionInfo1}
  elseif 2 == inputNumber then
    fashionInfoList = {fashionInfo2}
  elseif 3 == inputNumber then
    fashionInfoList = {fashionInfo3}
  elseif 4 == inputNumber then
    fashionInfoList = {fashionInfo1, fashionInfo3}
  elseif 5 == inputNumber then
    fashionInfoList = {
      fashionInfo1,
      fashionInfo2,
      fashionInfo3
    }
  end
  for i, fashionInfo in ipairs(fashionInfoList) do
    local attachPoint = BattleNpc.IndexToAttachPointEnumA[fashionInfo.pos]
    local uin = fashionInfo and fashionInfo.uin or 0
    local inspectorData = {uin = uin, fashionInfo = fashionInfo}
    local onLookerData = {
      type = BattlePawnManager.BattleOnLookerType.PlayerInspector,
      playerInspectorData = inspectorData,
      attachPoint = attachPoint
    }
    table.insert(onLookerDataList, onLookerData)
  end
  local notify = {
    observer_num = 0,
    leave_observer = {},
    enter_observer = {},
    observer_appearance_info = fashionInfoList
  }
  _G.BattleManager:OnBattleObserverChangeNotify(notify)
end

function DebugTabBattleTemp:TogglePvpRankCheckBox()
  local SystemSettingModule = _G.NRCModuleManager:GetModule("SystemSettingModule")
  local SystemSettingModuleData = SystemSettingModule and SystemSettingModule.data
  local playerSettings = SystemSettingModuleData and SystemSettingModuleData.playerSettings
  if playerSettings then
    local pvpSetting = playerSettings and playerSettings.pvp
    if not pvpSetting then
      pvpSetting = {}
      pvpSetting.open_rank = false
      playerSettings.pvp = pvpSetting
    end
    if pvpSetting then
      pvpSetting.open_rank = not pvpSetting.open_rank
    end
    Log.Warning("pvpSetting.open_rank", pvpSetting and pvpSetting.open_rank)
    local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
    _G.NRCEventCenter:DispatchEvent(SystemSettingModuleEvent.PlayerSettingUpdate)
  else
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqQueryPlayerSettings)
  end
end

function DebugTabBattleTemp:RefreshBattleTutorialGuide()
  _G.NRCModuleManager:DoCmd(_G.BattleTutorialGuideModuleCmd.RefreshGuideData)
end

function DebugTabBattleTemp:ClearBattleTutorialGuide()
  _G.NRCModuleManager:DoCmd(_G.BattleTutorialGuideModuleCmd.ClearGuide, "SimulatedGroup_1")
end

function DebugTabBattleTemp:OnBattleTutorialGuide(name, panel, InputText)
  local Text
  if panel then
    Text = panel.InputBox:GetText()
  else
    Text = InputText
  end
  if Text then
    local num = tonumber(Text)
    if num and type(num) == "number" then
      _G.NRCModuleManager:DoCmd(_G.BattleTutorialGuideModuleCmd.EnterGuide, num)
    else
      _G.NRCModuleManager:DoCmd(_G.BattleTutorialGuideModuleCmd.EnterGuide, "SimulatedGroup_1")
    end
  else
    _G.NRCModuleManager:DoCmd(_G.BattleTutorialGuideModuleCmd.EnterGuide, "SimulatedGroup_1")
  end
end

function DebugTabBattleTemp:TestTerritoryPrepareToBattle(name, panel)
  local inputText = ""
  if panel and panel.isshowabbrevia then
    inputText = panel and panel.AbbreInputBox:GetText() or ""
  else
    inputText = panel and panel.InputBox:GetText() or ""
  end
  local petIdStr, toPosStr = table.unpack(string.split(inputText, " "))
  local petId = tonumber(petIdStr)
  local toPos = tonumber(toPosStr)
  local BattlePrepareToBattlePlayer = require("NewRoco.Modules.Core.Battle.Players.BattlePrepareToBattlePlayer")
  local player = BattlePrepareToBattlePlayer()
  local pawnManager = _G.BattleManager.battlePawnManager
  local battleCard = pawnManager:GetCardByGuid(petId)
  if battleCard then
    battleCard:SetInBattleField(true)
    battleCard.pos = toPos
    battleCard.posInField = toPos
  end
  player.prepare_to_battle = {pet_id = petId, to_pos = toPos}
  player:Play()
end

function DebugTabBattleTemp:TestTerritoryBagToPrepare(name, panel)
  local inputText = ""
  if panel and panel.isshowabbrevia then
    inputText = panel and panel.AbbreInputBox:GetText() or ""
  else
    inputText = panel and panel.InputBox:GetText() or ""
  end
  local petIdStr, toPosStr = table.unpack(string.split(inputText, " "))
  local petId = tonumber(petIdStr)
  local toPos = tonumber(toPosStr)
  local BattleBagToPreparePlayer = require("NewRoco.Modules.Core.Battle.Players.BattleBagToPreparePlayer")
  local player = BattleBagToPreparePlayer()
  local pawnManager = _G.BattleManager.battlePawnManager
  local battleCard = pawnManager:GetCardByGuid(petId)
  local petState = battleCard and battleCard.petState
  if battleCard then
    battleCard:SetInBattleField(true)
    battleCard.pos = toPos
    battleCard.posInField = toPos
  end
  player.bag_to_prepare = {pet_id = petId, to_pos = toPos}
  player:Play()
end

function DebugTabBattleTemp:TestSkillByPath(name, panel)
  Log.Warning("TestSkillByPath")
  local testSkill = "/Game/ArtRes/Effects/G6Skill/Jineng/G6_Nor_nlhj_200004"
  BattleResourceManager:LoadClassAsync(self, testSkill, self.OnSkillLoad)
end

function DebugTabBattleTemp:OnSkillLoad(skillClass)
  local testPet = _G.BattleManager.battlePawnManager:GetFirstPet(BattleEnum.Team.ENUM_TEAM)
  Log.Warning("TestSkillByPath", testPet, testPet.model)
  if testPet and testPet.model then
    local skillObj = testPet.model.RocoSkill:AddSkillObjFromClassAndReturn(skillClass)
    skillObj:SetCaster(testPet.model)
    skillObj:SetTargets({
      testPet.model
    })
    skillObj:FastAsyncLoading()
    skillObj.OnAsyncLoadCompleted:Add(testPet.model, self.OnAsyncLoad)
  end
end

function DebugTabBattleTemp:OnAsyncLoad(skillObj)
  Log.Warning("OnAsyncLoad")
  local testPet = _G.BattleManager.battlePawnManager:GetFirstPet(BattleEnum.Team.ENUM_TEAM)
  testPet.model.RocoSkill:PlaySkill(skillObj)
end

return DebugTabBattleTemp
