local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local BlockInputAction = Base:Extend("BlockInputAction")
FsmUtils.MergeMembers(Base, BlockInputAction, {
  {name = "Block", type = "boolean"}
})

function BlockInputAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BlockInputAction:OnEnter()
  if self:GetProperty("Block", false) then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker, "DialogueModule.BlockInputAction")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "DialogueModule.BlockInputAction")
  end
  self:Finish()
end

function BlockInputAction:OnExit()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "DialogueModule.BlockInputAction")
end

return BlockInputAction
