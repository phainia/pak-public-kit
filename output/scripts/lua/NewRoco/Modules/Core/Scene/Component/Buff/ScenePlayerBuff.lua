local Buff = Class()

function Buff:Ctor(owner, ...)
  self.owner = owner
end

function Buff:OnBegin(param)
end

function Buff:OnUpdate(deltaTime)
end

function Buff:GetController()
  local ctrl
  if self.owner then
    ctrl = self.owner:GetUEController()
  end
  if nil == ctrl then
    ctrl = UE4.UGameplayStatics.GetPlayerControllerFromID(NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER).viewObj, 0)
  end
  return ctrl
end

function Buff:OnFinish(param)
end

function Buff:OnRefresh()
end

return Buff
