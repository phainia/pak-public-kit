local HomePetGetBackAction = Class("HomePetGetBackAction")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")

function HomePetGetBackAction:Ctor(owner, actionType, ownerNpc)
  self.owner = owner
  self.ownerNpc = ownerNpc
end

function HomePetGetBackAction:Execute()
  NRCModuleManager:DoCmd(HomeModuleCmd.ReCyclePet, self.ownerNpc.furnitureId)
  self.owner:OnPlayerLeaveActionArea()
end

return HomePetGetBackAction
