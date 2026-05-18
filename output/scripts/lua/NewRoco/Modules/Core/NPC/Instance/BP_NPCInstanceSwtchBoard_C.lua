local BP_NPCInstanceWeightPlate_C = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceWeightPlate_C")
local Base = BP_NPCInstanceWeightPlate_C
local BP_NPCInstanceSwtchBoard_C = Base:Extend("BP_NPCInstanceSwtchBoard_C")

function BP_NPCInstanceSwtchBoard_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCInstanceSwtchBoard_C:OnVisible()
  Base.OnVisible(self)
  if self.sceneCharacter then
    local Option = self.sceneCharacter.InteractionComponent:GetMainAction()
    if Option then
      self.NiagaraInstance:SetActive(false, true)
      self.On = false
      self.Off = true
    else
      self.NiagaraInstance:SetActive(true, true)
      self.On = true
      self.Off = false
    end
  end
end

return BP_NPCInstanceSwtchBoard_C
