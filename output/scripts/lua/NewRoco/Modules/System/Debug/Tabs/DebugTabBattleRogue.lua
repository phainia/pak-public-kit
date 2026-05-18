local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabBattleRogue = Base:Extend("DebugTabBattleRogue")

function DebugTabBattleRogue:Ctor(...)
  Base.Ctor(self, ...)
  self.needRefresh = true
end

function DebugTabBattleRogue:SetupTabs()
  if not _G.NRCModuleManager:IsModuleActive("BattleRogueModule") then
    return
  end
  local RogueLevelConfigs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ROGUE_LEVEL_CONF):GetAllDatas()
  local BtnTopic = ""
  for _, LevelConf in pairs(RogueLevelConfigs) do
    local LevelID = LevelConf.id
    BtnTopic = string.format("%s-%s", LevelID, LevelConf.topic)
    
    local function Callback()
      _G.NRCModuleManager:DoCmd(_G.BattleRogueModuleCmd.SendChallengeLevelReq, LevelID)
    end
    
    self:Add(BtnTopic, Callback, self)
  end
end

return DebugTabBattleRogue
