local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local JsonUtils = require("Common.JsonUtils")
local UMG_Battle_Fsm_C = _G.NRCPanelBase:Extend("UMG_Battle_Fsm_C")
UMG_Battle_Fsm_C.BattleFsmEnum = {
  BattleFsm = "BattleFsm",
  RoundSelectFsm = "RoundSelectFsm"
}

function UMG_Battle_Fsm_C:OnConstruct()
  self.FsmWidget = {}
  self.FsmStateName = "FsmState"
  self.FsmActionName = "FsmAction"
  self.IsShowLine = false
  self.IsCanMove = false
  self.CheckWidget = {}
  self.DropDownList = {}
  self.IsOnclick = false
  self.SavaPosition = nil
  self.IsOpenPreProcessList = false
  self.IsHideAllAction = false
  self.isTouchScale = false
  self.CurrentStateName = nil
  self.IsShowActivatedLine = false
  self.oldTwoTouchDistance = 0
  self.ActivateState = nil
  self.StateListInfo = nil
  self.CurrentSelectedState = nil
  self.FsmStateListInfo = {}
  self:SetButtonInfo(self.IsShowLine)
  self:SetShowActivatedLine()
  self:SetCanClickBtnState(self.IsCanMove)
  self.imageScale = UE4.FVector2D(1.0, 1.0)
  local imageWidth = 10000
  local imageHeight = 10000
  local imageToSceneScale = 1
  self.uiData = {
    mapSliderScale = 0.5,
    mapImageScale = 1.0,
    originalMapWidth = imageWidth,
    originalMapHeight = imageHeight,
    imageToSceneScale = imageToSceneScale
  }
  self:SetMapCenterPosition(self.uiData.originalMapWidth / 2, self.uiData.originalMapHeight / 2)
  self.mapScaleSlider:SetValue(self.uiData.mapSliderScale)
  self:PrepFsmManager()
end

function UMG_Battle_Fsm_C:OnActive(ActivateState, StateListInfo)
  self:CreateFsmWidgetInfo()
  self:CreateFsmLinState()
  self:ActivateStateChangeUpdate(ActivateState)
  self:FsmStateListInfoChangeUpdate(StateListInfo)
  self:SetMapScale(self:GetMapImageScale(self.uiData.mapSliderScale), true)
  self.UMG_FsmDropDownList:OnActive(self.DropDownList)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Battle_Fsm_C:OnAddEventListener()
  self.SearChBtn.OnClicked:Add(self, self.OnClickSearChBtn)
  self.SavaDataBtn.OnClicked:Add(self, self.OnSavaDataBtn)
  self.CreateCableBtn.OnClicked:Add(self, self.OnCreateCableBtn)
  self.CanClick.OnClicked:Add(self, self.OnCanClick)
  self.PreProcessBtn.OnClicked:Add(self, self.OnPreProcessBtn)
  self.ActionStateBtn.OnClicked:Add(self, self.OnActionStateBtn)
  self.ShowActivatedLine.OnClicked:Add(self, self.ShowAndHideActivatedLine)
  self.CloseBtn.OnClicked:Add(self, self.OnClose)
  self:AddButtonListener(self.btnScaleMin, self.OnBtnScaleMinClick)
  self:AddButtonListener(self.btnScaleMax, self.OnBtnScaleMaxClick)
  self:AddDelegateListener(self.mapScaleSlider.OnValueChanged, self.OnMapScaleValueChanged)
end

function UMG_Battle_Fsm_C:ShowAndHideActivatedLine()
  self.IsShowActivatedLine = not self.IsShowActivatedLine
  self:SetShowActivatedLine()
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      for _, LineWidgetInfo in ipairs(FsmStateWidget.LineWidget) do
        if self.IsShowActivatedLine then
          local IsActivated = LineWidgetInfo:GetIsActivated()
          if IsActivated then
            LineWidgetInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          else
            LineWidgetInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        else
          LineWidgetInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
  self:SetFsmWidgetAndFsmLineWidget()
end

