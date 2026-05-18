local ThrowSession = require("NewRoco.Modules.Core.NPC.ThrowSession")
local ThrowStarSession = require("NewRoco.Modules.Core.NPC.MagicStar.ThrowStarSession")
local ThrowVisualizationComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.ThrowVisualizationComponent")
local BP_NPCItemBase_C = require("NewRoco.Modules.Core.NPC.PetBall.BP_NPCItemBase_C")
local CivilCalculator = require("NewRoco.Modules.Core.Scene.Common.CivilCalculator")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local SceneNpc = require("NewRoco.Modules.Core.Scene.Actor.SceneNpc")
local EndThrowAbility = require("NewRoco.Modules.Core.Scene.Component.Ability.ThrowAbility.EndThrowAbility")
local SummonPetComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.SummonPetComponent")
local ThrowFakeSession = require("NewRoco.Modules.Core.NPC.MagicStar.ThrowFakeSession")
local DebugTabThrow = Base:Extend("DebugTabThrow")

function DebugTabThrow:Ctor()
  Base.Ctor(self)
end

function DebugTabThrow:SetupTabs()
  self:Add("\232\135\170\229\138\168\232\191\189\232\184\170\230\140\135\229\174\154NPC", self.OpenAutoHoming2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenAutoHoming")
  self:Add("\229\134\178\230\146\158\228\186\164\228\186\146", self.PowerDash, self)
  self:Add("\230\152\190\231\164\186/\233\154\144\232\151\143\231\148\187\233\157\162\228\184\173\229\191\131\229\141\129\229\173\151", self.ShowCenterCrossInScreen, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128")
  self:Add("\230\149\153\231\187\131\230\136\145\232\166\129\230\137\147\231\144\131", self.PlayBall, self)
  self:Add("\229\188\128\229\133\179\230\138\149\230\142\183\228\186\164\228\186\146Debug", self.TogglePetInteractDebug, self)
end

function DebugTabThrow:DropItemOnNPCHead(name, panel)
  Log.Debug("DebugTabThrow:DropItemOnNPCHead")
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    local location = npc:GetActorLocation()
    local Point = ProtoMessage:newPoint()
    Point.pos.x = math.round(location.X)
    Point.pos.y = math.round(location.Y)
    Point.pos.z = math.round(location.Z + 500)
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.npc_cfg_id = 50021
    req.npc_pos = Point
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req)
  end
end

function DebugTabThrow:ShowCollision(name, panel)
  self:ConsoleCommand("show Collision")
end

function DebugTabThrow:BatchRecall(name, panel)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  for v, _ in pairs(NPCModule.localPets) do
    local petView = v.viewObj
    petView:FlyBackToPlayer()
  end
  table.clear(NPCModule.localPets)
end

function DebugTabThrow:RemoveOneNPC(name, panel)
  local npc = self:GetNearestNpc()
  npc.DisappearSkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/G6_Scene_Caiji_Com"
  npc:Disappear()
end

function DebugTabThrow:ShowLocalBalls(name, panel)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local Balls = {}
  for Ball, Status in pairs(NPCModule.ThrowSessionManager.localBalls) do
    table.insert(Balls, Ball)
  end
  self:Inspect(Balls, "\230\156\172\229\156\176\229\146\149\229\153\156\231\144\131")
end

function DebugTabThrow:ShowLocalPets(name, panel)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local List = {}
  for pet, _ in pairs(NPCModule.ThrowSessionManager.localPets) do
    table.insert(List, pet)
  end
  self:Inspect(List, "\230\156\172\229\156\176\231\178\190\231\129\181")
end

function DebugTabThrow:MarkClosestNPC(name, panel)
  local NPC = self:GetNearestNpc()
  NPC.Watch = true
  self:ShowTips("\229\183\178\231\187\143\230\160\135\232\174\176" .. NPC:DebugNPCNameAndID())
  if panel then
    panel:DoClose()
  end
end

function DebugTabThrow:ShowThrowTrajectory(name, panel)
  ThrowSession.ToggleShowTrajectory(true)
  ThrowStarSession.ShowTrajectory = true
end

function DebugTabThrow:CloseThrowTrajectory(name, panel)
  ThrowSession.ToggleShowTrajectory(false)
  ThrowStarSession.ShowTrajectory = false
end

function DebugTabThrow:PreThrowTrajectory(name, panel)
  GlobalConfig.ShowPreThrowTrajectory = not GlobalConfig.ShowPreThrowTrajectory
end

function DebugTabThrow:ShowCatchRate(name, panel)
  GlobalConfig.ShowCatchRate = not GlobalConfig.ShowCatchRate
end

function DebugTabThrow:ShowShakeHaltRate(name, panel)
  GlobalConfig.ShowShakeHaltRate = not GlobalConfig.ShowShakeHaltRate
end

function DebugTabThrow:ChangeCatchRate(name, panel, InputNumber)
  if SceneUtils.debugOpenChangeCatchRate == false then
    SceneUtils.debugOpenChangeCatchRate = true
  end
  if panel then
    SceneUtils.debugCatchRate = panel:GetInputNumber(0)
  else
    SceneUtils.debugCatchRate = tonumber(InputNumber) or 0
  end
end

function DebugTabThrow:EnablePhysics(name, panel)
  BP_NPCItemBase_C.ToggleSimulate(true)
end

function DebugTabThrow:DisablePhysics(name, panel)
  BP_NPCItemBase_C.ToggleSimulate(false)
end

function DebugTabThrow:SetLinearDamping(name, panel, InputNumber)
  local value
  if panel then
    value = panel:GetInputNumber()
  else
    value = tonumber(InputNumber)
  end
  BP_NPCItemBase_C.SetLinearDamping(value)
end

function DebugTabThrow:SetAngularDamping(name, panel, InputNumber)
  local value
  if panel then
    value = panel:GetInputNumber()
  else
    value = tonumber(InputNumber)
  end
  BP_NPCItemBase_C.SetAngularDamping(value)
end

function DebugTabThrow:SetBounciness(name, panel, InputNumber)
  local value
  if panel then
    value = panel:GetInputNumber()
  else
    value = tonumber(InputNumber)
  end
  Log.Error("BP_NPCItemBase_C.SetProjectileBounciness \229\183\178\231\187\143\230\152\175\231\186\175\233\133\141\231\189\174\228\186\134\239\188\140\229\143\175\228\187\165\229\142\187\230\148\185\232\161\168\230\156\172\229\156\176\229\175\188\232\161\168")
end

function DebugTabThrow:SetFriction(name, panel, InputNumber)
  local value
  if panel then
    value = panel:GetInputNumber()
  else
    value = tonumber(InputNumber)
  end
  Log.Error("BP_NPCItemBase_C.SetProjectileFriction \229\183\178\231\187\143\230\152\175\231\186\175\233\133\141\231\189\174\228\186\134\239\188\140\229\143\175\228\187\165\229\142\187\230\148\185\232\161\168\230\156\172\229\156\176\229\175\188\232\161\168")
end

function DebugTabThrow:ShowBallCount(name, panel)
  local Count = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetThrowBagItemCount, 1)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local Balls = {}
  local Display = {Count = Count, Balls = Balls}
  for Ball, _ in pairs(NPCModule.localBalls) do
    table.insert(Balls, Ball.ThrowSession)
  end
  self:Inspect(Display, "Ball Count")
