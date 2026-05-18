local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabPGC = Base:Extend("DebugTabPGC")

function DebugTabPGC:Ctor()
  Base.Ctor(self)
end

function DebugTabPGC:SetupTabs()
  self:Add("\230\137\147\229\188\128", self.OpenPGCMainView, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179\233\151\173", self.ClosePGCMainView, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
end

function DebugTabPGC:OpenPGCMainView()
  NRCModuleManager:DoCmd(_G.PGCModuleCmd.OpenMainView)
end

function DebugTabPGC:ClosePGCMainView()
  NRCModuleManager:DoCmd(_G.PGCModuleCmd.CloseMainView)
end

return DebugTabPGC
