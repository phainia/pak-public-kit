local EventDispatcher = require("Common.EventDispatcher")
local BattleAsyncChain = Class("BattleAsyncChain")

function BattleAsyncChain:Ctor(owner, nodes)
  EventDispatcher():Attach(self)
  self.Owner = owner
  self.Nodes = nodes or {}
  self.Index = 0
  self.Processor = nil
  self.Finished = false
  self.HasStarted = false
end

function BattleAsyncChain:InsertNode(func)
  if not func then
    return
  end
  table.insert(self.Nodes, func)
end

function BattleAsyncChain:InsertNodes(funcs)
  if self.Nodes == funcs then
    Log.Error("You can't insert same piece of data!!")
    return
  end
  if not funcs then
    return
  end
  if 0 == #funcs then
    return
  end
  for _, v in ipairs(funcs) do
    self:InsertNode(v)
  end
end

function BattleAsyncChain:ClearNodes()
  table.clear(self.Nodes)
end

function BattleAsyncChain:StartWithProcessor(processor, p1, p2, p3, p4, p5, p6)
  self.HasStarted = true
  self.Processor = processor
  self:Start(p1, p2, p3, p4, p5, p6)
end

function BattleAsyncChain:Start(p1, p2, p3, p4, p5, p6)
  self.HasStarted = true
  self.Index = 0
  self.Finished = false
  self:Invoke(p1, p2, p3, p4, p5, p6)
end

function BattleAsyncChain:Invoke(p1, p2, p3, p4, p5, p6)
  if self.Index + 1 <= #self.Nodes then
    self.Index = self.Index + 1
    self:Resume(p1, p2, p3, p4, p5, p6)
  else
    Log.Debug("All Done!")
    self.Index = 0
    self.Finished = true
    if self.FinalCallback then
      self.FinalCallback(self.Owner)
    end
    self.HasStarted = false
  end
end

function BattleAsyncChain:Resume(p1, p2, p3, p4, p5, p6)
  local func = self.Nodes[self.Index]
  if not func then
    Log.Error("can't find node data")
    self.Finished = true
    if self.FinalCallback then
      self.FinalCallback(self.Owner)
    end
    self.HasStarted = false
    return
  end
  if type(func) == "function" then
    func(self.Owner, self, p1, p2, p3, p4, p5, p6)
  elseif self.Processor then
    self.Processor(self.Owner, self, func, p1, p2, p3, p4, p5, p6)
  else
    Log.Error("node type is wrong")
    self.Finished = true
    if self.FinalCallback then
      self.FinalCallback(self.Owner)
    end
    self.HasStarted = false
  end
end

function BattleAsyncChain:SetFinishCallback(callback)
  self.FinalCallback = callback
end

function BattleAsyncChain:Destroy()
  table.clear(self.Nodes)
  self.Index = 0
end

return BattleAsyncChain
