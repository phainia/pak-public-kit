require("UnLuaEx")
local DialoguePanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialoguePanelBase")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local UMG_TaskFetchText_C = DialoguePanelBase:Extend("UMG_TaskFetchText_C")
local _FETCHER_TEXT_DURATION = 1500

function UMG_TaskFetchText_C:OnConstruct()
  DialoguePanelBase.OnConstruct(self)
  self:BindInputAction()
  local cfg = _G.DataConfigManager:GetGlobalConfig("dialogue_task_fetcher_duration")
  if cfg then
    _FETCHER_TEXT_DURATION = cfg.num
  end
end

function UMG_TaskFetchText_C:OnDestruct()
  DialoguePanelBase.OnDestruct(self)
  self:UnBindInputAction()
end

function UMG_TaskFetchText_C:BindInputAction()
  local DialogueIMC = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_Dialogue")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, DialogueIMC, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_NextDialogue")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "NextDialogue")
end

function UMG_TaskFetchText_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_NextDialogue")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local DialogueIMC = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_Dialogue")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, DialogueIMC)
end

function UMG_TaskFetchText_C:NextDialogue()
  self:OnDialogueCLick()
end

function UMG_TaskFetchText_C:ShowTitle(DialogueConf)
  DialoguePanelBase.Show(self, DialogueConf)
  if not DialogueConf then
    Log.Error("UMG_TaskFetchText_C:Show DialogueConf is nil")
    return
  end
  if not DialogueConf.text or DialogueConf.text == "" then
    Log.ErrorFormat("UMG_TaskFetchText_C:Show DialogueConf %d text is nil or empty", DialogueConf.id)
    return
  end
  Log.DebugFormat("UMG_TaskFetchText_C:Show id %d text %s", DialogueConf.id, DialogueConf.text)
  t = DialogueConf.text:split("\n")
  if not t or table.len(t) <= 0 then
    return
  end
  self.Title:SetText("")
  if table.len(t) >= 1 then
    self.Title:SetText(t[1])
  end
  self.RocoTitle:SetText("")
  if table.len(t) >= 2 then
    self.RocoTitle:SetText(t[2])
  end
end

function UMG_TaskFetchText_C:OnAnimationFinished(animation)
  DialoguePanelBase.OnAnimationFinished(self, animation)
  if animation == self:GetEnterAnimation() then
    local task = a.task(function()
      a.wait(au.DelaySeconds(_FETCHER_TEXT_DURATION / 1000.0))
      self:PlayEndAnimation()
    end)
    task(function()
      Log.Debug("UMG_TaskFetchText_C:OnAnimationFinished start PlayEndAnimation")
    end)
  elseif animation == self:GetEndAnimation() then
    local Module = _G.NRCModuleManager:GetModule("DialogueModule")
    Module:ClosePanel("TaskFetchText")
  end
end

return UMG_TaskFetchText_C
