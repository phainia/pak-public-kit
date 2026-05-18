local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabBattleRogueEvent = Base:Extend("DebugTabBattleRogueEvent")

function DebugTabBattleRogueEvent:Ctor(...)
  Base.Ctor(self, ...)
  self.needRefresh = true
end

function DebugTabBattleRogueEvent:SetupTabs()
  if not _G.NRCModuleManager:IsModuleActive("BattleRogueModule") then
    return
  end
  local CurLevelConf = _G.NRCModuleManager:DoCmd(_G.BattleRogueModuleCmd.GetCurChallengeLevelConf)
  if not CurLevelConf then
    return
  end
  local EventConfIDs = CurLevelConf.event
  local EventConfigs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.EVENT_BASE_CONF):GetAllDatas()
  local BtnTopic = ""
  for _, EventConfID in pairs(EventConfIDs) do
    local EventConf = EventConfigs[EventConfID]
    if not EventConf then
    else
      BtnTopic = string.format("%s-%s-%s", EventConf.id, EventConf.name, EventConf.describe)
      
      local function Callback()
        Log.Warning("\230\154\130\230\151\182\228\184\141\230\148\175\230\140\129\233\128\137\230\139\169\228\187\187\230\132\143\228\186\139\228\187\182\231\137\140")
      end
      
      self:Add(BtnTopic, Callback, self)
    end
  end
end

return DebugTabBattleRogueEvent
