local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local UMG_BattleProcess_Visible_C = _G.NRCPanelBase:Extend("UMG_BattleProcess_Visible_C")
local TimeLineData = Class("TimeLineData")

function UMG_BattleProcess_Visible_C:OnActive()
  self.isOut = false
  self.isUp = false
  self.IsOpenFsmPanel = false
  self.TimeLineHeight = 500
  self.PerformRound = -1
  self.ExpandNumber = 0
  local dpi = UE4.UWidgetLayoutLibrary.GetViewportScale(UE4Helper.GetCurrentWorld())
  self.TimeLineWidth = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld()).X / dpi
  self.TimeLineDatas = {}
  self.UpBtn.OnClicked:Add(self, self.ClickUp)
  self.CloseBtn.OnClicked:Add(self, self.ClickCloseDetail)
  self.FsmBtn.OnClicked:Add(self, self.ClickFsmBtn)
  _G.BattleEventCenter:Bind(self, BattleEvent.START_BATTLE_PERFORM)
  self:SetFsmTextInfo()
  if self.HorizontalContent ~= nil then
    self.HorizontalContent:RemoveFromParent()
    self.HorizontalContent = nil
  end
  if nil ~= self.OutBtn then
    self.OutBtn:RemoveFromParent()
    self.OutBtn = nil
  end
  self:SetPanelRenderOpacity()
end

function UMG_BattleProcess_Visible_C:SetPanelRenderOpacity()
  if _G.IsSetRenderOpacity then
    self:SetRenderOpacity(_G.RenderOpacity)
  end
end

function UMG_BattleProcess_Visible_C:ClickOut()
  if self.performPlayer or self.isOut then
    self.isOut = not self.isOut
    self:StopAnimation(self.out)
    if self.isOut then
      self.OutBtn:SetRenderScale(UE4.FVector2D(-1, 1))
      self:PlayAnimation(self.out)
    else
      self.OutBtn:SetRenderScale(UE4.FVector2D(1, 1))
      self:PlayAnimationReverse(self.out)
    end
  end
end

function UMG_BattleProcess_Visible_C:ClickUp()
  self.isUp = not self.isUp
  self:StopAnimation(self.up)
  if self.isUp then
    self.FsmBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.up)
  else
    self.FsmBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimationReverse(self.up)
  end
  self:UpdateVisibleNodes()
end

function UMG_BattleProcess_Visible_C:PlayUp()
  self.isUp = false
  self:StopAnimation(self.up)
  self:PlayAnimationReverse(self.up)
end

function UMG_BattleProcess_Visible_C:ClickCloseDetail()
  self.DetailContent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TimeLine:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_BattleProcess_Visible_C:ClickFsmBtn()
  self:PlayUp()
  self.FsmBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleFsmUI, true)
end

function UMG_BattleProcess_Visible_C:SetFsmTextInfo()
  self.FsmText:SetText("\230\137\147\229\188\128Fsm")
end

function UMG_BattleProcess_Visible_C:ShowDetailInfo(performNode, detailText)
  self.DetailContent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.TimeLine:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local content = detailText .. "\n"
  content = content .. "ClusterId : " .. performNode.ClusterId .. "\n"
  content = content .. "GroupId : " .. performNode.groupID .. "\n"
  content = content .. "GroupRef : " .. (performNode:GetGroupRef() or "-1") .. "\n"
  content = content .. "NodeIdx : " .. performNode.performNodeIdx .. "\n"
  content = content .. "NodeType : " .. performNode:GetPerformTypeTostring() .. "\n"
  content = content .. "CastMoment : " .. performNode:GetCastMomentToString() .. "\n"
  content = content .. "IsHead : " .. (performNode:IsGroupHead() and "True" or "False") .. "\n"
  if performNode:GetInfo().skill_cast then
    content = content .. "Res : " .. SkillUtils.GetSkillResID(performNode:GetInfo().skill_cast.skill_id) .. "\n"
  elseif performNode:GetInfo().buff_trigger then
    content = content .. "Res : " .. SkillUtils.GetBuffResID(performNode:GetInfo().buff_trigger.buff_id) .. "\n"
  elseif performNode:GetInfo().buff_change then
    Log.Debug("performNode:GetInfo().buff_change.buff_id:", performNode:GetInfo().buff_change.buff_id)
    content = content .. "Res : " .. SkillUtils.GetBuffResID(performNode:GetInfo().buff_change.buff_id) .. "\n"
  end
  content = content .. "Waitting:" .. table.concat(self:GetWaittingNodeLst(performNode), ",") .. "\n"
  content = content .. "Performing:" .. table.concat(self:GetPerformingNodeLst(performNode), ",") .. "\n"
  content = content .. "Performed:" .. table.concat(self:GetPerformedNodeLst(performNode), ",")
  self.DetailText:SetText(content)
