local Class = _G.MakeSimpleClass
local ObjectPool = require("Utils.ObjectPool")
local NodeCount = 1024
local LeasingMaxNodeCount = 0
local LeasingNodeCount = 0
local PrevNodeCount = NodeCount
local NodeCountByTag = {}
local NOT_SHIPPING = not RocoEnv.IS_SHIPPING
local NodePoolHead

local function PoolInsert(Node)
  if NodePoolHead then
    Node.Next = NodePoolHead
    NodePoolHead.Prev = Node
    NodePoolHead = Node
  else
    NodePoolHead = Node
  end
end

local function PoolRemove()
  if NodePoolHead then
    local Next = NodePoolHead.Next
    local Ret = NodePoolHead
    NodePoolHead = Next
    Ret.Next = nil
    Ret.Prev = nil
    Ret.Value = nil
    Ret.Tag = ""
    Ret.Removed = false
    return Ret
  else
    if NOT_SHIPPING and LeasingNodeCount > LeasingMaxNodeCount then
      LeasingMaxNodeCount = LeasingNodeCount
      if LeasingNodeCount > PrevNodeCount + 50 then
        PrevNodeCount = LeasingNodeCount
        Log.Debug("\233\147\190\232\161\168\232\138\130\231\130\185\229\136\176\228\186\134\229\136\176\228\186\134\230\150\176\233\171\152", LeasingNodeCount)
      end
    end
    return {
      Next = nil,
      Prev = nil,
      Value = nil,
      Tag = "",
      Removed = false
    }
  end
end

for _ = 1, NodeCount do
  PoolInsert({
    Next = nil,
    Prev = nil,
    Value = nil,
    Tag = "",
    Removed = false
  })
end

local function GetNode(Value, Tag)
  if NOT_SHIPPING then
    LeasingNodeCount = LeasingNodeCount + 1
    local Count = NodeCountByTag[Tag]
    if Count then
      NodeCountByTag[Tag] = Count + 1
    else
      NodeCountByTag[Tag] = 1
    end
  end
  local Node = PoolRemove()
  Node.Value = Value
  Node.Tag = Tag
  return Node
end

local function ReturnNode(Node)
  if NOT_SHIPPING then
    local Count = NodeCountByTag[Node.Tag]
    if Count then
      NodeCountByTag[Node.Tag] = Count - 1
    end
    LeasingNodeCount = LeasingNodeCount - 1
    if LeasingNodeCount < PrevNodeCount - 100 then
      PrevNodeCount = LeasingNodeCount
      Log.Debug("\233\147\190\232\161\168\232\138\130\231\130\185\230\149\176\233\135\143\233\153\141\228\189\142\228\184\186", LeasingNodeCount)
    end
  end
  Node.Next = nil
  Node.Prev = nil
  Node.Value = nil
  Node.Tag = ""
  Node.Removed = false
  PoolInsert(Node)
end

local LinkedListPoolSize = 1024
local LinkedListPool
local LinkedList = Class("LinkedList")
LinkedList:SetMemberCount(16)

function LinkedList:PreCtor()
  self.MarkClear = false
  self.ValueToNode = table.new(0, 4)
  self.HashDict = table.new(0, 4)
  self.Tag = ""
  self.IteratingCount = 0
  self.NextIterator = nil
  self.Head = nil
  self.SubHead = nil
  self.CallingNode = nil
end

function LinkedList:Ctor(Tag)
  self.Tag = Tag or "Default"
end

local function createFunc(tag)
  return LinkedList(tag)
end

local function cleanFunc(obj)
  obj.NextIterator = nil
  obj.Head = nil
  obj.SubHead = nil
  obj.MarkClear = false
  obj.ValueToNode = table.new(0, 4)
  obj.HashDict = table.new(0, 4)
  obj.Tag = "Default"
  obj.IteratingCount = 0
end

LinkedListPool = ObjectPool(createFunc, cleanFunc, LinkedListPoolSize, "LinkedList")
LinkedListPool:WarmingUp()

