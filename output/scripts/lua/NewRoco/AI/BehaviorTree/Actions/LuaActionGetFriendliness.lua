local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local HomePetAttributeComponent = require("NewRoco.Modules.System.Home.HomePetFeed.HomePetAttributeComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetFriendliness = Base:Extend("LuaActionGetFriendliness")

function LuaActionGetFriendliness:OnStart(owner)
  local focusPlayer = owner:GetFocusPlayerCharacter()
  if not focusPlayer then
    return self:Finish(false)
  end
  if not _G.HomeModuleCmd then
    return self:Finish(false)
  end
  local playerId = focusPlayer:GetServerId()
  local AttrComp = owner.Npc:EnsureComponent(HomePetAttributeComponent)
  local Friendliness = AttrComp:GetFriendlinessCurrent(playerId)
  if self.OutFriendNess and self.OutFriendNess.useBlackboardKey then
    self.OutFriendNess:SetValue(owner, math.ceil(Friendliness))
  end
  if self.IntimacyRank and self.IntimacyRank.useBlackboardKey then
    local isMaster = _G.HomeIndoorSandbox and _G.HomeIndoorSandbox:InHomeIndoor() and _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.IsHomeMasterByPlayerId, playerId) or FarmUtils.IsHomeOwner(focusPlayer)
    if isMaster then
      self.IntimacyRank:SetValue(owner, 0)
    else
      self.IntimacyRank:SetValue(owner, _G.SceneAIUtils.CheckFriendlinessInRange(math.ceil(Friendliness)))
    end
  end
  return self:Finish(true)
end

return LuaActionGetFriendliness
