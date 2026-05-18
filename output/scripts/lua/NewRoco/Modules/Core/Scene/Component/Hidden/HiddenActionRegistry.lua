local HiddenActionRegistry = {}
HiddenActionRegistry.Entry = nil

function HiddenActionRegistry.Get(HiddenType, ...)
  if HiddenActionRegistry.Entry == nil then
    HiddenActionRegistry.Entry = {
      [Enum.WorldHide.WH_DRILL] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDrill"),
      [Enum.WorldHide.WH_MIMIC] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionMimic"),
      [Enum.WorldHide.WH_MIMIC_OPTION] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionMimic"),
      [Enum.WorldHide.WH_STATIC] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionStatic"),
      [Enum.WorldHide.WH_HIDE] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionHide"),
      [Enum.WorldHide.WH_GHOST] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionGhost"),
      [Enum.WorldHide.WH_THUNDER] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionThunderrush"),
      [Enum.WorldHide.WH_DIVING] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDiving"),
      [Enum.WorldHide.WH_FISHJUMP] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDivingJump"),
      [Enum.WorldHide.WH_TRAIL] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionTrail"),
      [Enum.WorldHide.WH_FALLING] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionMeteor"),
      [Enum.WorldHide.WH_DRILL_IMME] = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDrillImme")
    }
  end
  if not HiddenType then
    return nil
  end
  local Klass = HiddenActionRegistry.Entry[HiddenType]
  if not Klass then
    return nil
  end
  return Klass(...)
end

return HiddenActionRegistry