function LinkedList.CreateFromPool(Tag)
  return LinkedListPool:get(Tag)
end

function LinkedList.ReturnToPool(obj)
  return LinkedListPool:release(obj)
end

function LinkedList:CycleCheck()
  if not self.Head then
    return false
  end
  local Fast = self.Head
  local Slow = self.Head
  while Fast and Fast.Next do
    Slow = Slow.Next
    Fast = Fast.Next.Next
    if Fast == Slow then
      return true
    end
  end
  return false
end

function LinkedList:Recovery()
  if 0 == self.IteratingCount then
    return
  end
  if self.CallingNode == nil then
    return
  end
  Log.Error("LinkedList:Recovery\239\188\140\231\167\187\233\153\164\230\138\165\233\148\153\231\154\132\232\138\130\231\130\185\239\188\129", self.Tag)
  self.CallingNode.Removed = true
  self.CallingNode = nil
  self.IteratingCount = 0
end

function LinkedList:Iterate(Caller, Callback, ...)
  if type(Callback) ~= "function" then
    Log.Error("LinkedList:Iterate Callback\228\184\141\230\152\175function", Callback)
    return false
  end
  self.IteratingCount = self.IteratingCount + 1
  local Current = self.Head
  local Tail, Next
  local Length = 0
  while Current do
    Next = Current.Next
    Length = Length + 1
    if not Current.Removed then
      self.CallingNode = Current
      local Value = Current.Value
      if Caller then
        Callback(Caller, Value, ...)
      else
        Callback(Value, ...)
      end
      self.CallingNode = nil
    end
    Tail = Current
    Current = Next
  end
  self.IteratingCount = self.IteratingCount - 1
  if self.IteratingCount > 0 then
    return true
  end
  if Tail then
    Tail.Next = self.SubHead
  end
  if self.SubHead then
    self.SubHead.Prev = Tail
  end
  self.SubHead = nil
  if self.MarkClear then
    self:RemoveAll()
    self.MarkClear = false
  else
    self:Purge()
  end
  return true
end

function LinkedList:Purge()
  local Current = self.Head
  local FirstValid, LastValid, Next, Prev
  local RemoveCount = 0
  while Current do
    Next = Current.Next
    Prev = Current.Prev
    if Current.Removed then
      self.ValueToNode[Current.Value] = nil
      if Next then
        Next.Prev = Prev
      end
      if Prev then
        Prev.Next = Next
      end
      Current.Next = nil
      Current.Prev = nil
      RemoveCount = RemoveCount + 1
      ReturnNode(Current)
    else
      FirstValid = FirstValid or Current
      Current.Prev = LastValid
      if LastValid then
        LastValid.Next = Current
      end
      LastValid = Current
    end
    Current = Next
  end
  self.Head = FirstValid
end

function LinkedList:Insert(Value)
  if not Value then
    Log.Error("LinkedList:Add \230\143\146\229\133\165\231\154\132\229\128\188\228\184\186\231\169\186", self.Tag)
    return false
  end
  local ExistNode = self.ValueToNode[Value]
  if ExistNode then
    if ExistNode.Removed then
      ExistNode.Removed = false
      return true
    end
    Log.Debug("LinkedList:Add \233\135\141\229\164\141\230\183\187\229\138\160", Value.name and Value.name or "\230\178\161\229\144\141\229\173\151")
    return false
  end
  local Node = GetNode(Value, self.Tag)
  self.ValueToNode[Value] = Node
  if self.IteratingCount > 0 then
    if self.SubHead then
      Node.Next = self.SubHead
      self.SubHead.Prev = Node
    end
    self.SubHead = Node
    self.SubHead.Prev = nil
  else
    if self.Head then
      Node.Next = self.Head
      self.Head.Prev = Node
    end
    self.Head = Node
    self.Head.Prev = nil
  end
  return true
end

