local BattleComponent = NRCClass()
BattleComponent.log = false

function BattleComponent:Ctor()
  self.enable = true
  self.object = nil
end

function BattleComponent:SetEnable(flag)
  if self.enable == flag then
    return
  end
  self.enable = flag
  if self.enable then
    self:Enable()
  else
    self:Disable()
  end
end

function BattleComponent:Start()
end

function BattleComponent:Enable()
  self:Log("\229\144\175\231\148\168\231\187\132\228\187\182\239\188\154" .. self.name)
end

function BattleComponent:Disable()
  self:Log("\231\166\129\231\148\168\231\187\132\228\187\182\239\188\154" .. self.name)
end

function BattleComponent:Destroy()
end

function BattleComponent:OnTick(deltaTime)
end

function BattleComponent:InitByCard(Card)
end

function BattleComponent:UpdateByCard(Card)
end

function BattleComponent:Log(...)
  if self.log then
    Log.Debug(...)
  end
end

function BattleComponent:Warning(...)
  if self.log then
    Log.Warning(...)
  end
end

return BattleComponent
