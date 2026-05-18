local Delegate = require("Utils.Delegate")
local BinDataManager = Class()

function BinDataManager:Ctor()
end

function BinDataManager:RegisterBinData(name, binPath, binConf, binDataRootPath)
  self.Overridden.RegisterBinData(self, name, binPath, binConf, binDataRootPath or "")
end

function BinDataManager:LoadBinData(name, async, bReload)
  self.Overridden.LoadBinData(self, name, async or false, bReload or false)
end

function BinDataManager:SetLocalizationFilePath(filepath, rootPath)
  self.Overridden.SetLocalizationFilePath(self, filepath, rootPath or "")
end

function BinDataManager:GetBinDataAll(name)
  return self.Overridden.GetTableDataAll(self, name)
end

function BinDataManager:GetBinDataByIndex(name, index)
  return self.Overridden.GetTableDataByIndex(self, name, index - 1)
end

function BinDataManager:GetBinDataByKey(name, keyValue)
  return self.Overridden.GetTableDataByKey(self, name, keyValue)
end

function BinDataManager:GetBinDataCount(name)
  return self.Overridden.GetTableDataCount(self, name)
end

function BinDataManager:GetTableDataIndex(name, keyValue)
  return self.Overridden.GetTableDataIndex(self, name, keyValue)
end

function BinDataManager:IsTableDataHasKey(name)
  return self.Overridden.IsTableDataHasKey(self, name)
end

return BinDataManager
