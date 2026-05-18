local JsonUtils = require("Common.JsonUtils")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabOperationUI = Base:Extend("DebugTabOperationUI")

function DebugTabOperationUI:Ctor()
  Base.Ctor(self)
end

function DebugTabOperationUI:SetupTabs()
  self:Add("\229\188\128\229\144\175or\229\133\179\233\151\173\230\176\180\229\141\176", self.OpenOrCloseOpenWaterMask, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
end

function DebugTabOperationUI:OpenOrCloseOpenWaterMask()
end

return DebugTabOperationUI
