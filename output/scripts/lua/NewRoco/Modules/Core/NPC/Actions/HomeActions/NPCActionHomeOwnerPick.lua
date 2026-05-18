local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = NPCActionBase
local NPCActionHomeOwnerPick = Base:Extend("NPCActionHomeOwnerPick")

function NPCActionHomeOwnerPick:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.LoadQueue = nil
  self.shouldSync = true
end

function NPCActionHomeOwnerPick:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  local Player = self:GetPlayer()
  if Player and Player.isLocal and Player.statusComponent and Player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    self:Finish(true)
    return
  end
  self.LoadQueue = ResQueue()
  self.LoadQueue:InsertObject("Wand", Player:GetCurWandPath(), _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:InsertObject("MoZhang", "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'", _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:StartLoad(self, self.OnLoadFinish)
end

function NPCActionHomeOwnerPick:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
end

function NPCActionHomeOwnerPick:OnLoadFinish(Queue, Success)
  if not Success then
    Log.Error("NPCActionHomeOwnerPick Load Failed!!!!")
    self:Finish(false)
    return
  end
  local player = self:GetPlayer()
  if not player then
    Log.Error("NPCActionHomeOwnerPick:StartSkill \230\137\190\228\184\141\229\136\176player")
    self:Finish(false)
    return
  end
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("NPCActionHomeOwnerPick:StartSkill \230\137\190\228\184\141\229\136\176owner")
    self:Finish(false)
    return
  end
  local land_id = self.OwnerNpc:GetFarmLandId()
  if not land_id then
    Log.Error("NPCActionHomeOwnerPick:StartSkill \230\137\190\228\184\141\229\136\176land_id")
    self:Finish(false)
    return
  end
  local targets = {}
  local landNPC = FarmUtils.GetLandNPC(land_id)
  if not landNPC or not landNPC.viewObj then
    Log.Error("NPCActionHomeOwnerPick:StartSkill \230\137\190\228\184\141\229\136\176landNPC")
    self:Finish(false)
    return
  end
  table.insert(targets, landNPC.viewObj)
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create(FarmConst.SkillPath.Harvesting, skillComp, PriorityEnum.Active_Player_Action)
  if not skill then
    Log.Error("NPCActionHomeOwnerPick:StartSkill \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false)
    return
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(player.viewObj)
  skill:SetTargets(targets)
  skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  _G.NRCEventCenter:RegisterEvent("NPCActionHomeOwnerPick", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionHomeOwnerPick:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function NPCActionHomeOwnerPick:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
  local MoZhangActor = World:Abs_SpawnActor(self.LoadQueue:Get("MoZhang"), fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
  MoZhangActor.SkeletalMesh:SetSkeletalMesh(self.LoadQueue:Get("Wand"))
  Skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
  if self.LoadQueue then
    self.LoadQueue:Release()
  end
end

function NPCActionHomeOwnerPick:SkillFailed()
  Log.Error("NPCActionHomeOwnerPick:SkillFailed")
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionHomeOwnerPick:SkillComplete(Name, Skill)
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionHomeOwnerPick:OnInterrupted(Name, Skill)
  Log.Error("NPCActionHomeOwnerPick:OnInterrupted")
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionHomeOwnerPick:OnReconnect()
  Log.Error("NPCActionHomeOwnerPick:OnReconnect need to complete skill!")
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

return NPCActionHomeOwnerPick
