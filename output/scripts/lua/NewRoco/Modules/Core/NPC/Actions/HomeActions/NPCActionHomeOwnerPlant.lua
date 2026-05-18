local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local ResQueue = require("NewRoco.Utils.ResQueue")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionHomeOwnerPlant = Base:Extend("NPCActionHomeOwnerPlant")

function NPCActionHomeOwnerPlant:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.shouldSync = true
  self.curEquipSeedId = 0
end

function NPCActionHomeOwnerPlant:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  self.curEquipSeedId = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetEquipSeed) or 0
  self.curEquipSeedId = tostring(self.curEquipSeedId)
  local Player = self:GetPlayer()
  self.LoadQueue = ResQueue()
  self.LoadQueue:InsertObject("Wand", Player:GetCurWandPath(), _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:InsertObject("MoZhang", "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'", _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:StartLoad(self, self.OnLoadFinish)
end

function NPCActionHomeOwnerPlant:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
end

function NPCActionHomeOwnerPlant:OnLoadFinish(Queue, Success)
  if not Success then
    Log.Error("NPCActionHomeOwnerPlant Load Failed!!!!")
    self:Finish(false, nil, self.curEquipSeedId)
    return
  end
  Log.Debug("NPCActionHomeOwnerPlant:StartSkill")
  local player = self:GetPlayer()
  if not player then
    Log.Error("NPCActionHomeOwnerPlant:StartSkill \230\137\190\228\184\141\229\136\176player")
    self:Finish(false, nil, self.curEquipSeedId)
    return
  end
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("NPCActionHomeOwnerPlant:StartSkill \230\137\190\228\184\141\229\136\176owner")
    self:Finish(false, nil, self.curEquipSeedId)
    return
  end
  local land_id = self.OwnerNpc:GetFarmLandId()
  if not land_id then
    Log.Error("NPCActionHomeOwnerPlant:StartSkill \230\137\190\228\184\141\229\136\176land_id")
    self:Finish(false, nil, self.curEquipSeedId)
    return
  end
  local targets = {}
  local landNPC = FarmUtils.GetLandNPC(land_id)
  table.insert(targets, landNPC.viewObj)
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create(FarmConst.SkillPath.Sowing, skillComp)
  if not skill then
    Log.Error("NPCActionHomeOwnerPlant:StartSkill \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false, nil, self.curEquipSeedId)
    return
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(player.viewObj)
  skill:SetTargets(targets)
  skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("SendReq", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  self.SkillStarted = true
  skill:PlaySkill(self, self.OnSkillStart)
  _G.NRCEventCenter:RegisterEvent("NPCActionHomeOwnerPlant", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionHomeOwnerPlant:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed(Result)
  end
end

function NPCActionHomeOwnerPlant:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
  local MoZhangActor = World:Abs_SpawnActor(self.LoadQueue:Get("MoZhang"), fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
  MoZhangActor.SkeletalMesh:SetSkeletalMesh(self.LoadQueue:Get("Wand"))
  Skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
end

function NPCActionHomeOwnerPlant:SkillFailed(Result)
  Log.Error("NPCActionHomeOwnerPlant:SkillFailed", Result)
  self.SkillStarted = false
  self:SkillComplete()
  self:Finish(false, nil, self.curEquipSeedId)
end

function NPCActionHomeOwnerPlant:SkillComplete(Name, Skill)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
  if not self.SkillStarted then
    return
  else
    self.SkillStarted = false
    self:Finish(true, nil, self.curEquipSeedId)
  end
end

function NPCActionHomeOwnerPlant:OnInterrupted(Name, Skill)
  Log.Error("NPCActionHomeOwnerPlant:OnInterrupted")
  self.SkillStarted = false
  self:SkillComplete()
  self:Finish(false, nil, self.curEquipSeedId)
end

function NPCActionHomeOwnerPlant:OnReconnect()
  Log.Error("NPCActionHomeOwnerPlant:OnReconnect need to complete skill!")
  self.SkillStarted = false
  self:Finish(true, nil, self.curEquipSeedId)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

return NPCActionHomeOwnerPlant
