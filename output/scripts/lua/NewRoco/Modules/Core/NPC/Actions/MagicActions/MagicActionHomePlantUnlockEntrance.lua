local MagicActionBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionBase
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local MagicActionHomePlantUnlockEntrance = Base:Extend("MagicActionHomePlantUnlockEntrance")

function MagicActionHomePlantUnlockEntrance:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionHomePlantUnlockEntrance:Execute()
  Base.Execute(self)
end

return MagicActionHomePlantUnlockEntrance
