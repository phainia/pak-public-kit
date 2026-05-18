local BattleDebugger_C = _G.NRCPanelBase:Extend("BattleDebugger_C")

function BattleDebugger_C:OnConstruct()
  self:Log("BattleDebugger_C OnConstruct 2")
  self.timeline:InitList({
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
  })
  BattleResourceManager:LoadWidgetAsync(self, "/Game/NewRoco/Modules/System/BattleUI/Res/BattleDebugger/BattleDebuggerTimelineNode.BattleDebuggerTimelineNode", nil, self.SpawnNode)
end

function BattleDebugger_C:SpawnNode(nodeUmg)
  nodeUmg:SetRenderTranslation(UE4.FVector2D(1000, 0))
  self.timelineNodeContainer:AddChildToCanvas(nodeUmg)
end

function BattleDebugger_C:OnDestruct()
end

return BattleDebugger_C
