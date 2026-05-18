local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabAura = Base:Extend("DebugTabAura")

function DebugTabAura:SetupTabs()
  self:Add("\229\188\128\229\133\179\229\144\140\230\173\165\229\133\137\231\142\175debug\230\152\190\231\164\186", self.SwitchDebugDrawSyncAura, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SwitchDebugDrawSyncAura")
  for Name, Value in pairs(Enum.AuraEffect) do
    self:Add(Name, function(ButtonName, Panel)
      local Auras = self:GetPlayer().AuraComponent:GetAuraByEffectType(Value)
      self:Inspect(Auras, Name)
    end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\159\165\231\156\139\229\133\137\231\142\175\231\137\185\230\149\136")
  end
end

function DebugTabAura:SeeAuraEffect(Name, ButtonName, Panel)
  local Auras = self:GetPlayer().AuraComponent:GetAuraByEffectType(Value)
  self:Inspect(Auras, Name)
end

function DebugTabAura:ShowAura(Name, Panel)
  self:Inspect(self:GetPlayer().AuraComponent.Auras)
end

function DebugTabAura:ShowCachedAura(Name, Panel)
  self:Inspect(self:GetPlayer().AuraComponent.CachedSpaceAction)
end

function DebugTabAura:SwitchDebugDrawSyncAura(Name, Panel)
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.SwitchDebugDrawSyncAura)
end

return DebugTabAura
