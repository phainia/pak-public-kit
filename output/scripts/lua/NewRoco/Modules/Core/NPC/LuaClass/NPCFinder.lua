local Class = _G.MakeSimpleClass
local PriorityQueue = require("Utils.PriorityQueue")
local NPCFinder = Class("NPCFinder")

local function CmpNpcDis(npc1, npc2)
  local dis1 = npc1.squaredDis2LocalIgnoreZ or 1000000
  local dis2 = npc2.squaredDis2LocalIgnoreZ or 1000000
  return dis1 < dis2
end

function NPCFinder:Ctor(k, handler1, constValidFunc, handler2, adjustValidFunc, handler3, compareFunc, handler4, changeToValidFunc, handler5, changeToInValidFunc)
  self.k = k
  self.num = 0
  self.constValidHandler = handler1
  self.adjustValidHandler = handler2
  self.compareHandler = handler3
  self.constValidFunc = constValidFunc
  self.adjustValidFunc = adjustValidFunc
  self.toValidHandler = handler4
  self.toValidFunc = changeToValidFunc
  self.toInValidHandler = handler5
  self.toInValidFunc = changeToInValidFunc
  self.topKQueue = PriorityQueue()
  self.compareFunc = compareFunc or CmpNpcDis
  self.topKQueue:SetCmpFunction(function(npc1, npc2)
    return not self:CallFunc(self.compareFunc, self.compareHandler, npc1, npc2)
  end)
end

function NPCFinder:IsNPCValid(npc)
  return self:CallFunc(self.constValidFunc, self.constValidHandler, npc)
end

function NPCFinder:CallFunc(func, handler, ...)
  if not func then
    return true
  end
  if handler then
    return func(handler, ...)
  else
    return func(...)
  end
end

function NPCFinder:GetTopK()
  return self.topKQueue._items
end

function NPCFinder:Add(npc)
  if not self.adjustValidFunc or self:CallFunc(self.adjustValidFunc, self.adjustValidHandler, npc) then
    if self.num < self.k then
      self.topKQueue:EnQueue(npc)
      if self.toValidFunc then
        self:CallFunc(self.toValidFunc, self.toValidHandler, npc)
      end
      self.num = self.num + 1
    elseif self:CallFunc(self.compareFunc, self.compareHandler, npc, self.topKQueue:GetTop()) then
      local removenpc = self.topKQueue:DeQueue()
      if self.toInValidFunc then
        self:CallFunc(self.toInValidFunc, self.toInValidHandler, removenpc)
      end
      self.topKQueue:EnQueue(npc)
      if self.toValidFunc then
        self:CallFunc(self.toValidFunc, self.toValidHandler, npc)
      end
    end
  end
end

function NPCFinder:Adjust(npc)
  self.topKQueue:Adjust(npc)
  if self.adjustValidFunc and not self:CallFunc(self.adjustValidFunc, self.adjustValidHandler, npc) then
    self.topKQueue:Remove(npc)
    if self.toInValidFunc then
      self:CallFunc(self.toInValidFunc, self.toInValidHandler, npc)
    end
    self.num = self.num - 1
  end
end

function NPCFinder:Contains(npc)
  return self.topKQueue:Contains(npc)
end

function NPCFinder:Remove(npc)
  if self.topKQueue:Remove(npc) then
    if self.toInValidFunc then
      self:CallFunc(self.toInValidFunc, self.toInValidHandler, npc)
    end
    self.num = self.num - 1
  end
end

return NPCFinder
