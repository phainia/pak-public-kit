local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetFashionInfo = Base:Extend("LuaActionGetFashionInfo")

function LuaActionGetFashionInfo:OnStart(owner)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer.statusComponent then
    local statusParams = localPlayer.statusComponent._statusParams[Enum.WorldPlayerStatusType.WPST_FASHION_SUITS]
    if statusParams and statusParams.fashion_suits_param and statusParams.fashion_suits_param.fashion_suits_id and statusParams.fashion_suits_param.suit_ai_effect then
      self.OutFashionID:SetValue(owner, statusParams.fashion_suits_param.fashion_suits_id)
      self.OutFashionTag:SetValue(owner, statusParams.fashion_suits_param.suit_ai_effect)
      return self:Finish(true)
    end
  end
  self.OutFashionID:SetValue(owner, 0)
  self.OutFashionTag:SetValue(owner, 0)
  return self:Finish(false)
end

return LuaActionGetFashionInfo
