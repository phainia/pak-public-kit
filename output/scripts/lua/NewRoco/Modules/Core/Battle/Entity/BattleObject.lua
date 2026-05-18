local Class = _G.MakeSimpleClass
local EventDispatcher = require("Common.EventDispatcher")
local BattleObject = Class("BattleObject")
BattleObject.log = false

function BattleObject:Ctor()
  self.destroyed = false
  self.destroying = false
  self.destroyModel = false
  self.components = Array()
  self.isManaged = false
  EventDispatcher():Attach(self)
  local battleManager = _G.BattleManager
  if battleManager then
    battleManager.battleObjectManager:AddObject(self)
  end
end

function BattleObject:Destroy()
  if self.destroyed then
    return
  end
  if self.destroying then
    return
  end
  self.destroying = true
  self:Log("Destroy object : ", self.name)
  self:RecoverFromG6()
  local items = self.components:Items()
  for _, v in ipairs(items) do
    if v then
      v:Destroy()
    end
  end
  self.components = nil
  local battleManager = _G.BattleManager
  if battleManager then
    battleManager.battleObjectManager:RemoveObject(self)
  else
    self:Log("BattleManager is nil")
  end
  if self._eventDispatcher then
    self._eventDispatcher:RemoveAllListeners()
    self._eventDispatcher = nil
  end
  self.destroyed = true
  self.destroying = false
end

function BattleObject:AddComponent(component)
  if not component then
    return
  end
  self.components:Add(component)
  component.object = self
  component:Start()
  if component.enable then
    component:Enable()
  end
  return component
end

function BattleObject:RemoveComponent(component)
  if not component then
    return
  end
  self:Log("remove component:" .. component.name)
  self.components:Remove(component)
  component.object = nil
  if component.enable then
    component:SetEnable(false)
  end
  component:Destroy()
end

function BattleObject:EnsureComponent(ComponentClass, ...)
  local MemberName = ComponentClass.className
  local Instance = rawget(self, MemberName)
  if Instance then
    return Instance
  end
  Instance = ComponentClass(...)
  rawset(self, MemberName, Instance)
  self:AddComponent(Instance)
  return Instance
end

function BattleObject:OnTick(deltaTime)
  local items = self.components:Items()
  for _, v in ipairs(items) do
    if v and v.enable then
      v:OnTick(deltaTime)
    end
  end
end

function BattleObject:Log(...)
  if self.log then
    Log.Debug(...)
  end
end

function BattleObject:PrepareForG6()
  if self.model and UE4.UObject.IsValid(self.model) then
    local meshComp = self.model:GetComponentByClass(UE4.USkeletalMeshComponent)
    if meshComp and UE4.UObject.IsValid(meshComp) then
      self.modelBoundsScale = meshComp.BoundsScale
      self.modelVisibilityBasedAnimTickOption = meshComp.VisibilityBasedAnimTickOption
      meshComp:SetBoundsScale(20)
      meshComp.VisibilityBasedAnimTickOption = UE.EVisibilityBasedAnimTickOption.AlwaysTickPoseAndRefreshBones
    end
  end
end

function BattleObject:RecoverFromG6()
  if self.model and UE4.UObject.IsValid(self.model) then
    local meshComp = self.model:GetComponentByClass(UE4.USkeletalMeshComponent)
    if meshComp and UE4.UObject.IsValid(meshComp) then
      if self.modelBoundsScale then
        meshComp:SetBoundsScale(self.modelBoundsScale)
        self.modelBoundsScale = nil
      end
      if self.modelVisibilityBasedAnimTickOption then
        meshComp.VisibilityBasedAnimTickOption = self.modelVisibilityBasedAnimTickOption
        self.modelVisibilityBasedAnimTickOption = nil
      end
    end
  end
end

return BattleObject
