local Class = _G.MakeSimpleClass
local NodeCount = 0
local PoolCount = 0
local PoolHead
local GetFrameCount = _G.GetFrameCount

local function MakeNode(Tag)
  if PoolHead then
    PoolCount = PoolCount - 1
    local Head = PoolHead
    local Next = PoolHead.Next
    PoolHead = Next
    Head.Next = nil
    Head.Prev = nil
    return Head
  else
    NodeCount = NodeCount + 1
    local Node = {Next = nil, Prev = nil}
    Log.Debug("\231\148\179\232\175\183\230\150\176\231\154\132\232\138\130\231\130\185...", Tag, NodeCount, PoolCount, Node)
    return Node
  end
end

local function ReturnNode(Node, Tag)
  table.clear(Node)
  if PoolHead then
    Node.Next = PoolHead
  end
  PoolHead = Node
  PoolCount = PoolCount + 1
end

local FrameLimitQueue = Class("FrameLimitQueue")
FrameLimitQueue:SetMemberCount(5)

function FrameLimitQueue:PreCtor(Name, MaxPerFrame)
  self.Name = Name or "Unknown"
  self.MaxPerFrame = MaxPerFrame or 1
  self.CurrentCount = 0
  self.FrameCount = -1
  self.Head = nil
  self.Tail = nil
end

function FrameLimitQueue:IsEmpty()
  return self.Head == nil
end

function FrameLimitQueue:Push()
  local Node = MakeNode(self.Name)
  if self.Head then
    Node.Prev = self.Tail
    self.Tail.Next = Node
    self.Tail = Node
  else
    self.Head = Node
    self.Tail = Node
  end
  return Node
end

function FrameLimitQueue:FramedPop()
  local NowFrameCounter = GetFrameCount()
  if self.FrameCount == NowFrameCounter then
    if self.CurrentCount >= self.MaxPerFrame then
      return nil
    end
  else
    self.CurrentCount = 0
    self.FrameCount = NowFrameCounter
  end
  self.CurrentCount = self.CurrentCount + 1
  local First = self:Pop()
  return First
end

function FrameLimitQueue:Pop()
  local First = self.Head
  if not First then
    return nil
  end
  local Second = self.Head.Next
  if Second then
    Second.Prev = nil
  else
    self.Tail = nil
  end
  self.Head = Second
  First.Next = nil
  return First
end

function FrameLimitQueue:ReturnNode(Node)
  ReturnNode(Node, self.Name)
end

function FrameLimitQueue:ClearAll()
  local Current = self.Head
  while Current do
    local Node = Current
    Current = Current.Next
    ReturnNode(Node)
  end
  self.Head = nil
  self.Tail = nil
end

return FrameLimitQueue
