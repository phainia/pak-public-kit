local pb = require("pb")
local Delegate = require("Utils.Delegate")
local OnlineModuleEvent = require("NewRoco.Modules.Core.Online.OnlineModuleEvent")
local DataModelBase = require("Data.Global.DataModelBase")
local Base = DataModelBase
local RemoteStorageDataModel = Base:Extend("RemoteStorageDataModel")

function RemoteStorageDataModel:Ctor()
  Base.Ctor(self)
  self.SessionID = 1
  self.Callbacks = {}
  self.StorageCache = {}
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.Clear)
end

function RemoteStorageDataModel:Destroy()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.Clear)
end

function RemoteStorageDataModel:Clear()
  if self.Callbacks then
    for SessionID, Session in pairs(self.Callbacks) do
      Log.Warning("[\232\191\156\231\168\139\229\173\152\229\130\168]\233\135\141\231\153\187\230\151\182\230\184\133\231\144\134\230\174\139\231\149\153\229\155\158\232\176\131", SessionID, Session.Key, Session.DecoderName)
    end
    table.clear(self.Callbacks)
  end
  if self.StorageCache then
    table.clear(self.StorageCache)
  end
  self.SessionID = 1
end

function RemoteStorageDataModel:Get(Key, Protobuf, Caller, Callback)
  if self.StorageCache and self.StorageCache[Key] ~= nil then
    if Caller and Callback then
      Callback(Caller, self.StorageCache[Key])
    end
    Log.DebugFormat("RemoteStorageDataModel:Get from cache. Key=%s", tostring(Key))
    return
  end
  local rsReq = _G.ProtoMessage:newZoneClientRemoteStoreReq()
  rsReq.meth = "GET"
  rsReq.cli_stub = self.SessionID
  rsReq.key = Key
  local NewDelegate = Delegate()
  NewDelegate:Add(Caller, Callback)
  local Session = {
    Key = Key,
    SessionID = self.SessionID,
    Delegate = NewDelegate,
    DecoderName = Protobuf
  }
  self.Callbacks[self.SessionID] = Session
  self.SessionID = self.SessionID + 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_REMOTE_STORE_REQ, rsReq, self, self.InternalCallback, false, true)
end

function RemoteStorageDataModel:InternalCallback(rsp)
  local Session = self.Callbacks[rsp.cli_stub]
  if not Session then
    return
  end
  local Decoded = pb.decode(Session.DecoderName, rsp.value)
  self.StorageCache[Session.Key] = Decoded
  rawset(self, Session.Key, Decoded)
  local Del = Session.Delegate
  if Del then
    Del:Invoke(Decoded, rsp)
    Del:Clear()
  end
  self.Callbacks[rsp.cli_stub] = nil
end

function RemoteStorageDataModel:Set(Key, Protobuf, Data, Caller, Callback)
  if self.StorageCache and self.StorageCache[Key] ~= nil then
    self.StorageCache[Key] = nil
  end
  local rsReq = _G.ProtoMessage:newZoneClientRemoteStoreReq()
  rsReq.meth = "SET"
  rsReq.cli_stub = 0
  rsReq.key = Key
  rsReq.value = pb.encode(Protobuf, Data)
  if Caller and Callback then
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_REMOTE_STORE_REQ, rsReq, Caller, Callback, false, true)
  else
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_REMOTE_STORE_REQ, rsReq)
  end
end

return RemoteStorageDataModel
