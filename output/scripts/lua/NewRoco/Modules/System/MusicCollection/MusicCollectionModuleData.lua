local MusicCollectionModuleData = _G.NRCData:Extend("MusicCollectionModuleData")

function MusicCollectionModuleData:Ctor()
  NRCData.Ctor(self)
  self.MusicList = {}
end

return MusicCollectionModuleData
