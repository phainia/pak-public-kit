local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabMagicReplay = Base:Extend("DebugTabMagicReplay")

function DebugTabMagicReplay:Ctor()
  Base.Ctor(self)
end

function DebugTabMagicReplay:SetupTabs()
  self:Add("\230\181\139\232\175\149\231\149\153\229\189\177\229\188\128\229\167\139\229\189\149\229\140\133", self.GmStartRecord, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "GmStartRecord")
  self:Add("\230\181\139\232\175\149\231\149\153\229\189\177\231\187\147\230\157\159\229\189\149\229\140\133", self.GmStopRecord, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "GmStopRecord")
end

function DebugTabMagicReplay:GmStartRecord(Name, Panel)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.SendStartRecordReq)
end

function DebugTabMagicReplay:GmStopRecord(Name, Panel)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.SendStopRecordReq)
end

return DebugTabMagicReplay