end

function DebugTabThrow:EnableTrialDisturb(name, panel)
  BP_NPCItemBase_C.EnableTrailDisturb(true)
end

function DebugTabThrow:DisableTrialDisturb(name, panel)
  BP_NPCItemBase_C.EnableTrailDisturb(false)
end

function DebugTabThrow:SetBouncinessDisturb(name, panel, InputNumber)
  local value
  if panel then
    value = panel:GetInputNumber()
  else
    value = tonumber(InputNumber)
  end
  Log.Error("BP_NPCItemBase_C.SetProjectileBouncinessDisturb \229\183\178\231\187\143\230\152\175\231\186\175\233\133\141\231\189\174\228\186\134\239\188\140\229\143\175\228\187\165\229\142\187\230\148\185\232\161\168\230\156\172\229\156\176\229\175\188\232\161\168")
end

function DebugTabThrow:SetFrictionDisturb(name, panel, InputNumber)
  local value
  if panel then
    value = panel:GetInputNumber()
  else
    value = tonumber(InputNumber)
  end
  Log.Error("BP_NPCItemBase_C.SetProjectileFrictionDisturb \229\183\178\231\187\143\230\152\175\231\186\175\233\133\141\231\189\174\228\186\134\239\188\140\229\143\175\228\187\165\229\142\187\230\148\185\232\161\168\230\156\172\229\156\176\229\175\188\232\161\168")
