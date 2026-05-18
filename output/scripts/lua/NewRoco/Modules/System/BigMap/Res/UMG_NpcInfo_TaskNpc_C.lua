local UMG_NpcInfo_TaskNpc_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_TaskNpc_C")

function UMG_NpcInfo_TaskNpc_C:OnActive()
end

function UMG_NpcInfo_TaskNpc_C:OnDeactive()
end

function UMG_NpcInfo_TaskNpc_C:OnAddEventListener()
end

function UMG_NpcInfo_TaskNpc_C:OnConstruct()
end

function UMG_NpcInfo_TaskNpc_C:OnDestruct()
end

function UMG_NpcInfo_TaskNpc_C:OnEnable(props)
  self.npcName_5:SetText(props.name)
  self.TaskDesc:SetText(props.desc)
  self.AwardCanvas:SetVisibility(props.awardCanvasVisibility)
  self.TaskIcon:SetPath(props.taskIconPath)
  if props.shouldShowRewardList then
    self.TaskAwardList:InitGridView(props.rewardsList)
  end
end

function UMG_NpcInfo_TaskNpc_C:OnDisable()
end

return UMG_NpcInfo_TaskNpc_C
