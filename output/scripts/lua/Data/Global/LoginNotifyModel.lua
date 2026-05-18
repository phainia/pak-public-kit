local DataModelBase = require("Data.Global.DataModelBase")
local LoginNotifyModel = DataModelBase:Extend("LoginNotifyModel")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local PetUtils = require("NewRoco.Utils.PetUtils")

function LoginNotifyModel:Ctor()
  DataModelBase.Ctor(self)
  self:Init()
end

function LoginNotifyModel:Init()
  self.notifyDict = {}
end

function LoginNotifyModel:WriteCache(tag, notifyCmdId, notify)
  Log.Debug("LoginNotifyModel WriteCache:", tag, notifyCmdId)
  tag = tag or "Default"
  if not self.notifyDict[tag] then
    self.notifyDict[tag] = {}
  end
  local item = {}
  item.notifyCmdId = notifyCmdId
  item.notify = notify
  table.insert(self.notifyDict[tag], item)
end

function LoginNotifyModel:GetCache(tag)
  tag = tag or "Default"
  if not self.notifyDict[tag] then
    return nil
  end
  Log.Debug("LoginNotifyModel GetCache:", tag)
  return self.notifyDict[tag]
end

function LoginNotifyModel:ClearCache()
  self.notifyDict = {}
end

return LoginNotifyModel
