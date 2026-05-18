local BattlePetStateNode = NRCClass()

function BattlePetStateNode:Ctor(name, parentNode, isUnique, owner)
  self.name = name
  self.count = 0
  self.parentNode = parentNode
  self.childNodes = {}
  self.isUnique = isUnique
  self.owner = owner
end

function BattlePetStateNode:SetBuffSign(buffSign)
  self.buffSign = buffSign
end

function BattlePetStateNode:SetValue(boo, isForce)
  if self.isUnique and not isForce then
    self.parentNode:SetChildValue(self:GetName(), boo)
  else
    local oldValue = self:GetValue()
    if boo then
      self.count = self.count + 1
    else
      self.count = self.count - 1
    end
    if oldValue ~= self:GetValue() then
      self.owner:NodeValueChange(self)
    end
    if self.count < 0 then
      self.count = 0
      Log.Warning("\230\179\168\230\132\143BattlePetStateNode \232\174\161\230\149\176\229\153\168\229\188\130\229\184\184:", self.count)
    end
  end
end

function BattlePetStateNode:GetValue()
  return self.count > 0
end

function BattlePetStateNode:SetChildValue(childName, boo)
  for i = 1, #self.childNodes do
    local node = self.childNodes[i]
    if node:GetName() == childName then
      node:SetValue(boo, true)
    else
      node:SetValue(false)
    end
  end
end

function BattlePetStateNode:SetParent(node)
  self.parentNode = node
end

function BattlePetStateNode:AddChild(node)
  table.insert(self.childNodes, node)
end

function BattlePetStateNode:IsRootNode()
  return self.parentNode == nil
end

function BattlePetStateNode:GetName()
  return self.name
end

function BattlePetStateNode:ResetState()
  self.count = 0
end

return BattlePetStateNode