function UMG_Battle_Fsm_C:SetShowActivatedLine()
  if self.IsShowActivatedLine then
    self.NRCText_2:SetText("\233\154\144\232\151\143\230\191\128\230\180\187\231\186\191")
  else
    self.NRCText_2:SetText("\230\152\190\231\164\186\230\191\128\230\180\187\231\186\191")
  end
end

function UMG_Battle_Fsm_C:SetPositionInfo(_SavaPosition)
  self.SavaPosition = _SavaPosition
end

function UMG_Battle_Fsm_C:GetSavaPosition()
  return self.SavaPosition
end

function UMG_Battle_Fsm_C:OnTouchStarted(MyGeometry, InTouchEvent)
  local screenPostion = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  self.localPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, screenPostion)
  self.CanvasPanelTransLation = self.CanvasPanel_41.Slot:GetPosition()
  self.IsOnclick = true
  self.isTouchScale = false
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_C:OnTouchMoved(MyGeometry, InTouchEvent)
  local isTwoTouch, touchDistance = self:GetTouchScaleInfo()
  if isTwoTouch then
    if self.isTouchScale then
      local distance = touchDistance - self.oldTwoTouchDistance
      self:ChangeMapScaleSliderValue(0.005 * distance)
    else
      self.isTouchScale = true
    end
    self.oldTwoTouchDistance = touchDistance
  elseif self.IsOnclick and self.IsCanMove then
    local uiData = self.uiData
    local deltaX, deltaY = FPointerEvent_GetCursorDelta(InTouchEvent)
    self:SetMapCenterPosition(uiData.mapCenterX - deltaX, uiData.mapCenterY - deltaY)
    self.isTouchScale = false
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if self.IsCanMove then
    self.IsOnclick = false
  end
  self.isTouchScale = false
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_C:OnMouseWheel(MyGeometry, InTouchEvent)
  local wheelData = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(InTouchEvent)
  if wheelData > 0 then
    self:ChangeMapScaleSliderValue(0.1)
  elseif wheelData < 0 then
    self:ChangeMapScaleSliderValue(-0.1)
  end
end

function UMG_Battle_Fsm_C:GetDeltaX()
  return self.deltaY
end

function UMG_Battle_Fsm_C:GetDeltaY()
  return self.deltaY
end

function UMG_Battle_Fsm_C:PrepFsmManager()
  self.FsmManager = _G.FsmManager
  self:OnAddEventListener()
end

function UMG_Battle_Fsm_C:RegisterFsmEvent(_IsFirst)
  local RunningFsms = self.FsmManager.runningFsms
  for i = 1, #RunningFsms do
    if RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm or RunningFsms[i]:GetName() == self.BattleFsmEnum.RoundSelectFsm then
      if _IsFirst and RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm then
        self.CurrentStateName = RunningFsms[i].activeState:GetName()
      end
      RunningFsms[i]:RegisterEvent(FsmEnum.Events.EnterState, self, self.OnEnterState)
      RunningFsms[i]:RegisterEvent(FsmEnum.Events.EnterAction, self, self.OnEnterAction)
    end
  end
end

function UMG_Battle_Fsm_C:CleanFsmManager()
  if self.FsmManager then
    self.FsmManager:RemoveEventListener(self, FsmEnum.ManagerEvents.Changed, self.UpdateList)
    local RunningFsms = self.FsmManager.runningFsms
    for i = 1, #RunningFsms do
      if RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm or RunningFsms[i]:GetName() == self.BattleFsmEnum.RoundSelectFsm then
        RunningFsms[i]:RemoveEvent(FsmEnum.Events.EnterState, self, self.OnEnterState)
        RunningFsms[i]:RemoveEvent(FsmEnum.Events.EnterAction, self, self.OnEnterAction)
      end
    end
    self.FsmManager = nil
  end
end

function UMG_Battle_Fsm_C:Destruct()
end

function UMG_Battle_Fsm_C:OnDeactive()
end

function UMG_Battle_Fsm_C:OnCreateCableBtn()
  self.IsShowLine = not self.IsShowLine
  self:SetButtonInfo(self.IsShowLine)
  self:ShowLineWidgetInfo()
  self:SetFsmWidgetAndFsmLineWidget()
end

function UMG_Battle_Fsm_C:UpdateList(Fsm, StateName)
  if "Play" == StateName then
    self:RegisterFsmEvent(false)
  end
