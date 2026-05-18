local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local ClearNextConfIDAction = Base:Extend("ClearNextConfIDAction")
FsmUtils.MergeMembers(Base, ClearNextConfIDAction, {
  {name = "ConfID", type = "var"}
})

function ClearNextConfIDAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function ClearNextConfIDAction:OnEnter()
  self:InjectProperties()
  self.fsm:SetProperty("NextConfID", nil)
  self:Finish()
end

return ClearNextConfIDAction
