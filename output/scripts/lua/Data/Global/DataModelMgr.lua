local DataModelMgr = Singleton:Extend("DataModelMgr")

function DataModelMgr:Ctor()
  Singleton.Ctor(self, self.name)
  self.dataModel = Array()
end

function DataModelMgr:Init()
  self.ServerData = require("Data.Global.ServerDataModel")()
  self.PlayerDataModel = require("Data.Global.PlayerDataModel")()
  self.LoginNotifyModel = require("Data.Global.LoginNotifyModel")()
  self.RemoteStorage = require("Data.Global.RemoteStorageDataModel")()
  self.dataModel:Push(self.ServerData)
  self.dataModel:Push(self.PlayerDataModel)
  self.dataModel:Push(self.LoginNotifyModel)
  self.dataModel:Push(self.RemoteStorage)
end

return DataModelMgr