end

function UMG_Battle_Fsm_C:OnEnterState(Fsm, State)
  self:SetLineColourByState(State)
  table.insert(self.FsmStateListInfo, {
    State = State,
    Action = {}
  })
  if Fsm:GetName() == self.BattleFsmEnum.BattleFsm then
    self.CurrentStateName = State:GetName()
  end
end

function UMG_Battle_Fsm_C:ActivateStateChangeUpdate(ActivateState)
  self.ActivateState = ActivateState
  self:SetLineColourByState()
end

function UMG_Battle_Fsm_C:SetLineColourByState()
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      if self.ActivateState[j] then
        for k, FsmTransition in pairs(FsmStateWidget.FsmTransition) do
          if self.ActivateState[j][FsmTransition.next].IsActivate then
            FsmStateWidget.LineWidget[k]:SetColour()
            if self.IsShowActivatedLine then
              FsmStateWidget.LineWidget[k]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            end
          end
        end
      end
    end
  end
end

function UMG_Battle_Fsm_C:SetSelectedStateLine()
  local currSelectState = self.CurrentSelectedState
  if currSelectState == nill then
    self:ShowLineWidgetInfo()
    return
  end
  local SavaBattleFsm = self.FsmWidget
  local FsmWidget = SavaBattleFsm.BattleFsm
  for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
    for k, FsmTransition in pairs(FsmStateWidget.FsmTransition) do
      if j == currSelectState then
        FsmStateWidget.LineWidget[k]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      elseif FsmTransition.next == currSelectState then
        FsmStateWidget.LineWidget[k]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        FsmStateWidget.LineWidget[k]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_Battle_Fsm_C:OnEnterAction(Fsm, FsmAction)
  for i, FsmState in ipairs(self.FsmStateListInfo) do
    if FsmState.State == FsmAction.state then
      table.insert(FsmState.Action, FsmAction)
    end
  end
  if #self.FsmStateListInfo > 0 then
    self:ShowStateItemList()
  end
end

function UMG_Battle_Fsm_C:FsmStateListInfoChangeUpdate(FsmStateListInfo)
  self.FsmStateListInfo = FsmStateListInfo
  self:ShowStateItemList()
end

function UMG_Battle_Fsm_C:ShowStateItemList()
  self.StateList:InitList(self.FsmStateListInfo)
  self.StateList:ScrollToEnd()
end

function UMG_Battle_Fsm_C:OnSavaDataBtn()
  local SavaBattleFsm = self.FsmWidget
  local SavaBattleFsmData = {}
  local X, Y
  local count = 0
  for i, FsmWidget in pairs(SavaBattleFsm) do
    X, Y = FsmWidget.Widget:GetPositionInfo()
    count = count + 1
    SavaBattleFsmData[i] = {X = X, Y = Y}
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      X, Y = FsmStateWidget.Widget:GetPositionInfo()
      count = count + 1
      SavaBattleFsmData[i][j] = {X = X, Y = Y}
    end
  end
  JsonUtils.DumpBattleFsmSaved("BattleFsmData", SavaBattleFsmData)
end

