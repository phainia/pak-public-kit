local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_MiniGame_Task_C = _G.NRCPanelBase:Extend("UMG_MiniGame_Task_C")

function UMG_MiniGame_Task_C:Construct()
  NRCPanelBase.Construct(self)
  self.Exit.OnReleased:Add(self, self.OpenExitPanel)
  self.TaskWidgetMap = {}
  self.PreNPCID = nil
  self.StarWidget = nil
  self.TextWidget = nil
  self:OnAddEventListener()
end

function UMG_MiniGame_Task_C:Destruct()
  self.Module = NRCModuleManager:GetModule("MiniGameModule")
  if not self.Module then
    return
  end
  self.Module:UnRegisterEvent(self, MiniGameModuleEvent.Progression)
end

function UMG_MiniGame_Task_C:OnActive()
  self.Module = NRCModuleManager:GetModule("MiniGameModule")
  if not self.Module then
    return
  end
  self:PCKeySetting()
  self.Module:RegisterEvent(self, MiniGameModuleEvent.Progression, self.Progress)
end

function UMG_MiniGame_Task_C:OnDeactive()
  self.Module:UnRegisterEvent(self, MiniGameModuleEvent.Progression)
end

function UMG_MiniGame_Task_C:OnStartMiniGame()
  self:OnActive()
end

function UMG_MiniGame_Task_C:PCKeySetting()
  if SystemSettingModuleCmd then
    self.PCKey:SetKeyVisibility(true)
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_ExitDungeon")
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
  end
end

function UMG_MiniGame_Task_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_MiniGame_Task_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_MiniGame_Task_C:OpenExitPanel()
  if self.Module then
    self.Module:OpenExitPanel()
  else
    Log.Warning("MiniGameModule not found")
  end
end

function UMG_MiniGame_Task_C:Progress(MiniGameProgress)
  local MiniGameConfig = DataConfigManager:GetMinigameConf(MiniGameProgress.minigame_cfg_id, true)
  local RuleConfer
  local GuideTips = LuaText.umg_minigame_task_1
  local GuideText
  if MiniGameConfig then
    GuideText = MiniGameConfig.guide_text
    RuleConfer = DataConfigManager:GetMinigameRuleConf(MiniGameConfig.rule, true)
    if MiniGameConfig.opening_camera > 0 then
      local MiniGameCameraConf = DataConfigManager:GetCameraMoveLite(MiniGameConfig.opening_camera)
      GuideTips = MiniGameCameraConf and MiniGameCameraConf.guide_tips or GuideTips
    end
  end
  local MaxDict = {}
  if RuleConfer then
    for i, ref in pairs(RuleConfer.contents) do
      MaxDict[ref.npc_cfg_id] = ref.timer_goal
    end
  end
  for i, Progress in pairs(MiniGameProgress.progress) do
    local Widget = self:GetItemWithID(Progress.npc_cfg_id, GuideText)
    Widget:SetData(Progress, MaxDict[Progress.npc_cfg_id], GuideText)
    if MiniGameProgress.status == ProtoEnum.MinigameStatus.MS_PROGRESS then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1337, "UMG_MiniGame_Task_C:Progress")
    end
  end
end

function UMG_MiniGame_Task_C:GetItemWithID(ID, GuideText)
  local bNeedCreate = false
  local Widget
  if GuideText then
    if self.TextWidget then
      Widget = self.TextWidget
      self.TextWidget:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if self.StarWidget then
      self.StarWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    if self.StarWidget then
      Widget = self.StarWidget
      self.StarWidget:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if self.TextWidget then
      self.TextWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.PreNPCID ~= ID and nil == Widget then
    bNeedCreate = true
  end
  if bNeedCreate then
    local Klass
    if GuideText then
      Klass = self.TaskItemText
    else
      Klass = self.TaskItem
    end
    if not Klass then
      Log.Error("Class not found")
      return nil
    end
    Widget = UE4.UWidgetBlueprintLibrary.Create(self, Klass)
    self.TaskList1:AddChild(Widget)
    if GuideText then
      self.TextWidget = Widget
    else
      self.StarWidget = Widget
    end
  end
  self.PreNPCID = ID
  return Widget
end

function UMG_MiniGame_Task_C:OnConstruct()
end

function UMG_MiniGame_Task_C:OnDestruct()
end

function UMG_MiniGame_Task_C:OnAnimationFinished(anim)
end

return UMG_MiniGame_Task_C