function LinkedList:InsertWithHash(Value, Args1, Args2)
  if Args1 and Args2 then
    if not self.HashDict[Args1] then
      self.HashDict[Args1] = {}
    end
    if not self.HashDict[Args1][Args2] then
      self.HashDict[Args1][Args2] = {}
    end
    self.HashDict[Args1][Args2] = Value
    self:Insert(Value)
  else
    Log.Error("LinkedList InsertWithHash:Args1 or Args2 is nil")
  end
end

function LinkedList:Remove(Value)
  if not Value then
    Log.Error("LinkedList:Remove \231\167\187\233\153\164\231\154\132\229\128\188\228\184\186\231\169\186", self.Tag)
    return false
  end
  local NodeToRemove = self.ValueToNode[Value]
  if not NodeToRemove then
    return false
  end
  if self.IteratingCount > 0 then
    NodeToRemove.Removed = true
  else
    self.ValueToNode[Value] = nil
    NodeToRemove.Value = nil
    if self.Head == NodeToRemove then
      self.Head = self.Head.Next
      if self.Head then
        self.Head.Prev = nil
      end
    else
      local PrevNode = NodeToRemove.Prev
      local NextNode = NodeToRemove.Next
      PrevNode.Next = NextNode
      if NextNode then
        NextNode.Prev = PrevNode
      end
    end
    NodeToRemove.Next = nil
    NodeToRemove.Prev = nil
    ReturnNode(NodeToRemove)
  end
  if self.CallingNode == NodeToRemove then
    self.CallingNode = nil
  end
  return true
end

function LinkedList:RemoveWithHash(Value, Arg1, Arg2)
  if self.HashDict[Arg1] then
    self.HashDict[Arg1][Arg2] = nil
  end
  self:Remove(Value)
end

function LinkedList:RemoveAll()
  if self.IteratingCount > 0 then
    self.MarkClear = true
    return
  end
  if self.CallingNode then
    self.CallingNode = nil
  end
  local Current = self.Head
  while Current do
    local Node = Current
    Current = Current.Next
    Node.Next = nil
    Node.Prev = nil
    Node.Value = nil
    ReturnNode(Node)
  end
  self.Head = false
  table.clear(self.ValueToNode)
  table.clear(self.HashDict)
end

function LinkedList:FindValue(Finder, FinderCallback, Arg1, Arg2, Arg3, Arg4)
  if not FinderCallback then
    return nil
  end
  for Value, Node in pairs(self.ValueToNode) do
    local Found = false
    if Finder then
      Found = FinderCallback(Finder, Value, Arg1, Arg2, Arg3, Arg4)
    else
      Found = FinderCallback(Value, Arg1, Arg2, Arg3, Arg4)
    end
    if Found then
      return Value
    end
  end
  return nil
end

function LinkedList:FindValueWithHash(Finder, FinderCallback, Arg1, Arg2)
  if self.HashDict[Arg1] and self.HashDict[Arg1][Arg2] then
    return self.HashDict[Arg1][Arg2]
  end
  return nil
end

function LinkedList:PrintAll()
  if self.IteratingCount > 0 then
    Log.Debug("\230\173\163\229\156\168\233\129\141\229\142\134\228\184\173...\232\175\183\231\168\141\229\144\142\229\134\141\232\175\149")
    return
  end
  local Current = self.Head
  if not Current then
    Log.Debug("\233\129\141\229\142\134\233\147\190\232\161\168: \233\147\190\232\161\168\228\184\186\231\169\186")
    return
  end
  local Count = 1
  while Current do
    Log.Debug("\233\129\141\229\142\134\233\147\190\232\161\168:", Count, Current.Value)
    Current = Current.Next
    Count = Count + 1
  end
end

function LinkedList:HasAny()
  return self.Head ~= false and self.Head ~= nil
end

function LinkedList.GetNodeCounts()
  local Ret = {}
  for Tag, Count in pairs(NodeCountByTag) do
    if Count >= 10 then
      Ret[Tag] = Count
    end
  end
  return Ret
end

function LinkedList.GetTotalNodeCount()
  return LeasingNodeCount, LeasingMaxNodeCount
end

return LinkedList
