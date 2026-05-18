local BP_BattleHitPointSelect_C = NRCClass:Extend("BP_BattleHitPointSelect_C")

function BP_BattleHitPointSelect_C:ReceiveBeginPlay()
  self.frontPoints = {}
  self.allRoundPoints = {}
  self.specifiedFront = nil
  self:InitChildActor()
end

function BP_BattleHitPointSelect_C:InitChildActor()
  local tInsert = table.insert
  local childActors = self:GetAllChildActors(nil, true)
  for _, Actor in tpairs(childActors) do
    local pointActor = Actor
    if string.find(pointActor:GetName(), "SpecifiedFrontPoint") then
      self.specifiedFront = pointActor
    elseif string.find(pointActor:GetName(), "FrontPoint") then
      tInsert(self.frontPoints, pointActor)
      tInsert(self.allRoundPoints, pointActor)
    elseif string.find(pointActor:GetName(), "AllRoundPoint") then
      tInsert(self.allRoundPoints, pointActor)
    end
  end
end

function BP_BattleHitPointSelect_C:GetHitPoint(hitType)
  if hitType == UE4.ERocoSkillHitPointType.FrontPoint then
    if #self.frontPoints > 0 then
      local index = math.random(1, #self.frontPoints)
      return self.frontPoints[index]
    end
  elseif hitType == UE4.ERocoSkillHitPointType.AllRound then
    if #self.allRoundPoints then
      local index = math.random(1, #self.allRoundPoints)
      return self.allRoundPoints[index]
    end
  elseif hitType == UE4.ERocoSkillHitPointType.SpecifiedFront then
    return self.specifiedFront
  end
  return self.Object
end

function BP_BattleHitPointSelect_C:Destruct()
  self.frontPoints = nil
  self.allRoundPoints = nil
  self.specifiedFront = nil
end

return BP_BattleHitPointSelect_C
