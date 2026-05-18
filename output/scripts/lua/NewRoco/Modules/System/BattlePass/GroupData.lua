local GroupData = {}

function GroupData:New()
  local obj = {
    groupId = 0,
    evolutionStage = 1,
    groupNodes = {}
  }
  setmetatable(obj, {__index = GroupData})
  return obj
end

function GroupData:GetParentNodeCenterX()
  local points = {}
  for i, v in pairs(self.groupNodes) do
    table.insert(points, v.pos.X)
  end
  return self:CalculateCenter(points)
end

function GroupData:CalculateCenter(points)
  if 0 == #points then
    return nil
  elseif 1 == #points then
    return points[1]
  else
    local left = points[1]
    local right = points[1]
    for i = 2, #points do
      if left > points[i] then
        left = points[i]
      end
    end
    for i = 2, #points do
      if right < points[i] then
        right = points[i]
      end
    end
    return (left + right) / 2
  end
end

return GroupData
