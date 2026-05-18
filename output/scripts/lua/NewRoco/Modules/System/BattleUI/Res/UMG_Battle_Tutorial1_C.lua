local UMG_Battle_Tutorial1_C = _G.NRCPanelBase:Extend("UMG_Battle_Tutorial1_C")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleTutorialGuideModuleUtils = require("NewRoco.Modules.System.BattleTutorialGuide.BattleTutorialGuideModuleUtils")

function UMG_Battle_Tutorial1_C:OnActive()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.Close_Information_Recording)
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.CloseAllBattleChatRelatedUI, true)
  NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleChangePetConfirmPanel)
  self:BindInputAction()
  self:OnAddEventListener()
  self:CallOutNameTutorial2()
  if UE4Helper.IsPCMode() then
    local Padding = UE4.FMargin()
    Padding.Left = 25
    Padding.Top = 110
    Padding.Right = 0
    Padding.Bottom = 0
    self.CallNameTutorialPanel2.Slot:SetOffsets(Padding)
  end
end

function UMG_Battle_Tutorial1_C:OnDeactive()
  self.isClickClose = nil
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.BattleScreenClick, self.HandleScreenClick)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.FinalBattleCloseTutorial, self.HandleScreenClick)
  _G.UpdateManager:UnRegister(self)
end

function UMG_Battle_Tutorial1_C:OnAddEventListener()
  self:AddButtonListener(self.CallTutorialBtn2, self.CloseCallOutNameTutorial2)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_Tutorial1_C", self, _G.NRCGlobalEvent.BattleScreenClick, self.HandleScreenClick)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_Tutorial1_C", self, _G.NRCGlobalEvent.FinalBattleCloseTutorial, self.HandleScreenClick)
  _G.UpdateManager:Register(self)
end

function UMG_Battle_Tutorial1_C:OnBattleEvent(eventName, ...)
end

function UMG_Battle_Tutorial1_C:OnTick()
  local ui_path = {
    "BattleUIModule/BattleMain",
    "SkillPanelLoader",
    "SkillItemLoader",
    "BtnSkill"
  }
  local targetWidget = BattleTutorialGuideModuleUtils.GetGuideWidget(ui_path)
  if not BattleTutorialGuideModuleUtils.IsWidgetVisible(targetWidget) then
    self:DoClose()
  end
  if _G.BattleManager and _G.BattleManager.stateFsm and _G.BattleManager.stateFsm:GetActiveStateName() ~= BattleEnum.StateNames.RoundSelect then
    self:DoClose()
  end
end

function UMG_Battle_Tutorial1_C:CallOutNameTutorial1()
  NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBattleUIBackpackTips)
  self.CallNameTutorialPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.Point_R)
  self:LimitInputAction("IA_BattleBagStart", "CallOutNameTutorial2")
end

function UMG_Battle_Tutorial1_C:CallOutNameTutorial2()
  self.CallNameTutorialPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CallNameTutorialPanel2:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.Point_L)
  self:LimitInputAction("IA_BattleSelectItemStart_1", "CloseCallOutNameTutorial2")
end

function UMG_Battle_Tutorial1_C:CloseCallOutNameTutorial2()
  NRCEventCenter:DispatchEvent(BattlePerformEvent.SimulateClickSkill1)
  self:CancelAllLimitInputAction()
  self.isClickClose = true
end

function UMG_Battle_Tutorial1_C:TryClose()
  if self.isClickClose then
    self.CallNameTutorialPanel2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:OnClose()
  end
end

function UMG_Battle_Tutorial1_C:UploadData()
  local List = ProtoMessage:newPointList()
  local point = ProtoMessage:newPoint()
  point.pos.x = 0
  table.insert(List.points, point)
end

function UMG_Battle_Tutorial1_C:DownloadData()
end

function UMG_Battle_Tutorial1_C:HandleScreenClick()
  if self.CallNameTutorialPanel3:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
    self.CallNameTutorialPanel3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:CancelAllLimitInputAction()
end

function UMG_Battle_Tutorial1_C:OnAnimationFinished(anim)
  if anim == self.Point_R then
    self:PlayAnimation(self.Point_R_loop, 0, 9999)
  elseif anim == self.Point_L then
    self:PlayAnimation(self.Point_L_loop, 0, 9999)
  elseif anim == self.Point_Middle then
    self:PlayAnimation(self.Point_M_loop, 0, 9999)
  end
end

function UMG_Battle_Tutorial1_C:OnPCTriggerTutorial()
  local invokeFunc = self.PCInvokeFunctionName
  if not invokeFunc then
    return
  end
  self.PCInvokeFunctionName = nil
  local funInst = self[invokeFunc]
  if funInst then
    funInst(self)
  end
end

function UMG_Battle_Tutorial1_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_BattleTutorial")
  if mappingContext then
    mappingContext:BindAction("IA_BattleTutorial_0", self, "OnPCTriggerTutorial")
  end
end

function UMG_Battle_Tutorial1_C:LimitInputAction(allowAction, triggerFunctionName)
  self.PCInvokeFunctionName = nil
  local mappingContext = self:GetInputMappingContext("IMC_BattleTutorial")
  if mappingContext then
    local bindKey = _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.GetMappingKey, allowAction)
    if bindKey then
      mappingContext:EnableInputMappingContext()
      mappingContext:ChangeKey("IA_BattleTutorial_0", bindKey)
      self.PCInvokeFunctionName = triggerFunctionName
    end
  end
end

function UMG_Battle_Tutorial1_C:CancelAllLimitInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_BattleTutorial")
  if mappingContext then
    mappingContext:DisableInputMappingContext()
  end
end

return UMG_Battle_Tutorial1_C
