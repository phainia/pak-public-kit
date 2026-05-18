local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local DialogueSkipBlackScreenAction = Base:Extend("DialogueSkipBlackScreenAction")
FsmUtils.MergeMembers(Base, DialogueSkipBlackScreenAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "ConfID", type = "var"},
  {name = "LastConfID", type = "var"}
})

function DialogueSkipBlackScreenAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.DummyConf = nil
end

function DialogueSkipBlackScreenAction:OnEnter()
  self:InjectProperties()
  local SkipConfID = self.ConfID > 0 and self.ConfID or self.LastConfID
  if SkipConfID and SkipConfID > 0 then
    local SkipConf = _G.DataConfigManager:GetDialogueConf(SkipConfID)
    if SkipConf and not string.IsNilOrEmpty(SkipConf.dia_skip_text) then
      self.DummyConf = {}
      self.DummyConf.id = -SkipConfID
      self.DummyConf.text = SkipConf.dia_skip_text
      self.DummyConf.ui_source_type = Enum.UIsourceType.UIT_BLACK
      self.DummyConf.speed = 30
      self.ParentModule:_OpenConfiggedPanel(self.DummyConf, self.ParentModule.PreUIType, nil, nil, self.OnSkipBlackFadeIn, self)
      self.ParentModule.PreUIType = Enum.UIsourceType.UIT_BLACK
      return
    end
  end
  self:Finish()
end

function DialogueSkipBlackScreenAction:OnSkipBlackFadeIn()
  if self.ParentModule then
    self.fsm:Pause()
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished, self.OnUserClick)
  end
end

function DialogueSkipBlackScreenAction:OnUserClick(DialogueConfOnPanel)
  if DialogueConfOnPanel and self.DummyConf and DialogueConfOnPanel.id == self.DummyConf.id then
    self:Finish()
  end
end

function DialogueSkipBlackScreenAction:OnFinish()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueTalkFinished)
  end
  if self.fsm and self.fsm.Resume then
    self.fsm:Resume()
  end
  if not self.ConfID or self.ConfID <= 0 then
    local SkipConfID = self.LastConfID
    if SkipConfID and SkipConfID > 0 then
      local SkipConf = _G.DataConfigManager:GetDialogueConf(SkipConfID)
      if SkipConf then
        local TaskIDs = _G.DataConfigManager:GetDialogueUsedByTaskConf(SkipConfID, true)
        if TaskIDs then
          for _, TaskID in ipairs(TaskIDs.task_id) do
            local Task = NRCModuleManager:DoCmd(TaskModuleCmd.getTaskByID, TaskID)
            local bValidTask = nil ~= Task
            if bValidTask then
              local bShouldGlobalBlackScreenBlendIn = false
              local CurrentOption = self.fsm:GetProperty("CurrentOption")
              local OptionConf = CurrentOption and CurrentOption.config
              OptionConf = OptionConf or self.fsm:GetProperty("OptionConf")
              local OptionConfID = OptionConf and OptionConf.id
              if OptionConfID then
                local bOpenGlobalBlack = NRCModuleManager:DoCmd(BlackScreenModuleCmd.OpenGlobalBlackScreenIfNeed, TaskID, bShouldGlobalBlackScreenBlendIn, nil, nil, {OptionID = OptionConfID})
                if bOpenGlobalBlack then
                  break
                end
              end
            end
          end
        end
      end
    end
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState)
  end
end

return DialogueSkipBlackScreenAction
