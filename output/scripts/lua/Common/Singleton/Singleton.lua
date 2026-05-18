local Class = _G.MakeSimpleClass
local Singleton = Class("Singleton")
local SingletonMgr = _G.SingletonMgr

function Singleton:Ctor(name)
  if not name then
    Log.Error("singleton should set name")
  end
  self.name = name
  self.tickable = false
  self.isFree = false
  SingletonMgr._AddSingleton(self.name, self)
end

function Singleton:Free()
  if self.isFree then
    return
  end
  if self.tickable then
    self:EnableTick(false)
  end
  SingletonMgr._FreeSingleton(self.name)
  self.isFree = true
end

function Singleton:EnableTick(flag)
  if self.tickable == flag then
    return
  end
  self.tickable = flag
  if flag then
    _G.UpdateManager:Register(self)
  else
    _G.UpdateManager:UnRegister(self)
  end
end

function Singleton:OnTick(deltaTime)
end

return Singleton
