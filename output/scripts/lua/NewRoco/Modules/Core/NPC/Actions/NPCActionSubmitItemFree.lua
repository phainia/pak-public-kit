local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionSubmitItemFree = Base:Extend("NPCActionSubmitItemFree")

function NPCActionSubmitItemFree:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionSubmitItemFree:Execute()
  Base.Execute(self)
  local player = self:GetPlayer()
  player:PlayAnim("Think", 1, 0, 0.1, 0.1, 999, 0, "Locomotion")
  _G.NRCModuleManager:DoCmd(AltarModuleCmd.OpenItemAltarPanelFree, self)
end

function NPCActionSubmitItemFree:GiveFinish(commitIdStr)
  self.commitIdStr = commitIdStr
  local Player = self:GetPlayer()
  Player:StopAnim("Think", 0.1, "Locomotion")
  local SkillComp = Player.viewObj.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Zhiling/Item_Give", SkillComp)
  if not Skill then
    Log.Error("NPCActionSubmitItemFree:GiveFinish \230\137\190\228\184\141\229\136\176Skill")
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

function NPCActionSubmitItemFree:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  local Blackboard = Skill.Blackboard
  Blackboard:SetValueAsString("type", "item")
end

function NPCActionSubmitItemFree:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionOpenItemAltar failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionSubmitItemFree:SkillFailed()
  self:Finish(false)
end

function NPCActionSubmitItemFree:SubmitAction()
  self:Finish(true, nil, self.commitIdStr)
end

function NPCActionSubmitItemFree:Finish(success, data, param)
  local localPlayer = self:GetPlayer()
  localPlayer:StopAnim("Think", 0.1, "Locomotion")
  Base.Finish(self, success, data, param)
end

return NPCActionSubmitItemFree
