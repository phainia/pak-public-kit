local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionSearchPlayer = Base:Extend("LuaActionSearchPlayer")

function LuaActionSearchPlayer:OnStart(AIController, ...)
  if not self.OutTarget then
    self:Finish(false)
    return
  end
  local Radius = self.SearchRadius:GetValue(AIController) or 0
  local searchType = self.SearchType:GetValue(AIController) or 0
  local exceptLocal = self.ExceptLocalPlayer:GetValue(AIController) or false
  local exceptStatus = self.ExceptPlayerStatus or {}
  local includeStatus = self.IncludePlayerStatus or {}
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local allPlayers
  if playerModule then
    allPlayers = playerModule._playerDic
  end
  if not allPlayers then
    self:Finish(false)
    return
  end
  local myPawn = AIController:K2_GetPawn()
  if not myPawn then
    self:Finish(false)
    return
  end
  
  local function PlayerHasStatus(p, statusId)
    return p.statusComponent and p.statusComponent:HasStatus(statusId)
  end
  
  local function ShouldSkipPlayer(p)
    if exceptLocal and p.isLocal then
      return true
    end
    if #exceptStatus > 0 then
      for _, v in ipairs(exceptStatus) do
        local st = v:GetValue(AIController)
        if st and PlayerHasStatus(p, st) then
          return true
        end
      end
    end
    if #includeStatus > 0 then
      local matched = false
      for _, v in ipairs(includeStatus) do
        local st = v:GetValue(AIController)
        if st and PlayerHasStatus(p, st) then
          matched = true
          break
        end
      end
      if not matched then
        return true
      end
    end
    return false
  end
  
  local myPos = myPawn:Abs_K2_GetActorLocation()
  local Radius2 = Radius * Radius
  local candidates = {}
  for _, p in pairs(allPlayers) do
    if not ShouldSkipPlayer(p) then
      local d2 = (p:GetActorLocation() - myPos):SizeSquared()
      if Radius <= 0 or Radius2 >= d2 then
        candidates[#candidates + 1] = {player = p, dist2 = d2}
      end
    end
  end
  if 0 == #candidates then
    self:Finish(false)
    return
  end
  local targetPlayer
  if 0 == searchType then
    table.sort(candidates, function(a, b)
      return a.dist2 < b.dist2
    end)
    targetPlayer = candidates[1].player
  elseif 1 == searchType then
    table.sort(candidates, function(a, b)
      return a.dist2 > b.dist2
    end)
    targetPlayer = candidates[1].player
  elseif 2 == searchType then
    targetPlayer = candidates[math.random(1, #candidates)].player
  else
    table.sort(candidates, function(a, b)
      return a.dist2 < b.dist2
    end)
    targetPlayer = candidates[1].player
  end
  if targetPlayer then
    self.OutTarget:SetValue(AIController, targetPlayer)
    self:Finish(true)
  else
    self:Finish(false)
  end
end

return LuaActionSearchPlayer
