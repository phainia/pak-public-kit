local UMG_Roster_C = _G.NRCPanelBase:Extend("UMG_Roster_C")

function UMG_Roster_C:OnActive(NPCDataList, npcID)
  self.NPCDataList = NPCDataList
  self.NPCNum = #NPCDataList
  self.CurPageIndex = 1
  self.finalPageIndex = math.floor((self.NPCNum - 1) / 8) + 1
  local RedPointData = _G.NRCModuleManager:DoCmd(RedPointModuleCmd.GetRedPointSplitPointDataByKeyAndReason, 241, Enum.RedPointReason.RPR_MAGE_BOOK)
  local minNPCID = 999
  self:SetCommonPopUpInfo()
  self:SetBtnArrow()
  self.Text_pagination:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if RedPointData then
    for i, data in ipairs(RedPointData) do
      local npcID = tonumber(data[1])
      if minNPCID > npcID then
        local findInNPCDataListFlag = false
        for i, NPCData in ipairs(NPCDataList) do
          if NPCData.id == npcID then
            findInNPCDataListFlag = true
          end
        end
        if findInNPCDataListFlag then
          minNPCID = npcID
        end
      end
    end
  end
  local firstRedPointNPCIndex = 0
  for i, NPCData in ipairs(NPCDataList) do
    if NPCData.id == minNPCID then
      firstRedPointNPCIndex = i
    end
  end
  self:UpdateUI()
  if 0 ~= firstRedPointNPCIndex then
    local firstRedPointPage = math.floor((firstRedPointNPCIndex - 1) / 8) + 1
    if firstRedPointPage > 1 then
      for i = 1, firstRedPointPage do
        self:OnNextPageBtnClick()
      end
    end
  end
  if npcID then
    NRCModuleManager:DoCmd(BagModuleCmd.OpenMagicBook, npcID)
  end
  UE4Helper.SetDesiredShowCursor(true, "UMG_Roster_C")
  self:LoadAnimation(0)
end

function UMG_Roster_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self:OnAddEventListener()
end

function UMG_Roster_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Roster_C")
end

function UMG_Roster_C:OnAddEventListener()
end

function UMG_Roster_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Roster_C:SetBtnArrow()
  local CommonBtnArrowData1 = {}
  CommonBtnArrowData1.Call = self
  CommonBtnArrowData1.btnHandler = self.OnNextPageBtnClick
  CommonBtnArrowData1.modeIndex = 4
  self.Btn1:SetBtnInfo(CommonBtnArrowData1)
  local CommonBtnArrowData2 = {}
  CommonBtnArrowData2.Call = self
  CommonBtnArrowData2.btnHandler = self.OnPrePageBtnClick
  CommonBtnArrowData2.modeIndex = 3
  self.Btn2:SetBtnInfo(CommonBtnArrowData2)
end

function UMG_Roster_C:UpdateUI()
  self.UIData = {}
  for i, NPCData in ipairs(self.NPCDataList) do
    if i > self.CurPageIndex * 8 then
      break
    end
    if i > (self.CurPageIndex - 1) * 8 then
      table.insert(self.UIData, NPCData)
    end
  end
  if 1 == self.CurPageIndex then
    self.Btn2:ShowOrHideBtnArrow(false)
    self.PopUp2:ShowOrHideBtnLeft(false)
  else
    self.Btn2:ShowOrHideBtnArrow(true)
    self.PopUp2:ShowOrHideBtnLeft(true)
  end
  if self.CurPageIndex == self.finalPageIndex then
    self.Btn1:ShowOrHideBtnArrow(false)
    self.PopUp2:ShowOrHideBtnRight(false)
  else
    self.Btn1:ShowOrHideBtnArrow(true)
    self.PopUp2:ShowOrHideBtnRight(true)
  end
  while #self.UIData < 8 do
    local blankData = {}
    table.insert(self.UIData, blankData)
  end
  self.Text_pagination:SetText(self.CurPageIndex .. "/" .. self.finalPageIndex)
  self.list:InitGridView(self.UIData)
end

function UMG_Roster_C:OnPrePageBtnClick()
  if self.CurPageIndex <= 1 then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_Roster_C:OnPrePageBtnClick")
  self.CurPageIndex = self.CurPageIndex - 1
  self.UIDataList = self.NPCDataList[self.CurPageIndex]
  self.list:ClearSelection()
  self:UpdateUI()
end

function UMG_Roster_C:OnNextPageBtnClick()
  if self.CurPageIndex >= self.finalPageIndex then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_Roster_C:OnNextPageBtnClick")
  self.CurPageIndex = self.CurPageIndex + 1
  self.UIData = self.NPCDataList[self.CurPageIndex]
  self.list:ClearSelection()
  self:UpdateUI()
end

function UMG_Roster_C:ClosePanel()
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Roster_C:ClosePanel")
end

function UMG_Roster_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_Roster_C
