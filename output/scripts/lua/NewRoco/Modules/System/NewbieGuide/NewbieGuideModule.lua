local NewbieGuideModule = _G.NRCModuleBase:Extend("NewbieGuideModule")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local NewbieGuideCfg = require("NewRoco.Modules.System.NewbieGuide.Res.NewbieGuideCfg")
local GuideState = {
  Normal = 0,
  DoStep = 1,
  WaitStep = 2,
  BackStep = 3
}

function NewbieGuideModule:OnConstruct()
  self.CurId = nil
  self.CurStepId = 0
  self.FinishMap = {}
  self.CurState = GuideState.Normal
  self:AddEventListener()
  _G.NewbieGuideModuleCmd = require("NewRoco.Modules.System.NewbieGuide.NewbieGuideModuleCmd")
  self:RegisterCmd(NewbieGuideModuleCmd.EnterGuide, self.EnterGuide)
  self:RegisterCmd(NewbieGuideModuleCmd.BtnClick, self.BtnClick)
  self:RegisterCmd(NewbieGuideModuleCmd.GuideFinishById, self.GuideFinishById)
end

function NewbieGuideModule:OnDestruct()
  self:RemoveEventListener()
  self.cachedUIEnumShow = {}
  self.UICmdDic = nil
end

function NewbieGuideModule:OnTick(deltaTime)
  if not self.CurState or self.CurState == GuideState.Normal then
    return
  end
  if self.CurState == GuideState.DoStep then
    self:DoStep(self.CurStepInfo)
  elseif self.CurState == GuideState.WaitStep then
    self:CheckCurStep()
  end
end

function NewbieGuideModule:CheckCurStep()
  local Step = self.CurStepInfo
  if Step.type == "ShowGuideAndWaitBtnClick" then
    local guidePath = Step.path
    local widget = self:GetHighLightWidget(guidePath, true)
    if not widget or not self:CheckWidgetVisible(widget) then
      self.CurState = GuideState.BackStep
      self:TryBackStep()
    end
  end
end

function NewbieGuideModule:TryBackStep()
  self.CurStepId = self.CurStepId - 1
  if 0 == self.CurStepId then
    self:TryNextStep()
  else
    local Step = NewbieGuideCfg[self.CurId].steps[self.CurStepId]
    self.CurStepInfo = Step
    if Step and Step.type == "ShowGuideAndWaitBtnClick" then
      local guidePath = Step.path
      self.btnName = Step.btnName
      local widget = self:GetHighLightWidget(guidePath, true)
      if widget and self:CheckWidgetVisible(widget) then
        self.CurStepId = self.CurStepId - 1
        self:TryNextStep()
      else
        self:TryBackStep()
      end
    end
  end
end

function NewbieGuideModule:EnterGuide(id)
  if self.CurId then
    Log.Warning("\230\173\163\229\156\168\232\191\155\232\161\140\230\150\176\230\137\139\229\188\149\229\175\188 id=", id)
    return
  end
  if NewbieGuideCfg[id] then
    self.CurId = id
    self.CurStepId = 0
    self:TryNextStep()
  end
end

function NewbieGuideModule:GuideFinishById(id)
  if self.CurId == id then
    self:ClearCurStep()
    self:GuideFinish()
  end
end

function NewbieGuideModule:GuideFinish()
  if not self.FinishMap then
    self.FinishMap = {}
  end
  self.FinishMap[self.CurId] = true
  self.CurId = nil
  self.CurState = GuideState.Normal
end

function NewbieGuideModule:BtnClick(id)
  if not self.CurId then
    return
  end
  if id == self.btnName then
    self:TryNextStep()
  end
end

function NewbieGuideModule:ClearCurStep()
  local Step = self.CurStepInfo
  if not Step then
    return
  end
  if Step.type == "ShowGuideAndWaitBtnClick" then
    local guidePath = Step.path
    local widget = self:GetHighLightWidget(guidePath, false)
    if widget then
      local itemTutorialHighLight = widget:GetPanel()
      if itemTutorialHighLight then
        itemTutorialHighLight:Hide()
      end
      widget:UnLoadPanel()
    end
  end
end

function NewbieGuideModule:TryNextStep()
  self:ClearCurStep()
  self.CurStepId = self.CurStepId + 1
  if self.CurStepId > #NewbieGuideCfg[self.CurId].steps then
    self:GuideFinish()
  else
    local Step = NewbieGuideCfg[self.CurId].steps[self.CurStepId]
    if Step then
      self:DoStep(Step)
    else
      self:GuideFinish()
    end
  end
end

function NewbieGuideModule:DoStep(Step)
  self.CurStepInfo = Step
  if Step.type == "ShowGuideAndWaitBtnClick" then
    local guidePath = Step.path
    self.btnName = Step.btnName
    local widget = self:GetHighLightWidget(guidePath, true)
    if widget then
      widget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      widget:LoadPanel()
      self.CurState = GuideState.WaitStep
    else
      self.CurState = GuideState.DoStep
    end
  end
end

function NewbieGuideModule:CheckWidgetVisible(widget)
  if widget:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and widget:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
    return true
  else
    return false
  end
end

function NewbieGuideModule:SplitPath(str)
  local delimiter = "/"
  if not str:find(delimiter, 1, true) then
    return str, nil
  end
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result[1], result[2]
end

function NewbieGuideModule:GetHighLightWidget(guidePath, isCheckVisible)
  if guidePath[1] and guidePath[2] and guidePath[3] then
    local panel = _G.NRCPanelManager:GetPanel(guidePath[1], guidePath[2])
    if panel and self:CheckWidgetVisible(panel) then
      local answer
      local parent = panel
      for i = 3, #guidePath do
        local widgetName, TypeName = self:SplitPath(guidePath[i])
        if parent and parent[widgetName] then
          answer = parent[widgetName]
          if i == #guidePath then
            return answer
          end
          if answer then
            local isVisible = true
            if isCheckVisible then
              isVisible = self:CheckWidgetVisible(answer)
            end
            if isVisible then
              if not TypeName then
                parent = answer
              elseif "ScrollView" == TypeName then
                local itemCount = answer:GetItemCount()
                if itemCount > 0 then
                  parent = answer:GetItemByIndex(0)
                else
                  return nil
                end
              elseif "SpecialLoader" == TypeName then
                parent = answer:GetPanel()
              end
            else
              return nil
            end
          else
            self:GuideFinish()
            return nil
          end
        else
          return nil
        end
      end
      return answer
    else
      Log.Warning("NewbieGuideModule.GetHighLightWidget, panel is nil")
      return nil
    end
  else
    self:GuideFinish()
    Log.Error("NewbieGuideModule.Error please check moduleName and panelName")
  end
  return nil
end

function NewbieGuideModule:OnLeaveBattle()
  if self.CurId then
    self:GuideFinish()
  end
end

function NewbieGuideModule:AddEventListener()
  _G.NRCEventCenter:RegisterEvent("NewbieGuideModule", self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
end

function NewbieGuideModule:RemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
end

return NewbieGuideModule
