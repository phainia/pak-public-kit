local BP_NPCCharacter_C = require("NewRoco.Modules.Core.NPC.BP_NPCCharacter_C")
local Base = BP_NPCCharacter_C
local BP_BossSkillItem_C = Base:Extend("BP_BossSkillItem_C")

function BP_BossSkillItem_C:SetCollisionEnableInternal(Flag)
end

function BP_BossSkillItem_C:OnLoadResource()
  Base.OnLoadResource(self)
  if self.CharacterMovement then
    self.CharacterMovement:SetComponentTickEnabled(false)
    self.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_None)
    self.CharacterMovement:DisableMovement()
  end
end

return BP_BossSkillItem_C
