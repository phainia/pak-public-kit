local Enum = require("Data.Config.Enum")
local CampingUtils = {}

function CampingUtils.CheckIsUnlockItem(BagItemId)
  local ItemUnlockMapConf = _G.DataConfigManager:GetItemUnlockMapConf(BagItemId, true)
  if not (ItemUnlockMapConf and ItemUnlockMapConf.exchange_id) or #ItemUnlockMapConf.exchange_id < 1 then
    return false
  end
  local ExchangeConf = _G.DataConfigManager:GetExchangeConf(ItemUnlockMapConf.exchange_id[1], true)
  if not ExchangeConf then
    return false
  end
  if ExchangeConf.get_item[1] and ExchangeConf.get_item[1].get_goods_id then
    return ExchangeConf.get_item[1].get_goods_id
  end
  return false
end

return CampingUtils