function UMG_Battle_Fsm_C:CreateFsmWidgetInfo()
  local BattleFsmData = JsonUtils.LoadSavedFromBattleFsm("BattleFsmData", {})
  local RunningFsms = self.FsmManager.runningFsms
  local SavaBattleFsm = {}
  local PosX = 200
  local PosY = 200
  local DefaultPosX = PosX
  local DefaultPosY = PosY
  for i = 1, #RunningFsms do
    if RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm or RunningFsms[i]:GetName() == self.BattleFsmEnum.RoundSelectFsm then
      local Fsm = RunningFsms[i]
      if BattleFsmData[Fsm:GetName()] then
        PosX = BattleFsmData[Fsm:GetName()].X
        PosY = BattleFsmData[Fsm:GetName()].Y
      end
      local BattleFsmItem = self:CreateFsmWidget(self.BattleFsm, self.BattleItemWidget, PosX, PosY)
      BattleFsmItem:SetData(Fsm, self)
      if Fsm then
        SavaBattleFsm[Fsm:GetName()] = {Widget = BattleFsmItem}
      end
      local States = RunningFsms[i].states
      for j = 1, #States do
        local FsmItem = States[j]
        local IsNewAdd = false
        Log.Debug(FsmItem:GetName(), "UMG_Battle_Fsm_C:CreateFsmWidgetInfo")
        local fsmName = Fsm:GetName()
        local fsmItemName = FsmItem:GetName()
        if BattleFsmData and BattleFsmData[fsmName] and BattleFsmData[fsmName][fsmItemName] then
          PosX = BattleFsmData[fsmName][fsmItemName].X
          PosY = BattleFsmData[fsmName][fsmItemName].Y
        else
          IsNewAdd = true
          PosX = DefaultPosX
          PosY = DefaultPosY
          Log.Debug("BattleFsmData\228\184\173\230\151\160", FsmItem:GetName(), "\231\154\132\228\189\141\231\189\174\228\191\161\230\129\175\239\188\140\232\175\183\230\137\139\229\138\168\231\167\187\229\138\168\232\175\165\231\138\182\230\128\129\231\154\132\228\189\141\231\189\174\229\185\182\228\191\157\229\173\152")
        end
        local UmgFsmStateWidget = self:CreateFsmWidget(self.BattleFsm, self.BattleStateWidget, PosX, PosY)
        UmgFsmStateWidget:SetData(States[j], self)
        if SavaBattleFsm[Fsm:GetName()] and not SavaBattleFsm[Fsm:GetName()][self.FsmStateName] then
          SavaBattleFsm[Fsm:GetName()][self.FsmStateName] = {}
        end
        local FsmStateWidget = SavaBattleFsm[Fsm:GetName()][self.FsmStateName]
        if FsmItem then
          FsmStateWidget[FsmItem:GetName()] = {
            Widget = UmgFsmStateWidget,
            FsmTransition = FsmItem.transitions
          }
          table.insert(self.DropDownList, {
            name = FsmItem:GetName(),
            Widget = UmgFsmStateWidget,
            IsCheck = false,
            num = #States[j].actions,
            Parent = self,
            IsNewAdd = IsNewAdd
          })
        else
          Log.Error("FsmItem\230\156\137\233\151\174\233\162\152\230\163\128\230\159\165\230\149\176\230\141\174")
        end
      end
    end
  end
  self.FsmWidget = SavaBattleFsm
end

function UMG_Battle_Fsm_C:CreateFsmLinState()
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      if not FsmStateWidget.LineWidget then
        FsmStateWidget.LineWidget = {}
      end
      for k, FsmTransition in pairs(FsmStateWidget.FsmTransition) do
        local StateLineWidget = self:CreateLineWidget(self.BattleLine, self.BattleLineWidget)
        table.insert(FsmStateWidget.LineWidget, StateLineWidget)
      end
    end
  end
end

function UMG_Battle_Fsm_C:ShowLineWidgetInfo()
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      local IsCheckWidget = self:IsConnectAll() or self.CheckWidget[j]
      local IsShowActionWidget
      if IsCheckWidget then
        IsShowActionWidget = true
      else
        IsShowActionWidget = false
      end
      for _, LineWidgetInfo in ipairs(FsmStateWidget.LineWidget) do
        LineWidgetInfo:IsShowCable(self.IsShowLine and IsCheckWidget)
      end
    end
  end
end

function UMG_Battle_Fsm_C:IsConnectAll()
  for i, Wideget in pairs(self.CheckWidget) do
    if Wideget then
      return false
    end
  end
  return true
end

function UMG_Battle_Fsm_C:IsShowAll()
  local DropDownList = self.DropDownList
  for i, DropDown in ipairs(DropDownList) do
    if DropDown.IsCheck then
      return false
    end
  end
  return true
end

function UMG_Battle_Fsm_C:SetFsmWidgetAndFsmLineWidget()
  local SavaBattleFsm = self.FsmWidget
  local distance, angle, X
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      for k, FsmTransition in ipairs(FsmStateWidget.FsmTransition) do
        distance, angle, X = self:GetShorTestLengthAndAngleByCoords(FsmStateWidget.Widget:GetSizeInfo(), FsmStateWidget.Widget:GetActionSizeInfo(), FsmWidget.FsmState[FsmTransition.next].Widget:GetSizeInfo(), FsmWidget.FsmState[FsmTransition.next].Widget:GetActionSizeInfo())
        self:SetLineWidgetData(FsmStateWidget.LineWidget[k], X, distance, angle)
      end
    end
  end
