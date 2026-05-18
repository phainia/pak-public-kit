local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local UMG_Ability_DimoJump_C = _G.NRCUmgClass:Extend("UMG_Ability_DimoJump_C")

function UMG_Ability_DimoJump_C:Construct()
  self.Btn_Slot.OnClicked:Add(self, self.OnSlotClicked)
  UE4Helper.PrintScreenMsg("UMG_Ability_DimoJump_C:OnConstruct")
end

function UMG_Ability_DimoJump_C:OnSlotClicked()
  UE4Helper.PrintScreenMsg("UMG_Ability_DimoJump_C:OnSlotClicked")
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule.playerActor:Jump()
  self:PlayAnimation(self.press)
  _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerJump)
end

return UMG_Ability_DimoJump_C
