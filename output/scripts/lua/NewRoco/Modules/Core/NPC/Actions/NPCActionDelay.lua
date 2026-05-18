local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionDelay = Base:Extend("NPCActionDelay")

function NPCActionDelay:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.DelayHandler = -1
end

function NPCActionDelay:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  if self.SkipSubmit then
    local FakeRsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
    FakeRsp.ret_info.ret_code = 0
    self:OnSubmit(FakeRsp)
  end
end

function NPCActionDelay:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 == rsp.ret_info.ret_code then
    self:ClearTimer()
    local Time = tonumber(self.Config.action_param1 or "") or 0
    if Time <= 0 then
      self:TimesUp()
    else
      self.DelayHandler = _G.DelayManager:DelaySeconds(Time / 1000, self.TimesUp, self)
    end
  else
    self:Finish(false)
  end
end

function NPCActionDelay:TimesUp()
  self:Finish(true)
end

function NPCActionDelay:ClearTimer()
  if self.DelayHandler > 0 then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = -1
  end
end

function NPCActionDelay:Destroy()
  self:ClearTimer()
  Base.Destroy(self)
end

return NPCActionDelay
