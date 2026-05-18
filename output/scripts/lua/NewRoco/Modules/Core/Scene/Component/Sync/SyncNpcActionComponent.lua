local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NavigationComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.NavigationComponent")
local NpcActionOperation = require("NewRoco.Modules.Core.Scene.Component.Sync.NpcActionOperation")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Queue = require("Utils.Queue")
local Base = ActorComponent
local SyncNpcActionComponent = Base:Extend("SyncNpcActionComponent")

function SyncNpcActionComponent:Attach(owner)
  Base.Attach(self, owner)
  self.operation_queue = Queue()
end

function SyncNpcActionComponent:DeAttach()
  Base.DeAttach(self)
end

function SyncNpcActionComponent:Destroy()
  Base.Destroy(self)
end

function SyncNpcActionComponent:DealClientOperation(operation)
  if operation.npc_action_info.action_status == NPCModuleEnum.ActionStatus.Begin then
    local actionOperation = NpcActionOperation(operation, self)
    self.operation_queue:AddLast(actionOperation)
    self:UpdateCurrentOperation()
    self.currentOperation:Execute()
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, operation.operator_id)
  end
end

function SyncNpcActionComponent:DealNextOperation()
  self.currentOperation = nil
  self:UpdateCurrentOperation()
  if self.currentOperation then
    self.currentOperation:Execute()
  end
end

function SyncNpcActionComponent:UpdateCurrentOperation()
  if self.currentOperation == nil and self.operation_queue:Size() > 0 then
    self.currentOperation = self.operation_queue:First()
    self.operation_queue:RemoveFirst()
  end
end

function SyncNpcActionComponent:GetInteractPlayer()
  if self.currentOperation then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, self.currentOperation.operator_id)
    return player
  else
    return nil
  end
end

function SyncNpcActionComponent:Clear()
  self.currentOperation = nil
end

function SyncNpcActionComponent:IsPlaying()
  return self.currentOperation ~= nil
end

return SyncNpcActionComponent
