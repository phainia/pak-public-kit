local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenTeachingImageUI = Base:Extend("NPCActionOpenTeachingImageUI")

function NPCActionOpenTeachingImageUI:BeforeBeginAction(Action)
  Base.BeforeBeginAction(self, Action)
  if not self.SkipSubmit then
    return
  end
  local Params = Action and Action.begin_act_params
  if not Params or #Params < 1 then
    self:Finish(false)
    return
  end
  self:OpenTeachingPanel(Params[1] or 0)
end

function NPCActionOpenTeachingImageUI:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 ~= rsp.ret_info.ret_code then
    self:Finish(false)
    return
  end
  local teach_id = 0
  local option = self.Owner
  if option and option.optionInfo and option.optionInfo.cur_action_info and option.optionInfo.cur_action_info.begin_act_params and option.optionInfo.cur_action_info.begin_act_params[1] then
    teach_id = option.optionInfo.cur_action_info.begin_act_params[1]
  end
  self:OpenTeachingPanel(teach_id)
end

function NPCActionOpenTeachingImageUI:OpenTeachingPanel(teach_id)
  if 0 == teach_id then
    self:Finish(false)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.OpenTeachingImageUI, teach_id, self)
end

return NPCActionOpenTeachingImageUI
