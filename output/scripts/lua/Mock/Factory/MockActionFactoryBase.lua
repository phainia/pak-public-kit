local MockActionFactoryBase = Class("MockActionFactoryBase")

function MockActionFactoryBase:Ctor()
  self.registry = {}
  self.subFactory = {}
  self:SetRegistry()
end

function MockActionFactoryBase:SetRegistry()
end

function MockActionFactoryBase:GetSearchKey(MessageId, Request)
  return nil
end

function MockActionFactoryBase:Get(MessageId, Request)
  local key = self:GetSearchKey(MessageId, Request)
  if nil == key then
    return nil
  end
  local class = self.registry[key]
  if nil == class then
    return nil
  end
  if class.SetRegistry and class.Get and class.GetSearchKey then
    local className = class.className
    if nil == self.subFactory[className] then
      self.subFactory[className] = class()
    end
    local factory = self.subFactory[className]
    return factory:Get(MessageId, Request)
  end
  return class(MessageId, Request)
end

return MockActionFactoryBase
