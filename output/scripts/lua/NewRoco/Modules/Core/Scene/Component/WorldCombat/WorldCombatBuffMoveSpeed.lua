local WorldCombatBuffBase = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffBase")
local Base = WorldCombatBuffBase
local WorldCombatBuffMoveSpeed = Base:Extend("WorldCombatBuffMoveSpeed")

function WorldCombatBuffMoveSpeed:Ctor(Parent, Buff, Conf)
  Base.Ctor(self, Parent, Buff, Conf)
end

function WorldCombatBuffMoveSpeed:OnInit()
  Base.OnInit(self)
  self:OnMoveSpeedChange()
end

function WorldCombatBuffMoveSpeed:OnAdd()
  Base.OnAdd(self)
  self:OnMoveSpeedChange()
end

function WorldCombatBuffMoveSpeed:OnMoveSpeedChange()
  if self.Parent.owner and self.Config.params and #self.Config.params > 0 then
    local SpeedRate = (100 + self.Config.params[1]) / 100
    if SpeedRate >= 0 then
      self.Parent.owner:ModifyMoveSpeedByBuff(SpeedRate)
    end
  end
end

function WorldCombatBuffMoveSpeed:OnRemove(Reason)
  Base.OnRemove(self, Reason)
  if self.Parent.owner then
    self.Parent.owner:ModifyMoveSpeedByBuff(1)
  end
end

return WorldCombatBuffMoveSpeed
