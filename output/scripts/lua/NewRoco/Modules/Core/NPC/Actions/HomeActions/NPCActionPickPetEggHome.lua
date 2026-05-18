local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionPickPetEggHome = Base:Extend("NPCActionPickPetEggHome")

function NPCActionPickPetEggHome:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
end

function NPCActionPickPetEggHome:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  self:Finish(true, nil, nil)
end

function NPCActionPickPetEggHome:OpenItemRewardsPanel()
  local config = self.Config
  if not config then
    Log.Debug("NPCActionPickPetEggHome:OpenItemRewardsPanel - config is nil")
    return
  end
  local rewardId = config.action_param1
  if not rewardId then
    Log.Debug("NPCActionPickPetEggHome:OpenItemRewardsPanel - action_param1 is nil")
    return
  end
  local rewardNumber = tonumber(rewardId)
  if not rewardNumber then
    Log.Debug("NPCActionPickPetEggHome:OpenItemRewardsPanel - action_param1 is not number", rewardId)
    return
  end
  local rewardData = _G.DataConfigManager:GetRewardConf(rewardNumber, true)
  if not rewardData then
    Log.Debug("NPCActionPickPetEggHome:OpenItemRewardsPanel - rewardData is nil", rewardNumber)
    return
  end
  local rewardItems = rewardData.RewardItem
  if not rewardItems then
    Log.Debug("NPCActionPickPetEggHome:OpenItemRewardsPanel - rewardItems is nil", rewardData.id, rewardData.Name, rewardData.DisplayName)
    return
  end
  local goodsItem = {}
  for _, item in pairs(rewardItems) do
    local popupData = _G.ProtoMessage:newGoodsItem()
    popupData.id = item.Id
    popupData.num = item.Count
    popupData.type = item.Type
    table.insert(goodsItem, popupData)
  end
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, goodsItem, nil, nil, true)
end

return NPCActionPickPetEggHome
