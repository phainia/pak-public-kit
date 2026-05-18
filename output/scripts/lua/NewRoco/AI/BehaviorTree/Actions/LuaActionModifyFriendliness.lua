local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local HomePetAttributeComponent = require("NewRoco.Modules.System.Home.HomePetFeed.HomePetAttributeComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionModifyFriendliness = Base:Extend("LuaActionModifyFriendliness")
local HOME_STEAL_FIX_VALUE_FRIEND, HOME_STEAL_FIX_VALUE_GUEST

local function InitStealFixValue()
  if HOME_STEAL_FIX_VALUE_FRIEND then
    return
  end
  local conf_friend = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_fix_value_friend")
  HOME_STEAL_FIX_VALUE_FRIEND = conf_friend and conf_friend.num or 15
  local conf_guest = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_fix_value_guest")
  HOME_STEAL_FIX_VALUE_GUEST = conf_guest and conf_guest.num or 30
end

function LuaActionModifyFriendliness:OnStart(owner)
  local focusPlayer = owner:GetFocusPlayerCharacter()
  if not focusPlayer then
    return self:Finish(false)
  end
  local playerId = focusPlayer:GetServerId()
  local AttrComp = owner.Npc:EnsureComponent(HomePetAttributeComponent)
  local OpType = self.Op:GetValue(owner)
  if 0 == OpType then
    AttrComp:ModifyFriendliness(playerId, self.Value:GetValue())
  elseif 1 == OpType then
    AttrComp:SetFriendliness(playerId, self.Value:GetValue())
  elseif 2 == OpType then
    InitStealFixValue()
    local fixVal = HOME_STEAL_FIX_VALUE_FRIEND
    AttrComp:ModifyFriendliness(playerId, -fixVal)
  end
  return self:Finish(true)
end

return LuaActionModifyFriendliness
