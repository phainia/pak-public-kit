local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local MagicActionSubmitItem = Base:Extend("MagicActionSubmitItem")

function MagicActionSubmitItem:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionSubmitItem:Execute()
  Log.Debug("MagicActionSubmitItem:Execute")
  Base.Execute(self)
  local player = self:GetPlayer()
  player:PlayAnim("Think", 1, 0, 0.1, 0.1, 999, 0, "Locomotion")
  _G.NRCModuleManager:DoCmd(MagicCreationModuleCmd.OpenTransferNpcPanel, self)
end

function MagicActionSubmitItem:SubmitItem()
  self:Finish(true, nil, "1")
end

function MagicActionSubmitItem:Finish(success, data, param)
  local localPlayer = self:GetPlayer()
  localPlayer:StopAnim("Think", 0.1, "Locomotion")
  Base.Finish(self, success, data, param)
end

return MagicActionSubmitItem
