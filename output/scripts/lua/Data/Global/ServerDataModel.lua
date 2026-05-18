local DataModelBase = require("Data.Global.DataModelBase")
local ServerDataModel = DataModelBase:Extend("ServerDataModel")

function ServerDataModel:Ctor()
  DataModelBase.Ctor(self)
end

return ServerDataModel
