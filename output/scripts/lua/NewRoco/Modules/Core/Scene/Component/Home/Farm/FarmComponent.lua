local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local ResQueue = require("NewRoco.Utils.ResQueue")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local StaticCircleArea = require("NewRoco.Modules.Core.Task.StaticCircleArea")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")
local Base = ActorComponent
local FarmComponent = Base:Extend("FarmComponent")
local G6SkillResPath = {
  [FarmModuleEnum.OptionType.Sowing] = FarmConst.SkillPath.Sowing
}

function FarmComponent:Attach(owner)
  Base.Attach(self, owner)
  self.Player = nil
  self.target_land_id = nil
  self.longTick = 0
  self.isInFarm = false
  self.skillInfo = {}
  if self.FarmDetector then
    self.FarmDetector:StopDetect()
  end
  local originLocation, originRot = FarmUtils.GetOriginTransform()
  if originLocation and originRot then
    self.FarmDetector = StaticCircleArea.MakePoint2D("FarmCompCheckRange" .. tostring(self.owner.serverData.base.logic_id), 301, originLocation.X, originLocation.Y, FarmUtils.GetFarmVisibleDist(), 200, self, self.EnterFarm, self.ExitFarm)
    self.FarmDetector:StartDetect()
  end
end

function FarmComponent:DeAttach()
  self.Player = nil
  self.target_land_id = nil
  self.longTick = 0
  self.isInFarm = false
  self.skillInfo = nil
  if self.FarmDetector then
    self.FarmDetector:StopDetect()
  end
  Base.DeAttach(self)
end

function FarmComponent:Destroy()
  Base.Destroy(self)
end

function FarmComponent:EnterFarm()
  self.longTick = 0
  self.isInFarm = true
end

function FarmComponent:ExitFarm()
  self.longTick = 0
  self.isInFarm = false
end

function FarmComponent:Update(deltaTime)
  if self.isInFarm then
    self:CheckFarmLandStandPos(deltaTime)
  end
end

function FarmComponent:CheckFarmLandStandPos(deltaTime)
  if FarmUtils.IsModuleUnlock() and self.owner.isLocal then
    if self.longTick <= 0 then
      self.longTick = 0.1
      _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.RefreshCurrentStandLandInfo)
    end
    self.longTick = self.longTick - deltaTime
  end
end

function FarmComponent:PlayingSkill(target_land_id, opType, caller, callback)
  if not self.skillInfo then
    self.skillInfo = {}
  end
  if not self.skillInfo[opType] then
    self.skillInfo[opType] = {}
    self.skillInfo[opType].started = false
    self.skillInfo[opType].is_showing = false
  end
  local skillInfo = self.skillInfo[opType]
  if skillInfo.started then
    return
  end
  if not self.owner.avatarLoaded then
    return
  end
  if self.owner.isLocal and self.owner.statusComponent then
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
  end
  if skillInfo.is_showing then
    self:OnSkillStopImmediate(opType)
  end
  skillInfo.started = true
  skillInfo.is_showing = false
  skillInfo.target_land_id = target_land_id
  skillInfo.caller = caller
  skillInfo.callback = callback
  local LoadQueue = ResQueue()
  LoadQueue:InsertObject("Wand", self.owner:GetCurWandPath(), _G.PriorityEnum.Active_Player_Action)
  LoadQueue:InsertObject("MoZhang", "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'", _G.PriorityEnum.Active_Player_Action)
  LoadQueue:StartLoad(self, self.OnPlayingSkillInternal)
  LoadQueue.opType = opType
end

function FarmComponent:OnPlayingSkillInternal(Queue, Success)
  local opType = Queue.opType or FarmModuleEnum.OptionType.Sowing
  if not Success then
    self:OnSkillStopImmediate(Queue.opType)
    Queue:Release()
    return
  end
  local caster = self:GetOwnerView()
  if caster then
    local skillComponent = caster.RocoSkill
    if skillComponent then
      local skillInfo = self.skillInfo[opType]
      local Skill = RocoSkillProxy.Create(G6SkillResPath[opType], skillComponent, PriorityEnum.Active_Player_Action)
      if not Skill then
        self:OnSkillStopImmediate(opType)
        return
      end
      Skill:SetCaster(caster)
      local targets = {}
      if skillInfo.target_land_id then
        local landNPC = FarmUtils.GetLandNPC(skillInfo.target_land_id)
        if landNPC and landNPC.viewObj then
          table.insert(targets, landNPC.viewObj)
        end
      end
      Skill:SetTargets(targets)
      Skill:RegisterEventCallback("PreStart", self, function(this, Name, skill)
        this:OnSkillPreStart(opType, Queue, Name, skill)
        Queue:Release()
      end)
      Skill:RegisterEventCallback("PreEnd", self, function()
        self:OnSkillEnd(opType)
      end)
      Skill:RegisterEventCallback("End", self, function()
        self:OnSkillEnd(opType)
      end)
      Skill:RegisterEventCallback("Interrupt", self, function()
        self:OnSkillInterrupt(opType)
      end)
      Skill:SetPassive(false)
      skillInfo.is_showing = true
      Skill:PlaySkill(self, function()
        self:OnSkillCallback(opType)
      end)
    end
  end
end

function FarmComponent:OnSkillCallback(opType)
end

function FarmComponent:OnSkillPreStart(opType, Queue, Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
  local MoZhangActor = World:Abs_SpawnActor(Queue:Get("MoZhang"), fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
  MoZhangActor.SkeletalMesh:SetSkeletalMesh(Queue:Get("Wand"))
  Skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
end

function FarmComponent:OnSkillEnd(opType)
  if not self.skillInfo then
    return
  end
  self.skillInfo[opType].started = false
  self.skillInfo[opType].is_showing = false
  if self.skillInfo[opType].caller and self.skillInfo[opType].callback then
    self.skillInfo[opType].callback(self.skillInfo[opType].caller)
  end
end

function FarmComponent:OnSkillInterrupt(opType)
  if not self.skillInfo then
    return
  end
  self.skillInfo[opType].started = false
  self.skillInfo[opType].is_showing = false
  if self.skillInfo[opType].caller and self.skillInfo[opType].callback then
    self.skillInfo[opType].callback(self.skillInfo[opType].caller)
  end
end

function FarmComponent:OnSkillStopImmediate(opType)
  if not self.skillInfo then
    return
  end
  self.skillInfo[opType].started = false
  self.skillInfo[opType].is_showing = false
  if self.skillInfo[opType].caller and self.skillInfo[opType].callback then
    self.skillInfo[opType].callback(self.skillInfo[opType].caller)
  end
end

function FarmComponent:PlaySowingSkill(target_land_id, caller, callback)
  self:PlayingSkill(target_land_id, FarmModuleEnum.OptionType.Sowing, caller, callback)
end

return FarmComponent
