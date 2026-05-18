local NRCViewBase = require("Core.NRCModule.NRCViewBase")
local Base = NRCViewBase
local NRCBattleView = Base:Extend("NRCBattleView")

function NRCBattleView:Ctor()
  Base.Ctor(self)
  self.dataCenter = BattleDataCenter
  BattleEventCenter:BindUIPreInit(self)
end

function NRCBattleView:PreInit(data)
  self.dataCenter:WriteAsyncUIData(self:GetName(), data)
end

function NRCBattleView:Construct()
  NRCViewBase.Construct(self)
  local data = self.dataCenter:GetAsyncUIData(self:GetName())
  if self.OnConstruct then
    self:OnConstruct(data)
  end
end

function NRCBattleView:OnBattleEvent(event, ...)
  if self.isContruct then
  else
    self:PreInit(self:GetName(), event, ...)
  end
end

return NRCBattleView