end

function UMG_Battle_Fsm_C:GetLengthAndAngleByCoords(Vector_1, Vector_2, LengthAndAngle)
  local dx = Vector_2.X - Vector_1.X
  local dy = Vector_2.Y - Vector_1.Y
  local distance = math.sqrt(dx * dx + dy * dy)
  local angle = math.atan(dy, dx) * 180 / math.pi
  table.insert(LengthAndAngle, {
    distance = distance,
    angle = angle,
    X = Vector_1
  })
  return LengthAndAngle
end

function UMG_Battle_Fsm_C:GetShorTestLengthAndAngleByCoords(Vector_1, Vector_2, Vector_3, Vector_4)
  local LengthAndAngle = {}
  LengthAndAngle = self:GetLengthAndAngleByCoords(Vector_1, Vector_3, LengthAndAngle)
  LengthAndAngle = self:GetLengthAndAngleByCoords(Vector_1, Vector_4, LengthAndAngle)
  LengthAndAngle = self:GetLengthAndAngleByCoords(Vector_2, Vector_3, LengthAndAngle)
  LengthAndAngle = self:GetLengthAndAngleByCoords(Vector_2, Vector_4, LengthAndAngle)
  table.sort(LengthAndAngle, function(a, b)
    return a.distance < b.distance
  end)
  return LengthAndAngle[1].distance, LengthAndAngle[1].angle, LengthAndAngle[1].X
end

function UMG_Battle_Fsm_C:CreateLineWidget(_CanvasPanel, CreateWidget)
  local Widget = UE4.UWidgetBlueprintLibrary.Create(self, CreateWidget)
  if Widget then
    local iconSlot = _CanvasPanel:AddChild(Widget)
    iconSlot:SetAutoSize(true)
    return Widget
  end
end

function UMG_Battle_Fsm_C:CreateStateItemWidget(_CanvasPanel, CreateWidget)
  local Widget = UE4.UWidgetBlueprintLibrary.Create(self, CreateWidget)
  if Widget then
    local iconSlot = _CanvasPanel:AddChild(Widget)
    return Widget
  end
end

function UMG_Battle_Fsm_C:CreateFsmWidget(_CanvasPanel, CreateWidget, _posX, _posY)
  local Widget = UE4.UWidgetBlueprintLibrary.Create(self, CreateWidget)
  if Widget then
    local iconSlot = _CanvasPanel:AddChild(Widget)
    iconSlot:SetPosition(UE4.FVector2D(_posX, _posY))
    iconSlot:SetAutoSize(true)
    return Widget
  end
end

function UMG_Battle_Fsm_C:SetLineWidgetData(LineWidget, Pos, distance, angle)
  if LineWidget then
    LineWidget:SetSize(distance)
    LineWidget:SetRenderTransformPivot(UE4.FVector2D(0, 0.5))
    LineWidget:SetRenderTransformAngle(angle)
    local AbsoluteSize = LineWidget:GetAbsoluteSize()
    LineWidget.Slot:SetPosition(UE4.FVector2D(Pos.X, Pos.Y))
  end
end

function UMG_Battle_Fsm_C:SetButtonInfo(IsShowLine)
  if IsShowLine then
    self.NRCText:SetText("\229\133\179\233\151\173\232\191\158\230\142\165\231\186\191")
  else
    self.NRCText:SetText("\230\152\190\231\164\186\232\191\158\230\142\165\231\186\191")
  end
end

function UMG_Battle_Fsm_C:SetCanClickBtnState(IsCanMove)
  if IsCanMove then
    self.CanvasPanel_41:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_1:SetText("\228\184\141\229\143\175\230\139\150\230\139\189")
  else
    self.CanvasPanel_41:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_1:SetText("\229\143\175\230\139\150\230\139\189")
  end
end

