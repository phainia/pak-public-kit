local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = NPCActionBase
local NPCActionHomeVisitorPick = Base:Extend("NPCActionHomeVisitorPick")

function NPCActionHomeVisitorPick:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.shouldSync = true
end

function NPCActionHomeVisitorPick:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  local Player = self:GetPlayer()
  self.LoadQueue = ResQueue()
  self.LoadQueue:InsertObject("Wand", Player:GetCurWandPath(), _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:InsertObject("MoZhang", "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'", _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:StartLoad(self, self.OnLoadFinish)
end

function NPCActionHomeVisitorPick:OnCommitErrorRetInfo(retInfo, rsp)
  local msg
  if rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_HOME_PLANT_STEAL_BORBIDDING_TIME then
    msg = _G.LuaText[string.format("Error_Code_%d", rsp.ret_info.ret_code)]
    local timeConf = _G.DataConfigManager:GetHomeGlobalConfig("plant_steal_forbidding_time")
    msg = string.format(msg, timeConf.numList[1], timeConf.numList[2])
  elseif rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_HOME_PLANT_TOTAL_STEAL_CNT_NOT_ENOUGH then
    if self.OwnerNpc and self.OwnerNpc:GetFarmLandId() then
      local landId = self.OwnerNpc:GetFarmLandId()
      local plantGrowConf = FarmUtils.GetPlantGrowConfByLandId(landId)
      if not plantGrowConf then
        Log.Error("NPCActionHomeVisitorPick:OnSubmit: ERR_SCENE_HOME_PLANT_TOTAL_STEAL_CNT_NOT_ENOUGH, plantGrowConf is nil")
        return false
      end
      local bagItemConf = _G.DataConfigManager:GetBagItemConf(plantGrowConf.plant_harvest)
      if not bagItemConf then
        Log.Error("NPCActionHomeVisitorPick:OnSubmit: ERR_SCENE_HOME_PLANT_TOTAL_STEAL_CNT_NOT_ENOUGH, bagItemConf is nil")
        return false
      end
      local plantName = bagItemConf.name
      msg = _G.LuaText[string.format("Error_Code_%d", rsp.ret_info.ret_code)]
      msg = string.format(msg, plantName)
    end
  elseif rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_HOME_PLANT_LAND_HAS_STOLEN then
    msg = _G.LuaText[string.format("Error_Code_%d", rsp.ret_info.ret_code)]
  end
  if msg then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, msg)
    return true
  end
  return false
end

function NPCActionHomeVisitorPick:OnCommit(rsp)
  Base.OnCommit(self, rsp)
  if 0 == rsp.ret_info.ret_code then
    _G.NRCModeManager:DoCmd(_G.HomeModuleCmd.AddPlayerStealCount)
  end
end

function NPCActionHomeVisitorPick:OnLoadFinish(Queue, Success)
  Log.Debug("NPCActionHomeVisitorPick:StartSkill")
  if not Success then
    Log.Error("NPCActionHomeVisitorPick Load Failed!!!!")
    self:Finish(false)
    return
  end
  local player = self:GetPlayer()
  if not player then
    Log.Error("NPCActionHomeVisitorPick:StartSkill \230\137\190\228\184\141\229\136\176player")
    self:Finish(false)
    return
  end
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("NPCActionHomeVisitorPick:StartSkill \230\137\190\228\184\141\229\136\176owner")
    self:Finish(false)
    return
  end
  local land_id = self.OwnerNpc:GetFarmLandId()
  if not land_id then
    Log.Error("NPCActionHomeVisitorPick:StartSkill \230\137\190\228\184\141\229\136\176land_id")
    self:Finish(false)
    return
  end
  local targets = {}
  local landNPC = FarmUtils.GetLandNPC(land_id)
  if not landNPC then
    Log.Error("NPCActionHomeVisitorPick:StartSkill \230\137\190\228\184\141\229\136\176landNPC", land_id)
    self:Finish(false)
    return
  end
  table.insert(targets, landNPC.viewObj)
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create(FarmConst.SkillPath.Harvesting, skillComp)
  if not skill then
    Log.Error("NPCActionHomeVisitorPick:StartSkill \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false)
    return
  end
  if player and player.isLocal then
    local Position = player.viewObj:Abs_K2_GetActorLocation()
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.SendSenseEvent, Position, Enum.DotsAIWorldEventType.DAWET_HOME_PLANT_VISTOR_PICK)
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(player.viewObj)
  skill:SetTargets(targets)
  skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  _G.NRCEventCenter:RegisterEvent("NPCActionHomeVisitorPick", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionHomeVisitorPick:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function NPCActionHomeVisitorPick:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
  local MoZhangActor = World:Abs_SpawnActor(self.LoadQueue:Get("MoZhang"), fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
  MoZhangActor.SkeletalMesh:SetSkeletalMesh(self.LoadQueue:Get("Wand"))
  Skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
end

function NPCActionHomeVisitorPick:SkillFailed()
  Log.Error("NPCActionHomeVisitorPick:SkillFailed")
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionHomeVisitorPick:SkillComplete(Name, Skill)
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionHomeVisitorPick:OnInterrupted(Name, Skill)
  Log.Error("NPCActionHomeVisitorPick:OnInterrupted")
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionHomeVisitorPick:OnReconnect()
  Log.Error("NPCActionHomeVisitorPick:OnReconnect need to complete skill!")
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

return NPCActionHomeVisitorPick
