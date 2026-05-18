local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneAIUtils = require("NewRoco.AI.SceneAIUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = ViewNPCBase
local BP_NPCMagicLightBall_C = Base:Extend("BP_NPCMagicLightBall_C")
local FLY_PATH_CHECK_TIME = 0.1

function BP_NPCMagicLightBall_C:Init()
  Base.Init(self)
  self.MagicID = 0
  self.ChargeLevel = 0
  self.ChargeProcess = 0
  self.RevealRange = 0
  self.MaxDistance = 0
  self.MaxSpeed = 0
  self.BoomRevealRange = 0
  self.CurFlyTime = 0
  self.FlyTime = 0
  self.FlyPathTime = 0
  self.MagicBaseConfig = nil
end

function BP_NPCMagicLightBall_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.bIsBroken = false
  self:InitMagicBaseConfig()
  self.NS_Scene_LightMagic_Zhuti:ReinitializeSystem()
  self:SetChargeLevel(1)
  self:SetChargeProcess(0)
end

function BP_NPCMagicLightBall_C:SetChargeProcess(Percent)
  self.ChargeProcess = Percent
end

function BP_NPCMagicLightBall_C:SetChargeLevel(Level)
  self.ChargeLevel = Level
  self:SetChargeProcess(0)
end

function BP_NPCMagicLightBall_C:InitMagicBaseConfig()
  local ThrowItemInfo = _G.DataModelMgr.PlayerDataModel:GetThrowItemInfo()
  if ThrowItemInfo then
    local MagicGid = ThrowItemInfo.cur_selected_magic_item_gid
    if MagicGid then
      local MagicItemInfo = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, MagicGid)
      if MagicItemInfo then
        local PlayerMagicConf = _G.DataConfigManager:GetBagItemConf(MagicItemInfo.id)
        if PlayerMagicConf then
          self.MagicBaseConfig = _G.DataConfigManager:GetMagicBaseConf(PlayerMagicConf.magic_id)
          self.MagicID = PlayerMagicConf.magic_id
        end
      end
    end
  end
end

function BP_NPCMagicLightBall_C:InitMagicInfo()
  if self.MagicBaseConfig then
    self.RevealRange = SceneAIUtils.ParseMagicParamByLevel(self.MagicBaseConfig, self.ChargeLevel - 1, self.ChargeProcess, 0, 4)
    self.MaxDistance = SceneAIUtils.ParseMagicParamByLevel(self.MagicBaseConfig, self.ChargeLevel - 1, self.ChargeProcess, 1, 4)
    self.MaxSpeed = SceneAIUtils.ParseMagicParamByLevel(self.MagicBaseConfig, self.ChargeLevel - 1, self.ChargeProcess, 2, 4)
    self.BoomRevealRange = SceneAIUtils.ParseMagicParamByLevel(self.MagicBaseConfig, self.ChargeLevel - 1, self.ChargeProcess, 3, 4)
    self.FlyTime = self.MaxDistance / self.MaxSpeed
  end
end

function BP_NPCMagicLightBall_C:OnThrowStart()
  if not self.ThrowSession.is_local then
    if _G.BattleManager.isInBattle then
      _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowStar, self.sceneCharacter)
      return
    end
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, self.ThrowSession.owner_id)
    if Player and Player.viewObj and Player.viewObj:GetActorHidden() then
      _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowStar, self.sceneCharacter)
      return
    end
  end
  self.throwStarted = true
  local Root = self:K2_GetRootComponent()
  Root:SetSimulatePhysics(false)
  self.ProjectileMovement:SetUpdateMovingDistanceEnable(true)
  self.ProjectileMovement:SetUpdatedComponent(Root)
  self.ProjectileMovement:Activate(true)
  if self.ThrowSession.is_local then
    self.ThrowSession:OnBeginThrow()
  end
  _G.UpdateManager:Register(self)
  self:InitMagicInfo()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerCameraManager = Player:GetUEController().PlayerCameraManager
  self.BeginPos = PlayerCameraManager:GetCameraLocation()
  if self.Sphere:IsA(UE.USphereComponent) then
    self.Sphere.OnComponentBeginOverlap:Add(self, self.OnActionAreaOverlap)
  end
