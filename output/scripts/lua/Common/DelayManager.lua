local LinkedList = require("Utils.LinkedList")
local Base = require("Common.Singleton.Singleton")
local DelayManager = Base:Extend("DelayManager")

function DelayManager:Ctor(name)
  self.name = name or "DelayManager"
  Base.Ctor(self, self.name)
  self.ID = 1
  self.ItemList = LinkedList("DelayManager")
  self:EnableTick(true)
end

function DelayManager:DelayFrames(frame, callback, ...)
  assert(type(frame) == "number", "DelayFrames needs number")
  assert(type(callback) == "function", "DelayFrames needs function")
  if 0 == frame then
    callback(...)
    return
  end
  local arg = {
    ...
  }
  
  local function CreateDelayFrames(id, _frame, _callback, owner)
    local object = table.new(0, 4)
    object._id = id
    object._callback = _callback
    object._frame = _frame or 1
    
    function object:_tick(deltaTime)
      self._frame = self._frame - 1
      if self._frame > 0 then
        return
      end
      self._callback(table.unpack(arg))
      owner:Remove(self)
    end
    
    return object
  end
  
  local id = self.ID
  self.ID = self.ID + 1
  local item = CreateDelayFrames(id, frame, callback, self.ItemList)
  self.ItemList:Insert(item)
  return id
end

function DelayManager:DelayFramesEx(id, frame, callback, ...)
  if id then
    self:CancelDelayById(id)
  end
  return self:DelayFrames(frame, callback, ...)
end

function DelayManager:DelaySeconds(seconds, callback, ...)
  if 0 == seconds then
    callback(...)
    return
  end
  assert(type(seconds) == "number", "DelaySeconds needs number")
  assert(type(callback) == "function", "DelaySeconds needs function")
  local arg = {
    ...
  }
  
  local function CreateDelaySeconds(id, sec, _callback, owner)
    local object = table.new(0, 4)
    object._id = id
    object._callback = _callback
    object._seconds = sec or 1
    
    function object:_tick(deltaTime)
      self._seconds = self._seconds - deltaTime
      if self._seconds > 0 then
        return
      end
      self._callback(table.unpack(arg))
      owner:Remove(self)
    end
    
    return object
  end
  
  local id = self.ID
  self.ID = self.ID + 1
  local item = CreateDelaySeconds(id, seconds, callback, self.ItemList)
  self.ItemList:Insert(item)
  return id
end

function DelayManager:OnTick(deltaTime)
  self.ItemList:Recovery()
  self.ItemList:Iterate(self, self.IterateItems, deltaTime)
end

function DelayManager:IterateItems(Item, DeltaTime)
  if not Item then
    return
  end
  Item:_tick(DeltaTime)
end

function DelayManager:CancelDelay(funOrId)
  if type(funOrId) == "function" then
    local ItemByFunc = self.ItemList:FindValue(self, self.CompareByFunction, funOrId)
    if not ItemByFunc then
      return
    end
    self.ItemList:Remove(ItemByFunc)
  elseif type(funOrId) == "number" then
    local ItemByID = self.ItemList:FindValue(self, self.CompareByID, funOrId)
    if not ItemByID then
      return
    end
    self.ItemList:Remove(ItemByID)
  else
    Log.Error("Unhandled CancelDelay type !!!")
  end
end

function DelayManager:CancelDelayByFunc(fun)
  local Item = self.ItemList:FindValue(self, self.CompareByFunction, fun)
  if not Item then
    return
  end
  self.ItemList:Remove(Item)
end

function DelayManager:CancelDelayById(id)
  local Item = self.ItemList:FindValue(self, self.CompareByID, id)
  if not Item then
    return
  end
  self.ItemList:Remove(Item)
end

function DelayManager:CancelDelayByIdEx(id)
  if id then
    self:CancelDelayById(id)
  end
  return nil
end

function DelayManager:CompareByID(Value, ID)
  return Value._id == ID
end

function DelayManager:CompareByFunction(Value, Func)
  return Value._callback == Func
end

function DelayManager:ClearAll()
  self.ItemList:RemoveAll()
end

return DelayManager
