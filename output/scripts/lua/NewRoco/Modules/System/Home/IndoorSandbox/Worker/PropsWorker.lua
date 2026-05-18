local PropsWorker = Class("PropsWorker")

function PropsWorker:Ctor(Task)
  self.Task = Task
  local PropsActor = HomeIndoorSandbox.ResMgr:ResolvePropsActor(Task.PropsData)
  local World = UE4Helper.GetCurrentWorld()
  if not PropsActor and HomeIndoorSandbox:Ensure(World and UE.UObject.IsValid(World), "invalid world") then
    local Built = World:Abs_SpawnActor(Task.BlueprintClass, self.Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if HomeIndoorSandbox:Ensure(Built, "spawn failed", Task.PropsData.Id, Task.BlueprintClass) then
      PropsActor = Built
      PropsActor._TheRef = UnLua.Ref(Built)
    end
  end
  if PropsActor then
    self.PropsActor = PropsActor
    self:OnPostLoad(PropsActor)
    if PropsActor.UpdateConfig then
      PropsActor:UpdateConfig(Task.PropsData.ConfId)
    end
  end
end

function PropsWorker:OnPostLoad(PropsActor)
  HomeIndoorSandbox.HomePropsServ:OnPostLoad(self.Task.RoomId, PropsActor, self.Task.PropsData)
end

function PropsWorker:IsFinish()
  return true
end

return PropsWorker
