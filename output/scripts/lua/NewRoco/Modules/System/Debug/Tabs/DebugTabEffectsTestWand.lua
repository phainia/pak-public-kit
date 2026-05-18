local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabEffectsTestWand = Base:Extend("DebugTabEffects")

function DebugTabEffectsTestWand:SetupTabs()
  self:Add("\232\191\152\229\142\159\233\187\152\232\174\164", self.ResetWand, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  local WandConfTab = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.FASHION_WAND_CONF):GetAllDatas()
  for index, WandConf in pairs(WandConfTab) do
    local name = WandConf.editor_name
    if nil == name or "" == name then
      name = WandConf.WandName
    end
    self:Add(name, function()
      self:SwitchWand(WandConf.id, name)
    end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\229\136\135\230\141\162\230\152\190\231\164\186\229\157\144\233\170\145")
  end
end

function DebugTabEffectsTestWand:ResetWand()
  if _G.PlayerModuleCmd then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      localPlayer._OverrideWandId = nil
      Log.Error("\233\173\148\230\157\150\230\129\162\229\164\141\228\184\186\233\187\152\232\174\164")
    end
  end
end

function DebugTabEffectsTestWand:SwitchWand(id, name)
  if _G.PlayerModuleCmd then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      localPlayer._OverrideWandId = id
      localPlayer:ChangeDefaultWand(id)
      Log.Error("\233\173\148\230\157\150\229\136\135\230\141\162\228\184\186", id, name)
    end
  end
end

return DebugTabEffectsTestWand