function UMG_Battle_Fsm_C:OnClickSearChBtn()
  self:SearChInfo()
end

function UMG_Battle_Fsm_C:SearChInfo()
  local DropDownList = self.DropDownList
  local IsShowAll = self:IsShowAll()
  for i, DropDown in ipairs(DropDownList) do
    if DropDown.IsCheck or IsShowAll then
      DropDown.Widget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.CheckWidget[DropDown.name] = true
    else
      DropDown.Widget:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CheckWidget[DropDown.name] = false
    end
  end
end

function UMG_Battle_Fsm_C:SetWidgetByName()
  local SavaBattleFsm = self.FsmWidget
  local CheckWidgetName = self.CheckWidget
  local IsFind = false
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      if CheckWidgetName[j] then
        IsFind = true
      else
        IsFind = false
      end
      for k, FsmActionWidget in pairs(FsmStateWidget.FsmAction) do
        if IsFind then
          FsmActionWidget.Widget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          FsmActionWidget.Widget:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
end

function UMG_Battle_Fsm_C:OnCanClick()
  self.IsCanMove = not self.IsCanMove
  self:SetCanClickBtnState(self.IsCanMove)
end

function UMG_Battle_Fsm_C:OnPreProcessBtn()
  self.IsOpenPreProcessList = not self.IsOpenPreProcessList
  if self.IsOpenPreProcessList then
    self.PreProcessCmdList:SetVisibility(UE4.ESlateVisibility.Visible)
    self:UpdatePreProcessList()
    self:UpdatePreProcessList_BattleNotify()
  else
    self.PreProcessCmdList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Fsm_C:OnActionStateBtn()
  self.IsHideAllAction = not self.IsHideAllAction
  if self.IsHideAllAction then
    self.ActionStateText:SetText("\230\152\190\231\164\186Action")
  else
    self.ActionStateText:SetText("\233\154\144\232\151\143Action")
  end
  self:IsHideFsmAction(self.IsHideAllAction)
end

function UMG_Battle_Fsm_C:IsHideFsmAction(_IsHide)
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      FsmStateWidget.Widget:IsHideActionList(_IsHide)
    end
  end
end

function UMG_Battle_Fsm_C:UpdatePreProcessList()
end

function UMG_Battle_Fsm_C:UpdatePreProcessList_BattleNotify()
  if self.PreProcessCmdList:GetVisibility() == UE4.ESlateVisibility.Visible then
    local PreProcessList = NRCModeManager:DoCmd(BattleUIModuleCmd.GetBattleNotify)
    self.PreProcessCmdList:InitList(PreProcessList)
    self.PreProcessCmdList:ScrollToEnd()
  end
end

function UMG_Battle_Fsm_C:SetChildPosition(Name)
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      if j == Name then
        local X, Y = FsmStateWidget.Widget:GetPositionInfo()
        self:SetMapCenterPosition(X, Y)
        break
      end
    end
  end
end

function UMG_Battle_Fsm_C:OnBtnScaleMinClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_MainMap_C:OnBtnScaleMinClick")
  self:ChangeMapScaleSliderValue(-0.1)
end

function UMG_Battle_Fsm_C:OnBtnScaleMaxClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_MainMap_C:OnBtnScaleMaxClick")
  self:ChangeMapScaleSliderValue(0.1)
end

function UMG_Battle_Fsm_C:ChangeMapScaleSliderValue(_delta)
  local value = self.mapScaleSlider:GetValue() + _delta
  if value > 1 then
    value = 1
  elseif value < 0 then
    value = 0
  end
  if not UE4.UKismetMathLibrary.NearlyEqual_FloatFloat(value, self.mapScaleSlider:GetValue()) then
    self.mapScaleSlider:SetValue(value)
    self:OnMapScaleValueChanged(value)
  end
end

