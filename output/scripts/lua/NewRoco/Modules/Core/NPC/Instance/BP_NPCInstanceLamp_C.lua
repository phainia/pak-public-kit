require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPCInstanceLamp_C = Base:Extend("BP_NPCInstanceLamp_C")

function BP_NPCInstanceLamp_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCInstanceLamp_C:OnVisible()
  self.Open:SetActive(true, true)
  self.End:SetActive(true, true)
  self.Open:SetVisibility(false)
  self.End:SetVisibility(false)
  Base.OnVisible(self)
end

return BP_NPCInstanceLamp_C
