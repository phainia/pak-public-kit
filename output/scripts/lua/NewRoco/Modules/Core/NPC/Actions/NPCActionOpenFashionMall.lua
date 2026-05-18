local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionOpenFashionMall = Base:Extend("NPCActionOpenFashionMall")

function NPCActionOpenFashionMall:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenSeasonalCombinationBagShop, _G.AppearanceModuleEnum.FashionMallShopId.SEASONAL_COMBINATION_BAG, nil)
end

function NPCActionOpenFashionMall:OnSubmit(rsp)
  self:Finish()
end

return NPCActionOpenFashionMall