function UMG_Battle_Fsm_C:SetMapCenterPosition(_posX, _posY)
  local uiData = self.uiData
  local imagePosX = _posX or 0
  local imagePosY = _posY or 0
  local imageSizeX = uiData.originalMapWidth * self.imageScale.X
  local imageSizeY = uiData.originalMapHeight * self.imageScale.Y
  local wndSize = UE4.USlateBlueprintLibrary.GetLocalSize(self.CanvasPanel_41:GetCachedGeometry())
  if imageSizeX <= wndSize.X then
    imagePosX = uiData.originalMapWidth / 2
  else
    local minValue = 0
    local maxValue = imageSizeX - minValue
    minValue = minValue / self.imageScale.X
    maxValue = maxValue / self.imageScale.X
    if imagePosX < minValue then
      imagePosX = minValue
    elseif maxValue < imagePosX then
      imagePosX = maxValue
    end
  end
  if imageSizeY <= wndSize.Y then
    imagePosY = uiData.originalMapHeight / 2
  else
    local minValue = wndSize.Y / 2
    local maxValue = imageSizeY - minValue
    minValue = minValue / self.imageScale.Y
    maxValue = maxValue / self.imageScale.Y
    if imagePosY < minValue then
      imagePosY = minValue
    elseif maxValue < imagePosY then
      imagePosY = maxValue
    end
  end
  if UE4.UKismetMathLibrary.NearlyEqual_FloatFloat(uiData.mapCenterX, imagePosX) and UE4.UKismetMathLibrary.NearlyEqual_FloatFloat(uiData.mapCenterY, imagePosY) then
    return
  end
  uiData.mapCenterX = imagePosX
  uiData.mapCenterY = imagePosY
  local x = uiData.mapCenterX / uiData.originalMapWidth
  local y = uiData.mapCenterY / uiData.originalMapHeight
  Log.Debug(imagePosX, imagePosY, imageSizeX, imageSizeY, wndSize, self.imageScale, -uiData.mapCenterX, -uiData.mapCenterY, "UMG_MainMap_C:SetMapCenterPosition_4")
  self.FsmMap:SetRenderTranslation(UE4.FVector2D(-uiData.mapCenterX, -uiData.mapCenterY))
  self.FsmMap:SetRenderTransformPivot(UE4.FVector2D(x, y))
end

function UMG_Battle_Fsm_C:GetMapImageScale(_sliderScale)
  local minScale = 0.2
  local maxScale = 1
  return minScale + (maxScale - minScale) * _sliderScale
end

function UMG_Battle_Fsm_C:SetMapScale(_scale, _force)
  if not _scale then
    return
  end
  local uiData = self.uiData
  local isLessen = _scale < uiData.mapImageScale
  if _scale ~= uiData.mapImageScale or _force then
    uiData.mapImageScale = _scale
    self.imageScale.X = _scale
    self.imageScale.Y = _scale
    self.FsmMap:SetRenderScale(self.imageScale)
    if isLessen then
      self:SetMapCenterPosition(uiData.mapCenterX, uiData.mapCenterY)
    end
  end
end

function UMG_Battle_Fsm_C:UpdateIconScale()
  local scale = 1.0 / self.uiData.mapImageScale
  local scaleParam = UE4.FVector2D(scale, scale)
end

function UMG_Battle_Fsm_C:UpdateFsmWidgetScale(scaleParam)
  if not scaleParam then
    return
  end
  local SavaBattleFsm = self.FsmWidget
  for i, FsmWidget in pairs(SavaBattleFsm) do
    FsmWidget.Widget:SetRenderScale(scaleParam)
    for j, FsmStateWidget in pairs(FsmWidget.FsmState) do
      FsmStateWidget.Widget:SetRenderScale(scaleParam)
      if FsmStateWidget.LineWidget then
        FsmStateWidget.LineWidget:SetRenderScale(scaleParam)
      end
      for k, FsmActionWidget in pairs(FsmStateWidget.FsmAction) do
        FsmActionWidget.Widget:SetRenderScale(scaleParam)
        if FsmActionWidget.LineWidget then
          FsmStateWidget.LineWidget:SetRenderScale(scaleParam)
        end
      end
    end
  end
end

function UMG_Battle_Fsm_C:OnMapScaleValueChanged(_value)
  if self.uiData.mapSliderScale == _value then
    return
  end
  self.uiData.mapSliderScale = _value
  self:SetMapScale(self:GetMapImageScale(_value))
end

function UMG_Battle_Fsm_C:OnClose()
  self:DoClose()
end

return UMG_Battle_Fsm_C
