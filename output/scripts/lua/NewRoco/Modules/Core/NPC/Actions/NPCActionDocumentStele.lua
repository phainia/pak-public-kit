local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionDocumentStele = Base:Extend("NPCActionDocumentStele")

function NPCActionDocumentStele:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionDocumentStele:GetSide()
  local View = self:GetOwnerNPCView()
  if not View then
    return true
  end
  local Player = self:GetPlayer()
  local PlayerView = Player and Player.viewObj
  if not PlayerView then
    return true
  end
  local Forward = View:GetActorForwardVector()
  Forward = Forward:RotateAngleAxis(-90, UE.FVector(0, 0, 1))
  Forward = UE.FVector2D(Forward.X, Forward.Y)
  local P1 = View:K2_GetActorLocation()
  local P2 = PlayerView:K2_GetActorLocation()
  local Dir = P1 - P2
  Dir = UE.FVector2D(Dir.X, Dir.Y)
  Forward:Normalize()
  Dir:Normalize()
  local Dot = Forward:Dot(Dir)
  return Dot > 0
end

function NPCActionDocumentStele:Execute()
  Base.Execute(self)
  local SteleView = self:GetOwnerNPCView()
  local SkillComp = SteleView.RocoSkill
  local Path
  if self:GetSide() then
    Path = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_TextStele_01"
  else
    Path = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_TextStele_02"
  end
  local Skill = RocoSkillProxy.Create(Path, SkillComp, PriorityEnum.Active_Player_Action)
  if not Skill then
    self:Finish(false)
    return
  end
  Skill:SetCaster(SteleView)
  Skill:RegisterEventCallback("End", self, self.Learnt)
  Skill:RegisterEventCallback("PreEnd", self, self.Learnt)
  Skill:RegisterEventCallback("PreEndAnim", self, self.Learnt)
  Skill:PlaySkill()
end

function NPCActionDocumentStele:Learnt(Name, Skill)
  self:Finish(true)
end

return NPCActionDocumentStele
