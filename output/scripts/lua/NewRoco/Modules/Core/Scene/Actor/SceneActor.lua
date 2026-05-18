local Class = _G.MakeSimpleClass
local EventDispatcher = require("Common.EventDispatcher")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local SceneActorDebugInfo = require("NewRoco.Modules.Core.Scene.Actor.DebugInfo.SceneActorDebugInfo")
local getmetatable = _ENV.getmetatable
local ipairs = _ENV.ipairs
local SceneActor = Class("SceneActor")
SceneActor.isDestroy = false
SceneActor:SetMemberCount(8)
EventDispatcher.BindClass(SceneActor)

function SceneActor:PreCtor(module)
  self.viewObj = nil
  self.components = nil
  self.module = nil
  self.isDestroy = false
  self.isPaused = false
  self.debugInfo = SceneActorDebugInfo.new(self)
end

function SceneActor:Ctor(module)
  EventDispatcher():Attach(self)
  self.module = module
  NRCEventCenter:RegisterEvent(self.name, self, NRCGlobalEvent.ON_RECONNECT_ENDURING, self.OnDisConnect)
  NRCEventCenter:RegisterEvent(self.name, self, NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
end

function SceneActor:Destroy()
  self.isDestroy = true
  self:RemoveAllComponent()
  EventDispatcher.Detach(self)
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.ON_RECONNECT_ENDURING, self.OnDisConnect)
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
end

function SceneActor:SetViewObj(viewObj)
  self.viewObj = viewObj
  self.viewObjRef = UE4.UObject.IsValid(viewObj) and UnLua.Ref(viewObj)
  if self.components then
    local items = self.components:Items()
    for _, v in ipairs(items) do
      if v.OnSetViewObj then
        v:OnSetViewObj()
      end
    end
  end
end

function SceneActor:InitComponent()
end

function SceneActor:EnsureComponent(ComponentClass, ...)
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

function SceneActor:AddComponent(component)
  if self.components == nil then
    self.components = Array()
  end
  component:Attach(self)
  self.components:Add(component)
end

function SceneActor:GetComponent(ClassTable)
  local MemberName = ClassTable.className
  local Instance = rawget(self, MemberName)
  if Instance then
    return Instance
  end
  if self.components then
    local items = self.components:Items()
    for _, v in ipairs(items) do
      if v:InstanceOf(ClassTable) then
        return v
      end
    end
  end
  return nil
end

function SceneActor:RemoveComponent(Component)
  if self.components then
    Component:DeAttach()
    self.components:Remove(Component)
  end
  local MemberName = Component.className
  rawset(self, MemberName, nil)
end

function SceneActor:RemoveAllComponent()
  if self.components then
    local items = self.components:Items()
    for i = #items, 1, -1 do
      local curItem = items[i]
      curItem:DeAttach()
      curItem:Destroy()
    end
    self.components = nil
  end
end

function SceneActor:Update(DeltaTime)
  if self.components then
    local items = self.components:Items()
    for _, v in ipairs(items) do
      if v.enabled then
        v:Update(DeltaTime)
      end
    end
  end
  if self.debugInfo then
    self.debugInfo:DrawDebugInfo(DeltaTime)
  end
end

function SceneActor:UpdateByDistance(deltaTime)
  self:InvokeEnabledComponents("UpdateByDistance", deltaTime)
end

function SceneActor:FixedUpdate()
  if self.components then
    local items = self.components:Items()
    for i, v in ipairs(items) do
      if v.enabled then
        v:FixedUpdate()
      end
    end
  end
end

function SceneActor:OnVisible()
  local poolKey = self:GetPoolKey()
  local actorPool = SceneModule.poolManager:GetPool(poolKey)
  local viewObj
  if not actorPool:IsEmpty() then
    viewObj = actorPool:Get()
  end
  if not UE4.UObject.IsValid(viewObj) then
    viewObj = self:LoadBP(poolKey)
  end
  self:SetViewObj(viewObj)
  if self.components then
    local items = self.components:Items()
    for i, v in ipairs(items) do
      if v.enabled then
        v:OnVisible()
      end
    end
  end
end

function SceneActor:OnInvisible()
  if self.viewObj then
    local actorPool = SceneModule.poolManager:GetPool(self:GetPoolKey())
    actorPool:Recycle(self.viewObj)
    self.viewObj = nil
    self.viewObjRef = nil
  end
  if self.components then
    local items = self.components:Items()
    for i, v in ipairs(items) do
      if v.enabled then
        v:OnInvisible()
      end
    end
  end
end

function SceneActor:GetPoolKey()
end

function SceneActor:LoadBP(AssetPath)
  local class
  if nil == class then
    return false
  end
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 0)
  local fTransfom = UE4.FTransform(quat, UE4Helper.ZeroVector)
  local viewObj = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(class, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  return viewObj
end

function SceneActor:OnReConnect(bLight)
  if self.components then
    local items = self.components:Items()
    for i, v in ipairs(items) do
      v:OnReConnect(bLight)
      v:SetEnable(true)
    end
  end
end

function SceneActor:OnDisConnect()
  if self.components then
    local items = self.components:Items()
    for i, v in ipairs(items) do
      if v.enabled then
        v:OnDisConnect()
        v:SetEnable(false)
      end
    end
  end
end

function SceneActor:Pause(pause)
  if self.components then
    local items = self.components:Items()
    for i, v in ipairs(items) do
      v:OnPause(pause)
      v:SetEnable(not pause)
    end
  end
  self.isPaused = pause
end

function SceneActor:SetCustomDepth(depth)
end

function SceneActor:InvokeAllComponents(FuncName, ...)
  if not FuncName then
    return
  end
  if not self.components then
    return
  end
  local BaseFunc = ActorComponent[FuncName]
  local items = self.components:Items()
  for _, Value in ipairs(items) do
    local CompFunc = rawget(getmetatable(Value), FuncName)
    if CompFunc and CompFunc ~= BaseFunc then
      CompFunc(Value, ...)
    end
  end
end

function SceneActor:InvokeEnabledComponents(FuncName, ...)
  if not FuncName then
    return
  end
  if not self.components then
    return
  end
  local BaseFunc = ActorComponent[FuncName]
  local items = self.components:Items()
  for _, Value in ipairs(items) do
    if Value.enabled then
      local CompFunc = rawget(getmetatable(Value), FuncName)
      if CompFunc and CompFunc ~= BaseFunc then
        CompFunc(Value, ...)
      end
    end
  end
end

return SceneActor
