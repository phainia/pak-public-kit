local RequesterInterface = require("NewRoco.AI.Requester.RequesterInterface")
local RequesterQueued = require("NewRoco.AI.Requester.RequesterQueued")
local RequesterDefault = require("NewRoco.AI.Requester.RequesterDefault")
local Requester_test = Class("Requester_test")

function Requester_test:Main()
  self:Unit1()
  self:Unit2()
  self:Unit3()
end

function Requester_test:Unit1()
  local req = RequesterInterface()
  req:Request(nil, self, self.AssertCallback_Success)
end

function Requester_test:Unit2()
  local clazz = RequesterQueued:Extend("DelayAct2")
  
  function clazz:Ctor()
    RequesterDefault.Ctor(self)
    self.delayId = 0
  end
  
  function clazz:Action(param)
    Log.Warning("[DelayAct2] BeginAction!", param)
    self.delayId = DelayManager:DelaySeconds(1, self.ActEnd, self, AIDefines.ActionResult.Success)
  end
  
  function clazz:Interrupt()
    Log.Error("DelayAct2 Interrupted!")
    DelayManager:CancelDelayById(self.delayId)
  end
  
  local req = clazz()
  req:Request(0, self, self.AssertCallback_Continue)
  DelayManager:DelaySeconds(0.5, function(self, req)
    req:Request(2, self, self.AssertCallback_Continue)
  end, self, req)
  DelayManager:DelaySeconds(0.75, function(self, req)
    req:Request(3, self, self.AssertCallback_Continue)
  end, self, req)
  DelayManager:DelaySeconds(1.5, function(self, req)
    req:Request(4, self, self.AssertCallback_Success)
  end, self, req)
  DelayManager:DelaySeconds(4, function()
    Log.Warning("[DelayAct2] Finished!")
  end)
end

function Requester_test:Unit3()
  local clazz = RequesterDefault:Extend("DelayAct3")
  
  function clazz:Ctor()
    RequesterDefault.Ctor(self)
    self.delayId = 0
  end
  
  function clazz:Action(param)
    self.delayId = DelayManager:DelaySeconds(2, self.ActEnd, self, AIDefines.ActionResult.Success)
    Log.Warning("[DelayAct3] start " .. tostring(self.delayId), param)
  end
  
  function clazz:Interrupt()
    Log.Warning("[DelayAct3] abort" .. tostring(self.delayId))
    DelayManager:CancelDelayById(self.delayId)
  end
  
  local req = clazz()
  req:Request(1, self, self.AssertCallback_Abort)
  req:Request(2, self, self.AssertCallback_Abort)
  req:Request(3, self, self.AssertCallback_Abort)
  local tmpDelayer = NRCClass()
  
  function tmpDelayer:Ctor()
    self.count = 0
  end
  
  function tmpDelayer:OnTick(dt)
    self.count = self.count + dt
    if self.count > 1 then
      UpdateManager:UnRegister(self)
      req:Request(4, self.caller, self.callback)
    end
  end
  
  function tmpDelayer:Register(caller, callback)
    self.caller = caller
    self.callback = callback
  end
  
  local delayer = tmpDelayer()
  delayer:Register(self, self.AssertCallback_Success)
  UpdateManager:Register(delayer)
  DelayManager:DelaySeconds(2, function()
    Log.Warning("[DelayAct3] Finished!")
  end)
end

function Requester_test:AssertCallback_Success(result, req, pm)
  if result == AIDefines.ActionResult.Success then
  else
    Log.Error("AssertCallback_Success failed", pm)
  end
end

function Requester_test:AssertCallback_Abort(result, req, pm)
  if result == AIDefines.ActionResult.Aborted then
  else
    Log.Error("AssertCallback_Abort failed", pm)
  end
end

function Requester_test:AssertCallback_Continue(result, req)
  if result == AIDefines.ActionResult.Continue then
  else
    Log.Error("AssertCallback_Continue failed")
  end
end

return Requester_test