end

function UMG_BattleProcess_Visible_C:StartPerform(performPlayer)
  if ServerData.values.battleMode then
    return
  end
  if RocoEnv.IS_SHIPPING then
    return
  end
  self.performPlayer = {}
  table.copy(performPlayer, self.performPlayer)
  self:ExpandNew()
end

function UMG_BattleProcess_Visible_C:ExpandNew()
  if not self.ExpandNumber then
    return
  end
  self.ExpandNumber = self.ExpandNumber + 1
  if _G.BattleManager.curRound ~= self.PerformRound then
    self.PerformRound = _G.BattleManager.curRound
    self.ExpandNumber = 0
  end
  self:UpdateVisibleNodes()
end

function UMG_BattleProcess_Visible_C:AnalysisGroup(performNode, depth)
  for i, v in pairs(self.TimeLineDatas) do
    if performNode == v.PerformNode then
      return
    end
  end
  local lineData = TimeLineData()
  lineData.PerformNode = performNode
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnBeforeAttack, depth, performNode)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnBeforePetDead, depth, performNode)
  lineData.Height = depth
  lineData.TimeLength = 3
  lineData.StartTime = self.TimeLineHorizonNum
  table.insert(self.TimeLineDatas, lineData)
  self.TimeLineHorizonNum = lineData.StartTime + 1
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnInterrupt, depth + 1, performNode)
  self.TimeLineHorizonNum = lineData.StartTime + 1
  local curDepth = 0
  _, curDepth = self:GetLimit(self.TimeLineHorizonNum, depth)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnCounter, curDepth + 1, performNode)
  self.TimeLineHorizonNum, self.TimeLineVerticalNum = self:GetLimit(0, 0)
  self.TimeLineHorizonNum = lineData.StartTime + 1
  curDepth = 0
  _, curDepth = self:GetLimit(self.TimeLineHorizonNum, depth)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnAttackHit, curDepth + 1, performNode)
  self.TimeLineHorizonNum, self.TimeLineVerticalNum = self:GetLimit(0, 0)
  self.TimeLineHorizonNum = lineData.StartTime + 1
  curDepth = 0
  _, curDepth = self:GetLimit(self.TimeLineHorizonNum, depth)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnHit, curDepth + 1, performNode)
  self.TimeLineHorizonNum, self.TimeLineVerticalNum = self:GetLimit(0, 0)
  self.TimeLineHorizonNum = lineData.StartTime + 1
  curDepth = 0
  _, curDepth = self:GetLimit(self.TimeLineHorizonNum, depth)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnAnimationHit, curDepth + 1, performNode)
  self.TimeLineHorizonNum, self.TimeLineVerticalNum = self:GetLimit(0, 0)
  curDepth = 0
  _, curDepth = self:GetLimit(self.TimeLineHorizonNum, depth)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnCounterEnd, curDepth + 1, performNode)
  self.TimeLineHorizonNum, self.TimeLineVerticalNum = self:GetLimit(0, 0)
  self:GetNodeByCast(performNode.groupID, ProtoEnum.Buffbasetrigger_type.OnAfterAttack, depth, performNode)
