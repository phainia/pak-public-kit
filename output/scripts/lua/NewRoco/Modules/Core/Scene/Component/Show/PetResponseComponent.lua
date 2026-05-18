local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetResponseComponent = Base:Extend("PetResponseComponent")

function PetResponseComponent:Attach(owner)
  Base.Attach(self, owner)
  self.bResponding = false
end

function PetResponseComponent:DeAttach()
end

function PetResponseComponent:OnSetViewObj()
  self.bResponding = false
end

function PetResponseComponent:AddPetResponse()
  if self:IsInHiddenState() then
    return
  end
  if self.bResponding then
    return
  end
  self:DoResponse()
end

function PetResponseComponent:DoResponse()
  local skillPath = string.format("/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/G6_Pet_Response.G6_Pet_Response")
  local view = self:GetOwnerView()
  local skillComp = view and view.RocoSkill
  if not skillComp then
    local playerView = self.owner.owner and self.owner.owner.viewObj
    if playerView then
      skillComp = playerView.RocoSkill
    end
  end
  if view and skillComp then
    self.bResponding = true
    local SkillProxy = RocoSkillProxy.Create(skillPath, skillComp, PriorityEnum.Passive_NPC_Show)
    SkillProxy:SetCaster(view)
    SkillProxy:RegisterEventCallback("End", self, self.OnResponseEnd)
    SkillProxy:SetPassive(true)
    SkillProxy:PlaySkill()
  else
    Log.Error("PetResponseComponent:DoResponse Failed", view and view:GetName(), skillComp)
  end
end

function PetResponseComponent:OnResponseEnd()
  self.bResponding = false
end

function PetResponseComponent:IsInHiddenState()
  local owner = self:GetOwner()
  local view = owner and owner.viewObj
  if view and view.bHidden then
    return true
  end
  local hiddenComponent = owner and owner.HiddenComponent
  if hiddenComponent then
    return hiddenComponent:IsHidden()
  end
  return false
end

return PetResponseComponent
