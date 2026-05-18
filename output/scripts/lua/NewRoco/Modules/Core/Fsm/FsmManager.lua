local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local EventDispatcher = require("Common.EventDispatcher")
local Singleton = _G.Singleton
local FsmManager = Singleton:Extend("FsmManager")

function FsmManager:Ctor(name)
  Singleton.Ctor(self, name)
  EventDispatcher():Attach(self)
  self.runningFsms = {}
  self:EnableTick(true)
end

function FsmManager:Play(fsm)
  self:Add(fsm)
  self:SendEvent(FsmEnum.ManagerEvents.Changed, fsm, "Play")
end

function FsmManager:Stop(fsm)
  self:Remove(fsm)
  self:SendEvent(FsmEnum.ManagerEvents.Changed, fsm, "Stop")
end

function FsmManager:Resume(fsm)
  self:SendEvent(FsmEnum.ManagerEvents.Changed, fsm, "Resume")
end

function FsmManager:Pause(fsm)
  self:SendEvent(FsmEnum.ManagerEvents.Changed, fsm, "Pause")
end

function FsmManager:Add(fsm)
  if not fsm then
    return
  end
  table.insert(self.runningFsms, fsm)
end

function FsmManager:Remove(fsm)
  if not fsm then
    return
  end
  for i, f in ipairs(self.runningFsms) do
    if f == fsm then
      table.remove(self.runningFsms, i)
      break
    end
  end
end

function FsmManager:OnTick(DeltaTime)
  if not self.runningFsms then
    return
  end
  if 0 == #self.runningFsms then
    return
  end
  for _, fsm in ipairs(self.runningFsms) do
    if not fsm.paused then
      fsm:OnTick(DeltaTime)
    end
  end
  local Count = #self.runningFsms
  for i = Count, 1, -1 do
    local fsm = self.runningFsms[i]
    if fsm.finished then
      table.remove(self.runningFsms, i)
    end
  end
end

return FsmManager