end

function DebugTabThrow:EnableEQSTrace(name, panel)
  local input = self:GetInputString()
  if string.IsNilOrEmpty(input) then
    input = "EnvQueryTrace"
  end
  UE4.UNRCStatics.SetWorldDebugTraceTag(_G.UE4Helper.GetCurrentWorld(), input)
end

function DebugTabThrow:CalcCivil(name, panel)
  local NewCalculator = CivilCalculator()
  Log.Error("Current Civil Value", NewCalculator:Calculate())
  local Player = self:GetPlayer()
  Log.Error("Current Player Aura Temperature", Player.AuraComponent:GetTemperature())
end

function DebugTabThrow:StartDebugCivil(name, panel)
  CivilCalculator.ToggleDebug(true)
end

function DebugTabThrow:StopDebugCivil(name, panel)
  CivilCalculator.ToggleDebug(false)
end

function DebugTabThrow:OpenYawLimit(name, panel)
  GlobalConfig.YawLimit.UseLimit = not GlobalConfig.YawLimit.UseLimit
end

function DebugTabThrow:SetYawLimitMin(name, panel, InputNumber)
  if panel then
    GlobalConfig.YawLimit.yaw_min = panel:GetInputNumber()
  else
    GlobalConfig.YawLimit.yaw_min = tonumber(InputNumber)
  end
end

function DebugTabThrow:SetYawLimitMax(name, panel, InputNumber)
  if panel then
    GlobalConfig.YawLimit.yaw_max = panel:GetInputNumber()
  else
    GlobalConfig.YawLimit.yaw_max = tonumber(InputNumber)
  end
end

function DebugTabThrow:ShowBallFlyTime()
  GlobalConfig.EnableShowBallFlyTime = not GlobalConfig.EnableShowBallFlyTime
end

function DebugTabThrow:ShowAllActivePet(name, panel)
  self:Inspect(ThrowSession.ActivePetSessions, "Sessions")
end

function DebugTabThrow:ShowPetBallCollision(Name, Panel)
  ThrowSession.DebugHits = true
end

function DebugTabThrow:ClosePetBallCollision(Name, Panel)
  ThrowSession.DebugHits = false
end

function DebugTabThrow:OpenVisibilityCheckVisualization(Name, Panel)
  SceneNpc.ToggleInteractionCheck(true)
end

function DebugTabThrow:CloseVisibilityCheckVisualization(Name, Panel)
  SceneNpc.ToggleInteractionCheck(false)
end

function DebugTabThrow:OpenAutoHoming(Name, Panel)
  SceneUtils.SetAutoHoming(true)
end

function DebugTabThrow:OpenAutoHoming2(Name, Panel)
  local TargetID = Panel and Panel:GetInputNumber()
  self:OpenAutoHomingWithID(TargetID)
end

function DebugTabThrow:OpenAutoHomingWithID(TargetID)
  TargetID = TargetID or 0
  TargetID = tonumber(TargetID) or 0
  if TargetID and 0 ~= TargetID then
    local NPCs = self:GetModule("NPCModule")._npcDic
    for _, NPC in pairs(NPCs) do
      if NPC.serverData.base.actor_id == TargetID then
        Log.Error("\232\174\190\231\189\174\232\135\170\229\138\168\232\191\189\232\184\170\231\155\174\230\160\135", NPC:DebugNPCNameAndID())
        SceneUtils.SetAutoHomingTargetID(NPC:GetServerId())
        break
      elseif NPC.serverData.npc_base.npc_cfg_id == TargetID then
        Log.Error("\232\174\190\231\189\174\232\135\170\229\138\168\232\191\189\232\184\170\231\155\174\230\160\135", NPC:DebugNPCNameAndID())
        SceneUtils.SetAutoHomingTargetID(NPC:GetServerId())
        break
      elseif NPC.serverData.npc_base.npc_content_cfg_id == TargetID then
        Log.Error("\232\174\190\231\189\174\232\135\170\229\138\168\232\191\189\232\184\170\231\155\174\230\160\135", NPC:DebugNPCNameAndID())
        SceneUtils.SetAutoHomingTargetID(NPC:GetServerId())
        break
      end
    end
  end
  SceneUtils.SetAutoHoming(true)
