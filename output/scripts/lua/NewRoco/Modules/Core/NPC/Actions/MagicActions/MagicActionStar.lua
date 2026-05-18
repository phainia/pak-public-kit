local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local MagicActionBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionBase
local MagicActionStar = Base:Extend("MagicActionStar")

function MagicActionStar:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionStar:OnSubmit(rsp)
  local ErrorCode = rsp.ret_info.ret_code
  if 0 == ErrorCode then
    self:Finish(false)
    return
  end
  self:StartSkill()
end

function MagicActionStar:StartSkill()
  local OwnerView = self:GetOwnerNPCView()
  local Player = self:GetPlayer()
  local SkillComp = Player:GetSkillComponent()
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Stele_Star", SkillComp, PriorityEnum.Active_Player_Action)
  if not Skill then
    self:Finish(false)
    return
  end
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({OwnerView})
  Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  SkillComp:StopCurrentSkill()
  Skill:PlaySkill()
end

function MagicActionStar:OnSkillComplete()
  self:Finish(true)
end

function MagicActionStar:GetPlayer()
  return _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
end

return MagicActionStar