end

function BP_NPCMagicLightBall_C:OnActionAreaOverlap(SelfComp, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, Result)
  local OtherSceneCharacter = OtherActor.sceneCharacter
  if not OtherSceneCharacter then
    return
  end
  local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
  if not SceneModule then
    return
  end
  if not SceneModule:CheckIsNpc(OtherSceneCharacter:GetServerId()) then
    return
  end
  local SelfMoved = true
  local HitLocation = Result.ImpactPoint
  local HitNormal = Result.ImpactNormal
  local NormalImpulse = -HitNormal
  self:ReceiveHit(SelfComp, OtherActor, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Result)
end

function BP_NPCMagicLightBall_C:ReceiveHit(MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  self.ProjectileMovement:Bounce(Hit)
  self:SetFlyEnd()
end

function BP_NPCMagicLightBall_C:SetInitialVelocity(InitVelocity)
  self.ProjectileMovement:SetInitSpeed(InitVelocity)
  self.ProjectileMovement.InitHeight = self:Abs_K2_GetActorLocation().Z
end

function BP_NPCMagicLightBall_C:SetFlyEnd()
  _G.UpdateManager:UnRegister(self)
  self.ProjectileMovement:SetUpdateMovingDistanceEnable(false)
  self.ProjectileMovement:Activate(false)
  self:BreakItself()
  if self.Sphere:IsA(UE.USphereComponent) then
    self.Sphere.OnComponentBeginOverlap:Remove(self, self.OnActionAreaOverlap)
  end
end

function BP_NPCMagicLightBall_C:BreakItself()
  if self.bIsBroken then
    return
  end
  self.bIsBroken = true
  self.NS_Scene_LightMagic_Zhuti:SetHiddenInGame(true)
  if self.RocoSkill then
    self.RocoSkill:StopCurrentSkill()
    local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/StarMagic/G6_LightMagic_Hit", self.RocoSkill, PriorityEnum.Active_Player_Action)
    if not Skill then
      self:OnFinishBreakBall()
      return
    end
    Skill:SetCaster(self)
    Skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
    Skill:RegisterEventCallback("PreEnd", self, self.OnFinishBreakBall)
    Skill:PlaySkill(self, self.OnSkillCallBack)
  else
    self:OnFinishBreakBall()
  end
end

function BP_NPCMagicLightBall_C:OnSkillCallBack(SkillProxy, Result)
  if Result ~= UE4.ESkillStartResult.Success then
    self:OnFinishBreakBall()
  end
end

function BP_NPCMagicLightBall_C:OnSetupBlackboard(Name, Skill)
  if 1 == self.ChargeLevel then
    Skill.Blackboard:SetValueAsString("B1", "Hit1")
  elseif 2 == self.ChargeLevel then
    Skill.Blackboard:SetValueAsString("B2", "Hit2")
  elseif 3 == self.ChargeLevel then
    Skill.Blackboard:SetValueAsString("B3", "Hit3")
  end
end

function BP_NPCMagicLightBall_C:OnFinishBreakBall()
  if UE4.UObject.IsValid(self) then
    self:SetActorHiddenInGame(true)
  end
  if self.ThrowSession.is_local then
    self.ThrowSession:OnEndThrow()
  end
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowLightBall, self.sceneCharacter)
end

function BP_NPCMagicLightBall_C:OnTick(DeltaTime)
  if 0 ~= self.CurFlyTime and self.CurFlyTime > self.FlyTime then
    self:SetFlyEnd()
    return
  else
    self.CurFlyTime = self.CurFlyTime + DeltaTime
    self.FlyPathTime = self.FlyPathTime + DeltaTime
    if self.FlyPathTime > FLY_PATH_CHECK_TIME then
      self.FlyPathTime = 0
      self.ThrowSession:OnFlyPathReveal()
    end
  end
end

return BP_NPCMagicLightBall_C
