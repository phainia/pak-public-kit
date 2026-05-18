local LevelUpUIModuleData = _G.NRCData:Extend("LevelUpUIModuleData")

function LevelUpUIModuleData:Ctor()
  NRCData.Ctor(self)
  self.NPCActionOpenLevelAwards = nil
end

return LevelUpUIModuleData
