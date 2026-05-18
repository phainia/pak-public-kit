local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabPlayerInfo = Base:Extend("DebugTabPlayerInfo")

function DebugTabPlayerInfo:SetupTabs()
  self:Add("\229\136\135\230\141\162\229\164\180\233\161\182\228\191\161\230\129\175\230\152\190\231\164\186", self.ToggleShowActorDebugInfo, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self.options = {
    callbackOwner = self,
    onCheckStateChangedCallback = self.OnCheckStateChanged,
    optionData = GlobalConfig.ActorDebugInfoRegions
  }
end

function DebugTabPlayerInfo:ToggleShowActorDebugInfo(name, panel)
  GlobalConfig.DebugShowActorDebugInfo = not GlobalConfig.DebugShowActorDebugInfo
end

function DebugTabPlayerInfo:OnCheckStateChanged(checked, data, datalist, index, checkBoxUMG)
  GlobalConfig.ActorDebugInfoRegions[data.name].show = checked
end

return DebugTabPlayerInfo
