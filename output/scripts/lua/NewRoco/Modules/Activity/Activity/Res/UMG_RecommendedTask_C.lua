local UMG_RecommendedTask_C = _G.NRCPanelBase:Extend("UMG_RecommendedTask_C")

function UMG_RecommendedTask_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
end

function UMG_RecommendedTask_C:OnActive(showTaskList, data)
  self.data = data
  self.Desc:SetText(data and data.desc or "")
  self:InitPopUp(data)
  local taskListData = {}
  for _, taskId in ipairs(showTaskList) do
    local itemData = {}
    itemData.taskId = taskId
    itemData.taskStatus = data.taskStatusData and data.taskStatusData[taskId]
    table.insert(taskListData, itemData)
  end
  self.TaskList:InitList(taskListData)
  self:LoadAnimation(0)
end

function UMG_RecommendedTask_C:InitPopUp(data)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = data.title
  CommonPopUpData.Btn_LeftText = data.leftBtnText
  CommonPopUpData.Btn_RightText = data.rightBtnText
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClickCancel
  CommonPopUpData.Btn_RightHandler = self.OnClickOk
  CommonPopUpData.ClosePanelHandler = self.OnClickCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
  if string.IsNilOrEmpty(data.leftBtnText) then
    self.PopUp2:ShowOrHideBtnLeft(false)
  end
  if string.IsNilOrEmpty(data.rightBtnText) then
    self.PopUp2:ShowOrHideBtnRight(false)
  end
end

function UMG_RecommendedTask_C:OnClickCancel()
  self:LoadAnimation(2)
end

function UMG_RecommendedTask_C:OnClickOk()
  local data = self.data
  if data and data.clickOkCallback then
    data.clickOkCallback()
  end
  self:LoadAnimation(2)
end

function UMG_RecommendedTask_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:OnClose()
  end
end

return UMG_RecommendedTask_C
