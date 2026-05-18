local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_TransformLoading_C = NRCPanelBase:Extend("UMG_TransformLoading_C")

function UMG_TransformLoading_C:OnConstruct()
end

function UMG_TransformLoading_C:OnActive(_param)
  _G.BattleEventCenter:Dispatch(BattleEvent.TransformLoadingOpened)
end

function UMG_TransformLoading_C:OnDeactive()
end

function UMG_TransformLoading_C:OnDestruct()
end

return UMG_TransformLoading_C