end

function UMG_BattleProcess_Visible_C:GetLimit(startH, startV)
  local limitH = 0
  local limitV = 0
  for _, v in pairs(self.TimeLineDatas) do
    if startV <= v.Height and startH <= v.StartTime + v.TimeLength then
      limitH = math.max(limitH, v.StartTime + v.TimeLength)
      limitV = math.max(limitV, v.Height)
    end
  end
  return limitH, limitV
end

function UMG_BattleProcess_Visible_C:GetNodeByCast(groupID, castMoment, depth, performNode)
  Log.Debug("UMG_BattleProcess_Visible_C:GetNodeByCast:", castMoment)
  local triggerNodes = {}
  local otherNodes = {}
  local groupLst = self.currentGroupList
  for groupIdx = groupID + 1, #groupLst do
    local headNode = groupLst[groupIdx].HeadNode
    if headNode ~= performNode then
      local result = headNode:IsMatchToPerform(groupID, castMoment)
      if result then
        table.insert(triggerNodes, headNode)
      end
    end
  end
  local performNodes = self.currentGroupList[groupID].GroupNodes
  if performNodes and #performNodes > 0 then
    Log.Debug("BattlePerformCastmomentPlayer PerformCallback:", groupID, castMoment, performNodes)
    for i = 1, #performNodes do
      local performNode = performNodes[i]
      if performNode ~= performNode then
        local result = performNode:IsMatchToPerform(groupID, castMoment)
        if result then
          if performNode:IsTriggerNode() or performNode:IsLetterNode() then
            if not performNode:IsGroupHead() then
              table.insert(triggerNodes, performNode)
            end
          elseif not performNode:IsGroupHead() then
            table.insert(otherNodes, performNode)
          end
        end
      end
    end
  end
  local curDepth = depth - 1
  for _, v in pairs(otherNodes) do
    curDepth = curDepth + 1
    local lineData = TimeLineData()
    lineData.PerformNode = v
    lineData.StartTime = self.TimeLineHorizonNum
    lineData.TimeLength = 2
    lineData.Height = curDepth
    table.insert(self.TimeLineDatas, lineData)
  end
  if #otherNodes > 0 then
    self.TimeLineHorizonNum = self.TimeLineHorizonNum + 2
  end
  self.TimeLineVerticalNum = math.max(self.TimeLineVerticalNum, curDepth)
  for _, v in pairs(triggerNodes) do
    self:AnalysisGroup(v, depth)
  end
end

function UMG_BattleProcess_Visible_C:Expand(performNode)
  if self.childs then
    for i, v in ipairs(self.childs) do
      v:Clear()
    end
  end
  self.childs = {}
  self.HorizontalContent:ClearChildren()
  if nil == performNode then
    table.insert(self.childs, self:CreateVisItem())
  else
    table.insert(self.childs, self:CreateVisItem(performNode, self:GetParentNode(performNode)))
    table.insert(self.childs, self:CreateVisItem(nil, performNode))
  end
end

function UMG_BattleProcess_Visible_C:CreateVisItem(selfNode, parentNode)
  local item = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), self.horizontalItem)
  local slot = self.HorizontalContent:AddChildToHorizontalBox(item)
  slot:SetSize(UE4.FSlateChildSize(1, UE4.ESlateSizeRule.Fill))
  item:SetNodes(selfNode, parentNode, self)
  return item
end

function UMG_BattleProcess_Visible_C:GetParentNode(node)
  if node:IsGroupHead() then
    if node:GetGroupRef() then
      return self.currentGroupList[node:GetGroupRef()].GroupNodes[1]
    else
      return
    end
  else
    return self.currentGroupList[node:GetGroupID()].GroupNodes[1]
  end
end

