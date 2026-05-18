local LogicStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.LogicStatusComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = ActorComponent
local LegendaryBattleComponent = Base:Extend("LegendaryBattleComponent")

function LegendaryBattleComponent:Attach(owner)
  Base.Attach(self, owner)
  local RadiusConf = _G.DataConfigManager:GetLegendaryGlobalConfig("active_radius")
  local Radius = (RadiusConf and RadiusConf.num or 1 or 1) * 100
  self.disRangeSqr = Radius * Radius
  self.bInRange = false
  self.timeInterval = 0
  self.LastActiveState = nil
  if self.owner then
    local Comp = self.owner:EnsureComponent(LogicStatusComponent)
    SceneUtils.RegisterNPCVisibilityNotify(self, true)
    self.owner:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdate)
  end
end

function LegendaryBattleComponent:DeAttach()
  _G.UpdateManager:UnRegister(self)
  if self.owner then
    self.owner:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdate)
  end
  SceneUtils.UnregisterNPCVisibilityNotify(self)
  Base.DeAttach(self)
end

function LegendaryBattleComponent:Destroy()
  _G.UpdateManager:UnRegister(self)
end

function LegendaryBattleComponent:UpdateShadow(bDataChange)
  local Comp = self.owner:EnsureComponent(LogicStatusComponent)
  local bActivated, _, _ = Comp:GetStatus(_G.ProtoEnum.SpaceActorLogicStatus.SALS_GHOST_ACTIVE)
  if bActivated == self.LastActiveState then
    return
  end
  if bActivated then
    if true == bDataChange then
      self:PlaySkillCommon("/Game/ArtRes/Effects/G6Skill/ShenShou/G6_ShenShou_TeamBattle_XuyingEnd.G6_ShenShou_TeamBattle_XuyingEnd")
    end
  elseif true == bDataChange then
    self:PlaySkillCommon("/Game/ArtRes/Effects/G6Skill/ShenShou/G6_ShenShou_TeamBattle_XuyingOpen.G6_ShenShou_TeamBattle_XuyingOpen")
  else
    self:PlaySkillCommon("/Game/ArtRes/Effects/G6Skill/ShenShou/G6_ShenShou_TeamBattle_Xuying.G6_ShenShou_TeamBattle_Xuying")
  end
  self.LastActiveState = bActivated
end

function LegendaryBattleComponent:OnTick(deltaTime)
  self.timeInterval = self.timeInterval + deltaTime
  if self.timeInterval <= 0.5 then
    return
  end
  self.timeInterval = 0
  if not self.owner then
    return
  end
  if self.owner.isDestroy then
    return
  end
  if not self.owner.viewObj then
    return
  end
  if not self.owner.viewObj.resourceLoaded then
    return
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  local distSqr = player:DistanceTo(self.owner, false, true)
  if distSqr > self.disRangeSqr and self.bInRange then
    if self:OnZoneReportAvatarAroundNpcReq(false) then
      self.bInRange = false
    end
  elseif distSqr < self.disRangeSqr and not self.bInRange and self:OnZoneReportAvatarAroundNpcReq(true) then
    self.bInRange = true
  end
end

function LegendaryBattleComponent:OnLogicStatusUpdate()
  local View = self:GetOwnerView()
  if not View or not View.resourceLoaded then
    return
  end
end

function LegendaryBattleComponent:OnVisible()
  _G.UpdateManager:Register(self)
end

function LegendaryBattleComponent:OnInvisible()
  _G.UpdateManager:UnRegister(self)
end

function LegendaryBattleComponent:OnReConnect()
end

function LegendaryBattleComponent:PlaySkillCommon(Path)
  local OwnerView = self:GetOwnerView()
  if not OwnerView then
    return
  end
  if OwnerView.RocoSkill then
    OwnerView.RocoSkill:StopCurrentSkill()
  end
  OwnerView:PlaySkill(Path, OwnerView, nil, nil, nil, false)
end

function LegendaryBattleComponent:OnZoneReportAvatarAroundNpcReq(bInRange)
  local req = _G.ProtoMessage:newZoneSceneReportAvatarAroundNpcReq()
  req.npc_logic_id = self.owner.serverData.base.logic_id
  req.npc_obj_id = self.owner.serverData.base.actor_id
  req.enter = bInRange
  return _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_REPORT_AVATAR_AROUND_NPC_REQ, req)
end

return LegendaryBattleComponent
