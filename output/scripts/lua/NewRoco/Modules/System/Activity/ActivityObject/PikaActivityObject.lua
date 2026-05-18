local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local PikaActivityObject = Base:Extend("PikaActivityObject")

function PikaActivityObject:OnTryJoinActivity(...)
  local fashionMallId, specificPackageId = ...
  local CombinationBagShopOpenContext = {}
  CombinationBagShopOpenContext.Activity = self:GetActivityId()
  CombinationBagShopOpenContext.BaseId = self:GetSinglePartId()
  CombinationBagShopOpenContext.ActionId = "J0011"
  ActivityUtils.SendTLogActivityAction(CombinationBagShopOpenContext.Activity, CombinationBagShopOpenContext.BaseId, ActivityEnum.TLogActionType.Join, CombinationBagShopOpenContext.ActionId)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenSeasonalCombinationBagShop, fashionMallId, specificPackageId, CombinationBagShopOpenContext)
end

return PikaActivityObject