end

function DebugTabThrow:CloseAutoHoming(Name, Panel)
  SceneUtils.SetAutoHoming(false)
end

function DebugTabThrow:SummonPet(Name, Panel)
  local GID = NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  local Player = self:GetPlayer()
  local Comp = Player:EnsureComponent(SummonPetComponent)
  Comp:SummonWithGID(GID, nil, self, self.Summon)
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabThrow:Summon(Success)
  Log.Error("Summon", Success)
end

function DebugTabThrow:RecallPet(Name, Panel)
  local GID = NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  local Player = self:GetPlayer()
  local Comp = Player:EnsureComponent(SummonPetComponent)
  Comp:Recall(GID, false, self, self.Recall)
  if Panel then
    Panel:DoClose()
  end
end

function DebugTabThrow:Recall(Success)
  Log.Error("Recall", Success)
end

local npc_index = 0

function DebugTabThrow:CatchWithNormalBall()
  gid = 1
  self:OneForAll()
end

function DebugTabThrow:CatchWithGreatGuruBall()
  gid = 5
  self:OneForAll()
end

function DebugTabThrow:OneForAll()
  npc_index = npc_index + 1
  local session = ThrowFakeSession()
  session:BeginThrow(npc_index)
end

function DebugTabThrow:RotateOwl(Name, Panel)
  local MaybeOwl = self:GetNearestNpc()
  local Player = self:GetPlayer()
  if MaybeOwl.viewObj and MaybeOwl.viewObj.TurnAndOpen then
    MaybeOwl.viewObj:TurnAndOpen(Player.viewObj:K2_GetActorLocation())
    self:ClosePanel()
  else
    self:ShowTips("\230\156\128\232\191\145\231\154\132NPC\228\184\141\230\152\175\231\156\160\230\158\173\233\155\149\229\131\143")
  end
end

function DebugTabThrow:AddInteractionQuantity(Name, Panel)
  local npc = self:GetNearestNpc()
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = ProtoEnum.SceneGmType.SGT_INTERACTION_QUANTITY
  req.gm_op_type = ProtoEnum.SceneGmOpType.SGOT_SET
  req.uin = 0
  req.param1 = npc.serverData.pet_info.gid
  req.param2 = 100
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, self, nil, false, false)
end

function DebugTabThrow:PowerDash(Name, Panel)
  local NPC = self:GetNearestNpc()
  if not NPC then
    self:ShowTips("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
    return
  end
  local InterComp = NPC.InteractionComponent
  if not InterComp then
    self:ShowTips(string.format("\230\178\161\230\156\137\228\186\164\228\186\146\231\187\132\228\187\182%s", NPC:DebugNPCNameAndID()))
    return
  end
  local Option = InterComp:GetPowerDashOption()
  if not Option then
    return
  end
  Option:SendPowerDashReq(_G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid))
  self:ClosePanel()
end

function DebugTabThrow:ShowCenterCrossInScreen()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowCenterRedCross)
end

function DebugTabThrow:PlayBall(Name, Panel)
  if Panel then
    local Numbers = Panel:GetInputNumbers()
    local Y = Numbers and Numbers[1] or 0 or 0
    local Z = Numbers and Numbers[2] or -1 or -1
    _G.GlobalConfig.PlayBall = true
    _G.GlobalConfig.SpinBall = UE.FVector(0, Y, Z)
    Log.Error("Play Ball!!!!", Y, Z)
  else
    Log.Error("\230\136\145\231\156\139\228\189\160\232\191\152\230\152\175\229\136\171\230\137\147\228\186\134")
  end
end

function DebugTabThrow:TogglePetInteractDebug()
  _G.GlobalConfig.DebugPetInteract = not _G.GlobalConfig.DebugPetInteract
  if _G.GlobalConfig.DebugPetInteract then
    Log.Error("\229\183\178\229\188\128\229\144\175\231\178\190\231\129\181\228\186\164\228\186\146Debug")
  else
    Log.Error("\229\183\178\229\133\179\233\151\173\231\178\190\231\129\181\228\186\164\228\186\146Debug")
  end
end

return DebugTabThrow