function UMG_BattleProcess_Visible_C:OnDeactive()
  self.UpBtn.OnClicked:Remove(self, self.ClickUp)
  self.CloseBtn.OnClicked:Remove(self, self.ClickCloseDetail)
  _G.BattleEventCenter:UnBind(self)
end

function UMG_BattleProcess_Visible_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.START_BATTLE_PERFORM then
    self:StartPerform(...)
  end
end

function UMG_BattleProcess_Visible_C:GetWaittingNodeLst(performNode)
  local t = {}
  for i = 1, #performNode.OwnerGroup.GroupNodes do
    local node = performNode.OwnerGroup.GroupNodes[i]
    if not node:IsPerforming() and not node:IsPerformed() then
      table.insert(t, node:GetNodeIdx())
    end
  end
  return t
end

function UMG_BattleProcess_Visible_C:GetPerformedNodeLst(performNode)
  local t = {}
  for i = 1, #performNode.OwnerGroup.GroupNodes do
    local node = performNode.OwnerGroup.GroupNodes[i]
    if node:IsPerformed() then
      table.insert(t, node:GetNodeIdx())
    end
  end
  return t
end

function UMG_BattleProcess_Visible_C:GetPerformingNodeLst(performNode)
  local t = {}
  for i = 1, #performNode.OwnerGroup.GroupNodes do
    local node = performNode.OwnerGroup.GroupNodes[i]
    if node:IsPerforming() then
      table.insert(t, node:GetNodeIdx())
    end
  end
  return t
end

function UMG_BattleProcess_Visible_C:UpdateVisibleNodes()
  if self.isUp then
    self:ClearNodes()
    self:CreateNodes()
  else
    self:ClearNodes()
  end
end

function UMG_BattleProcess_Visible_C:CreateNodes()
  if self.performPlayer == nil then
    local turnPlayer = _G.BattleManager.turnPlayer
    if turnPlayer then
      self.performPlayer = {}
      table.copy(turnPlayer.performPlayer, self.performPlayer)
    end
  end
  if self.performPlayer == nil then
    Log.Warning("UMG_BattleProcess_Visible_C:CreateNodes \230\156\170\230\137\190\229\136\176 performPlayer")
    return
  end
  self.TimeLineHorizonNum = 0
  self.TimeLineVerticalNum = 0
  self.TimeLineDatas = {}
  self.currentGroupList = self.performPlayer.PerformGroupLst
  self.currentClusterList = self.performPlayer.PerformClusterLst
  for _, cluster in ipairs(self.currentClusterList) do
    local performNode = cluster.HeadGroup.HeadNode
    self:AnalysisGroup(performNode, 1)
  end
  local timeLinePerformNodes = {}
  for k, v in ipairs(self.TimeLineDatas) do
    local i = k
    local currentPerformNode = v
    timeLinePerformNodes[i] = currentPerformNode.PerformNode
  end
  if self.TimeLineHorizonNum > 0 and self.TimeLineVerticalNum > 0 then
    local perH = math.min(self.TimeLineWidth / self.TimeLineHorizonNum, 300)
    local perV = math.min(self.TimeLineHeight / self.TimeLineVerticalNum, perH * 0.35)
    for _, v in pairs(self.TimeLineDatas) do
      local item = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), self.TimelineItem)
      local slot = self.TimeLine:AddChildToCanvas(item)
      slot:SetSize(UE4.FVector2D(perH * v.TimeLength, perV))
      slot:SetPosition(UE4.FVector2D(perH * v.StartTime, perV * (v.Height - 1) * 1.2))
      item:SetUI(v, self)
    end
  end
end

function UMG_BattleProcess_Visible_C:ClearNodes()
  self.TimeLine:ClearChildren()
end

function UMG_BattleProcess_Visible_C:GetCurrentGroupList()
  return self.currentGroupList
end

function UMG_BattleProcess_Visible_C:CurrentClusterList()
  return self.currentClusterList
end

return UMG_BattleProcess_Visible_C
