local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local WeakPointRevealComponent = Base:Extend("WeakPointRevealComponent")

function WeakPointRevealComponent:Attach(owner)
  Base.Attach(self, owner)
  self.WeakPointList = {}
  self.UpdatePointIndex = 1
  self.VisibleState = false
  self.weak_attach_list = {}
  self.buff_type_list = {}
  SceneUtils.RegisterNPCVisibilityNotify(self, true)
end

function WeakPointRevealComponent:DeAttach()
  SceneUtils.UnregisterNPCVisibilityNotify(self)
  local viewObj = self:GetOwnerView()
  for i = 1, #self.WeakPointList do
    viewObj:K2_DestroyComponent(self.WeakPointList[i].component)
  end
  _G.UpdateManager:UnRegister(self)
  table.clear(self.WeakPointList)
  Base.DeAttach(self)
end

function WeakPointRevealComponent:ShowWeakness(weak_attach_list, buff_type_list, is_restore)
  self.weak_attach_list = weak_attach_list
  self.buff_type_list = buff_type_list
  self:UpdateWeakPoint(is_restore)
  _G.UpdateManager:Register(self)
end

function WeakPointRevealComponent:UpdateWeakPoint(is_restore)
  local viewObj = self:GetOwnerView()
  if not viewObj then
    return
  end
  if self.VisibleState then
    while #self.WeakPointList < #self.weak_attach_list do
      local WeakPointActorComponent = viewObj:AddComponentByClass(UE4.UNRCChildActorComponent, false, UE4.FTransform(), false)
      WeakPointActorComponent:SetAbsolute(false, false, true)
      WeakPointActorComponent:SetLoadPriority(PriorityEnum.Passive_WorldCombat_Important)
      table.insert(self.WeakPointList, {
        component = WeakPointActorComponent,
        attach_name = "",
        buff_type = 1
      })
    end
    for i = 1, #self.weak_attach_list do
      local attach_name = self.weak_attach_list[i]
      local buff_type = self.buff_type_list[i]
      self.WeakPointList[i].attach_name = attach_name
      self.WeakPointList[i].buff_type = buff_type
      self.WeakPointList[i].is_restore = is_restore
      self.WeakPointList[i].delayFrame = (i - 1) * 5
      self.WeakPointList[i].component:K2_AttachToComponent(viewObj:GetComponentByClass(UE4.USkeletalMeshComponent), attach_name, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.KeepWorld, false)
      self.WeakPointList[i].component:SetComponentActive(true)
      self.WeakPointList[i].component:SetPath("/Game/NewRoco/Modules/Core/NPC/WorldCombat/BP_WeakPoint.BP_WeakPoint_C")
      self.WeakPointList[i].component:SetComponentTickEnabled(false)
    end
    for i = #self.weak_attach_list + 1, #self.WeakPointList do
      self.WeakPointList[i].component:SetComponentActive(false)
      self.WeakPointList[i].component:SetComponentTickEnabled(false)
    end
  else
    for i = 1, #self.WeakPointList do
      self.WeakPointList[i].component:SetComponentActive(false)
      self.WeakPointList[i].component:SetComponentTickEnabled(false)
    end
  end
end

function WeakPointRevealComponent:RemoveWeakness()
  self.buff_type_list = {}
  self.weak_attach_list = {}
  self:UpdateWeakPoint()
  local viewObj = self:GetOwnerView()
  if viewObj then
    for i = 1, #self.WeakPointList do
      viewObj:K2_DestroyComponent(self.WeakPointList[i].component)
    end
  end
  self.WeakPointList = {}
  _G.UpdateManager:UnRegister(self)
end

function WeakPointRevealComponent:TryGetWeakPoint(OtherComponent, item)
  for i, data in ipairs(self.WeakPointList) do
    if data.component == OtherComponent and data.buff_type > 0 then
      return data.attach_name
    end
  end
  if _G.GlobalConfig.DrawThrowDebug then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), item:Abs_K2_GetActorLocation(), 20, 5, UE4.FLinearColor(1.0, 1.0, 0.2, 1), 10, 5)
  end
  for i, data in ipairs(self.WeakPointList) do
    if data.buff_type > 0 then
      local ChildActor = data.component and data.component:GetChildActor()
      local isHit = false
      if ChildActor then
        isHit = ChildActor:CanEnterByWeakPointDoubleCheck(item)
      end
      if isHit then
        return data.attach_name
      end
    end
  end
  return nil
end

function WeakPointRevealComponent:GetBuffTypeByComponent(Component)
  for i, data in ipairs(self.WeakPointList) do
    if data.component == Component then
      return data.buff_type
    end
  end
end

function WeakPointRevealComponent:GetWeakPointDataByComponent(Component)
  for i, data in ipairs(self.WeakPointList) do
    if data.component == Component then
      return data
    end
  end
end

function WeakPointRevealComponent:CanEnterThrowInter(OtherComponent)
  local IsSelfInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  if not IsSelfInWorldCombat then
    return false
  end
  for i, data in ipairs(self.WeakPointList) do
    if data.component == OtherComponent then
      return true
    end
  end
  return false
end

function WeakPointRevealComponent:OnTick(deltaTime)
  if self.UpdatePointIndex > #self.WeakPointList then
    self.UpdatePointIndex = 1
  end
  local WeakPointData = self.WeakPointList[self.UpdatePointIndex]
  local Component = WeakPointData and WeakPointData.component
  local ChildActor = Component and Component:GetChildActor()
  if ChildActor then
    ChildActor:UpdateWeakPoint()
  end
  self.UpdatePointIndex = self.UpdatePointIndex + 1
end

function WeakPointRevealComponent:OnVisible()
  self.VisibleState = true
  self:UpdateWeakPoint()
end

function WeakPointRevealComponent:OnInvisible()
  self.VisibleState = false
  self:UpdateWeakPoint()
end

function WeakPointRevealComponent:OnThrowItemEnter(Item, OtherComponent)
  local ItemLocation = Item:K2_GetActorLocation()
  local MinChildActor, MinChildComponent
  local MinDistance = 1000
  for i, WeakPoint in ipairs(self.WeakPointList) do
    local ChildComponent = WeakPoint.component
    local ChildActor = ChildComponent:GetChildActor()
    if ChildActor then
      local ChildActorLocation = ChildActor:K2_GetActorLocation()
      if ChildActor:CanEnterByWeakPoint(Item) then
        local Distance = UE4.UKismetMathLibrary.Vector_Distance(ItemLocation, ChildActorLocation)
        if Distance < 120 and MinDistance > Distance then
          MinChildActor = ChildActor
          MinChildComponent = ChildComponent
        end
      end
    end
  end
  if MinChildActor and MinChildComponent then
    self:GetOwnerView():OnThrowItemEnter(Item, MinChildComponent)
    MinChildActor:OnHitByPetBall(Item)
  else
    self:GetOwnerView():OnThrowItemEnter(Item, nil)
  end
  _G.NRCAudioManager:PlaySound3DWithActorAuto(300203, self:GetOwnerView())
end

return WeakPointRevealComponent
