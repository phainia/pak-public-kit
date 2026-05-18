local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local MagicActionStarHitFruitTree = Base:Extend("MagicActionStarHitFruitTree")

function MagicActionStarHitFruitTree:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionStarHitFruitTree:OnExecute()
  local TreeView = self:GetRunnerView()
  TreeView.InteractType = NPCModuleEnum.InteractType.STAR_HIT
  self:Finish(true)
end

function MagicActionStarHitFruitTree:OnSubmit(rsp)
  local TreeView = self:GetRunnerView()
end

return MagicActionStarHitFruitTree
