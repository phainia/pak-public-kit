local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabScreenTime = Base:Extend("DebugTabScreenTime")

function DebugTabScreenTime:Ctor()
  Base.Ctor(self)
end

function DebugTabScreenTime:SetupTabs()
  self.instruction = {
    instruction = {
      type = nil,
      openid = nil,
      uin = nil,
      title = nil,
      msg = nil,
      url = nil,
      modal = nil,
      rule_name = nil,
      logout_type = nil,
      trace_id = nil,
      logout_time = nil
    }
  }
end

function DebugTabScreenTime:TipsInstructions()
  self.instruction.instruction.type = 1
  self.instruction.instruction.msg = "\228\186\178\231\136\177\231\154\132\229\176\143\230\180\155\229\133\139,\230\130\168\228\187\138\230\151\165\231\180\175\232\174\161\229\156\168\231\186\191\230\151\182\233\149\191\229\183\178\232\190\1903\229\176\143\230\151\182,\232\175\183\229\144\136\231\144\134\229\174\137\230\142\146\230\130\168\231\154\132\230\184\184\230\136\143\230\151\182\233\151\180"
  _G.DelayManager:DelaySeconds(5, function()
    _G.NRCModeManager:DoCmd(TipsModuleCmd.OpenAntiAddictionPullDown, self.instruction.instruction)
  end)
  if self.Panel then
    self.Panel:DoClose()
  end
end

function DebugTabScreenTime:TipsProhibit()
  self.instruction.instruction.type = 2
  self.instruction.instruction.msg = "\228\186\178\231\136\177\231\154\132\229\176\143\230\180\155\229\133\139,\230\130\168\228\187\138\230\151\165\231\180\175\232\174\161\229\156\168\231\186\191\230\151\182\233\149\191\229\183\178\232\190\190\228\184\138\233\153\144,\232\175\183\230\179\168\230\132\143\228\188\145\230\129\175,\232\175\166\231\187\134\232\175\180\230\152\142\232\175\183\230\159\165\231\156\139\229\174\152\230\150\185\233\152\178\230\178\137\232\191\183\231\179\187\231\187\159\229\133\172\229\145\138"
  self.instruction.instruction.title = "\230\143\144\231\164\186"
  self.instruction.instruction.modal = 1
  _G.DelayManager:DelaySeconds(5, function()
    _G.NRCModeManager:DoCmd(TipsModuleCmd.OpenScreenTimeTips, self.instruction)
  end)
  if self.Panel then
    self.Panel:DoClose()
  end
end

function DebugTabScreenTime:TipsProhibitRemind()
  self.instruction.instruction.type = 8
  self.instruction.instruction.msg = "\228\186\178\231\136\177\231\154\132\229\176\143\230\180\155\229\133\139,\230\130\168\228\187\138\230\151\165\231\180\175\232\174\161\229\156\168\231\186\191\230\151\182\233\149\191\229\183\178\232\190\190\228\184\138\233\153\144,\232\175\183\230\179\168\230\132\143\228\188\145\230\129\175,\232\175\166\231\187\134\232\175\180\230\152\142\232\175\183\230\159\165\231\156\139\229\174\152\230\150\185\233\152\178\230\178\137\232\191\183\231\179\187\231\187\159\229\133\172\229\145\138"
  self.instruction.instruction.title = "\230\143\144\231\164\186"
  self.instruction.instruction.logout_time = _G.ZoneServer:GetServerTime() + 910
  _G.DelayManager:DelaySeconds(5, function()
    _G.NRCModeManager:DoCmd(TipsModuleCmd.OpenScreenTimeTips, self.instruction)
  end)
  if self.Panel then
    self.Panel:DoClose()
  end
end

function DebugTabScreenTime:TestTextContent()
  self.instruction.instruction.type = 2
  self.instruction.instruction.msg = "\228\186\178\231\136\177\231\154\132\229\176\143\230\180\155\229\133\139,\230\130\168\228\187\138\230\151\165\231\180\175\232\174\161\229\156\168\231\186\191\230\151\182\233\149\191\229\183\178\232\190\190\228\184\138\233\153\144,\232\175\183\230\179\168\230\132\143\228\188\145\230\129\175,\232\175\166\231\187\134\232\175\180\230\152\142\232\175\183\230\159\165\231\156\139\229\174\152\230\150\185\233\152\178\230\178\137\232\191\183\231\179\187\231\187\159\229\133\172\229\145\138,\228\186\178\231\136\177\231\154\132\229\176\143\230\180\155\229\133\139,\230\130\168\228\187\138\230\151\165\231\180\175\232\174\161\229\156\168\231\186\191\230\151\182\233\149\191\229\183\178\232\190\190\228\184\138\233\153\144,\232\175\183\230\179\168\230\132\143\228\188\145\230\129\175,\232\175\166\231\187\134\232\175\180\230\152\142\232\175\183\230\159\165\231\156\139\229\174\152\230\150\185\233\152\178\230\178\137\232\191\183\231\179\187\231\187\159\229\133\172\229\145\138,\228\186\178\231\136\177\231\154\132\229\176\143\230\180\155\229\133\139,\230\130\168\228\187\138\230\151\165\231\180\175\232\174\161\229\156\168\231\186\191\230\151\182\233\149\191\229\183\178\232\190\190\228\184\138\233\153\144,\232\175\183\230\179\168\230\132\143\228\188\145\230\129\175,\232\175\166\231\187\134\232\175\180\230\152\142\232\175\183\230\159\165\231\156\139\229\174\152\230\150\185\233\152\178\230\178\137\232\191\183\231\179\187\231\187\159\229\133\172\229\145\138,"
  self.instruction.instruction.title = "\230\143\144\231\164\186"
  self.instruction.instruction.modal = 0
  _G.DelayManager:DelaySeconds(5, function()
    _G.NRCModeManager:DoCmd(TipsModuleCmd.OpenScreenTimeTips, self.instruction)
  end)
  if self.Panel then
    self.Panel:DoClose()
  end
end

return DebugTabScreenTime
