local pb = require("pb")
local pb_unsafe = require("pb.unsafe")
local ProtoCMD = require("Data.PB.ProtoCMD")
local ProtoMgr = {}

function ProtoMgr:Init()
  pb.option("enum_as_value")
  assert(pb.loadufsfile(RocoEnv.PB_PATH))
end

function ProtoMgr:Encode(cmd, msg)
  local name = ProtoCMD:GetMessageName(cmd)
  local data = pb.encode(name, msg)
  assert(data)
  return data
end

function ProtoMgr:Decode(cmd, data)
  local name = ProtoCMD:GetMessageName(cmd)
  local msg = pb.decode(name, data)
  if not msg then
    Log.Error("\229\141\143\232\174\174\229\175\185\228\184\141\228\184\138\229\149\166\239\188\129\229\187\186\232\174\174\230\155\180\230\150\176", name, cmd)
  end
  assert(msg)
  return msg
end

function ProtoMgr:DecodeRaw(name, raw, len)
  local msg = pb_unsafe.decode(name, raw, len)
  if not msg then
    Log.Error("\229\141\143\232\174\174\229\175\185\228\184\141\228\184\138\229\149\166\239\188\129\229\187\186\232\174\174\230\155\180\230\150\176", name)
  end
  assert(msg)
  return msg
end

return ProtoMgr
