local BattleObjectManager = {}
BattleObjectManager.log = false
BattleObjectManager.Objects = Array()
BattleObjectManager.isTicking = false
BattleObjectManager.waitList = Array()

function BattleObjectManager:EnterBattle()
  return self
end

function BattleObjectManager:LeaveBattle()
  self.Objects:Clear()
  self.waitList:Clear()
end

function BattleObjectManager:AddObject(object)
  if not object then
    return
  end
  if object == self then
    return
  end
  if object.isManaged then
    return
  end
  if object.name then
    self:Log("add object to manager : ", object.name)
  else
    self:Log("add object to manager : ", object)
  end
  if self.isTicking then
    self.waitList:Add(object)
  else
    self.Objects:Add(object)
  end
  object.isManaged = true
end

function BattleObjectManager:RemoveObject(object)
  if not object then
    self:Log("object is nil")
    return
  end
  if object == self then
    self:Log("object cannot be self")
    return
  end
  if not object.isManaged then
    self:Log("object not managed")
    return
  end
  if object.name then
    self:Log("remove object from manager : ", object.name)
  else
    self:Log("remove object from manager : ", object)
  end
  object.isManaged = false
  if self.isTicking then
    self.waitList:Add(object)
  else
    self.Objects:Remove(object)
  end
end

function BattleObjectManager:OnTick(deltaTime)
  self.isTicking = true
  for _, v in ipairs(self.Objects:Items()) do
    if v.isManaged then
      v:OnTick(deltaTime)
    end
  end
  self.isTicking = false
  if self.waitList:Size() > 0 then
    for _, v in ipairs(self.waitList:Items()) do
      if v.isManaged then
        self.Objects:Add(v)
      else
        self.Objects:Remove(v)
      end
    end
    self.waitList:Clear()
  end
end

function BattleObjectManager:Log(...)
  if self.log then
    Log.Debug(...)
  end
end

return BattleObjectManager
