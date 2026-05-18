local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionOpenPetAltar = Base:Extend("NPCActionOpenPetAltar")

function NPCActionOpenPetAltar:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenPetAltar:Execute()
  Log.Debug("NPCActionOpenPetAltar:Execute")
  Base.Execute(self)
  local player = self:GetPlayer()
  player:PlayAnim("Think", 1, 0, 0.1, 0.1, 999, 0, "Locomotion")
  local allpets = _G.DataModelMgr.PlayerDataModel:GetPetData()
  if allpets and #allpets > 0 then
    _G.NRCModuleManager:DoCmd(AltarModuleCmd.OpenPetAltarPanel, self)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.npcactionopenpetaltar_1)
    self:Finish(false)
  end
end

function NPCActionOpenPetAltar:GiveFinish(petData)
  self.gid = tostring(petData.gid)
  self.petdata = petData
  local Player = self:GetPlayer()
  Player:StopAnim("Think", 0.1, "Locomotion")
  local SkillComp = Player.viewObj.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Zhiling/Item_Give", SkillComp, PriorityEnum.Active_Player_Action)
  if not Skill then
    Log.Error("NPCActionOpenPetAltar:GiveFinish \230\137\190\228\184\141\229\136\176Skill")
    return
  end
  Skill:SetWithLoadAndPlay(true)
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    self:GetOwnerNPCView()
  })
  Skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  Skill:RegisterEventCallback("End", self, self.SubmitAction)
  Skill:PlaySkill(self, self.OnSkillCallBack)
end

function NPCActionOpenPetAltar:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  local Blackboard = Skill.Blackboard
  Blackboard:SetValueAsString("type", "ball")
  Skill:SetDynamicData({
    BallPath = BattleUtils.GetPetBallPath(self.petdata)
  })
end

function NPCActionOpenPetAltar:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionOpenPetAltar failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionOpenPetAltar:SkillFailed(success, data, param)
  Base.Finish(self, success, data, param)
end

function NPCActionOpenPetAltar:SubmitAction(success, data, param)
  self:Finish(true, nil, self.gid)
end

function NPCActionOpenPetAltar:Finish(success, data, param)
  local localPlayer = self:GetPlayer()
  localPlayer:StopAnim("Think", 0.1, "Locomotion")
  Base.Finish(self, success, data, param)
end

return NPCActionOpenPetAltar
