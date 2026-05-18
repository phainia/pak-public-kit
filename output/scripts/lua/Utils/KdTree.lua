local PriorityQueue = require("Utils.PriorityQueue")
local KdTree = {}
KdTree.__index = KdTree
setmetatable(KdTree, {
  __call = function(class, ...)
    local instance = {}
    setmetatable(instance, KdTree)
    instance:_new(...)
    return instance
  end
})

function KdTree:_new(...)
  self:Clear(...)
end

function KdTree:Clear()
  self._cache_nodes = {}
  self._root = nil
end

function KdTree:AddAndCache(x, y, z, data)
  local node = {
    x = x,
    y = y,
    z = z,
    data = data,
    left = nil,
    right = nil
  }
  table.insert(self._cache_nodes, node)
end

local function cmpx(node1, node2)
  return node1.x < node2.x
end

local function cmpy(node1, node2)
  return node1.y < node2.y
end

local function cmpz(node1, node2)
  return node1.z < node2.z
end

local function getcmp(axis)
  if 0 == axis then
    return cmpx
  elseif 1 == axis then
    return cmpy
  else
    return cmpz
  end
end

function KdTree:Build()
  self._root = self:Build_Internal(self._cache_nodes, 0)
  self._cache_nodes = nil
end

function KdTree:Build_Internal(nodes, axis)
  if 0 == #nodes then
    return nil
  elseif 1 == #nodes then
    return nodes[1]
  else
    local cmp = getcmp(axis)
    local bigger_half = PriorityQueue()
    bigger_half:SetCmpFunction(cmp)
    local littler_nodes = {}
    local nhalf = #self._cache_nodes / 2
    for _, node in pairs(nodes) do
      if nhalf >= bigger_half:Size() then
        bigger_half:EnQueue(node)
      else
        local top = bigger_half:GetTop()
        if cmp(node, top) then
          table.insert(littler_nodes, node)
        else
          table.insert(littler_nodes, bigger_half:DeQueue())
          bigger_half:EnQueue(node)
        end
      end
    end
    local root = bigger_half:DeQueue()
    root.axis = axis
    root.left = self:Build_Internal(littler_nodes, (axis + 1) % 3)
    root.right = self:Build_Internal(bigger_half._items, (axis + 1) % 3)
    return root
  end
end

local function square_dis_between_node(node1, node2)
  local xx = node1.x - node2.x
  local yy = node1.y - node2.y
  local zz = node1.z - node2.z
  return xx * xx + yy * yy + zz * zz
end

local function square_dis_node_to_pos(node, x, y, z)
  local xx = node.x - x
  local yy = node.y - y
  local zz = node.z - z
  return xx * xx + yy * yy + zz * zz
end

function KdTree:SearchNearest_Internal_BackTrace(node, x, y, z, square_radius, data)
  if not node.data then
    Log.Warning("KdTree:SearchNearest_Internal_BackTrace, node.data nil")
  end
  if not data then
    Log.Warning("KdTree:SearchNearest_Internal_BackTrace, data nil")
  end
  local k, node_k
  if 0 == node.axis then
    k = x
    node_k = node.x
  elseif 1 == node.axis then
    k = y
    node_k = node.y
  else
    k = z
    node_k = node.z
  end
  local dis_k = k - node_k
  if square_radius < dis_k * dis_k then
    if k > node_k and node.right then
      return self:SearchNearest_Internal_BackTrace(node.right, x, y, z, square_radius, data)
    elseif k < node_k and node.left then
      return self:SearchNearest_Internal_BackTrace(node.left, x, y, z, square_radius, data)
    end
    return square_radius, data
  else
    local ans_dis, ans_data
    local square_dis = square_dis_node_to_pos(node, x, y, z)
    if square_radius > square_dis then
      ans_dis = square_dis
      ans_data = node.data
    else
      ans_dis = square_radius
      ans_data = data
    end
    if node.left then
      local square_dis = square_dis_node_to_pos(node.left, x, y, z)
      if square_radius > square_dis then
        ans_dis = square_dis
        ans_data = node.data
      else
        ans_dis = square_radius
        ans_data = data
      end
    end
    if node.right then
      local square_dis = square_dis_node_to_pos(node.right, x, y, z)
      if square_radius > square_dis then
        ans_dis = square_dis
        ans_data = node.data
      else
        ans_dis = square_radius
        ans_data = data
      end
    end
    return ans_dis, ans_data
  end
end

function KdTree:SearchNearest_Internal(node, x, y, z)
  if not node.data then
    Log.Warning("KdTree:SearchNearest_Internal, node.data nil")
  end
  if not node.left and not node.right then
    return square_dis_node_to_pos(node, x, y, z), node.data
  end
  local k, node_k
  if 0 == node.axis then
    k = x
    node_k = node.x
  elseif 1 == node.axis then
    k = y
    node_k = node.y
  else
    k = z
    node_k = node.z
  end
  local square_dis, data
  if k > node_k then
    if node.right then
      square_dis, data = self:SearchNearest_Internal(node.right, x, y, z)
    else
      square_dis = square_dis_node_to_pos(node, x, y, z)
      data = node.data
    end
  elseif node.left then
    square_dis, data = self:SearchNearest_Internal(node.left, x, y, z)
  else
    square_dis = square_dis_node_to_pos(node, x, y, z)
    data = node.data
  end
  return self:SearchNearest_Internal_BackTrace(node, x, y, z, square_dis, data)
end

function KdTree:SearchNearest(x, y, z)
  Log.Debug("KdTree:SearchNearest")
  if not self._root then
    Log.Warning("\230\160\185\232\138\130\231\130\185\228\184\141\229\173\152\229\156\168")
    return nil
  end
  Log.Debug("KdTree:SearchNearest_Internal")
  local square_dis, data = self:SearchNearest_Internal(self._root, x, y, z)
  return data
end

return KdTree
