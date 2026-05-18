local ProtoEnum = require("Data.PB.ProtoEnum")
local ProtoCMD = require("Data.PB.ProtoCMD")
local BattleDebugger = require("NewRoco.Modules.Core.Battle.Debugger.BattleDebugger_Declare")

function BattleDebugger:ToString_ProtoEnum_Any(enumTypeName, value)
  if not _G.RocoEnv.IS_EDITOR then
    return tostring(value)
  else
    local enumTable = ProtoEnum[enumTypeName]
    if not enumTable then
      return string.format("unknow_enum_type[%s](%d)", enumTypeName, value)
    end
    for k, v in pairs(enumTable) do
      if v == value then
        return k
      end
    end
    return string.format("unknow_enum_value[%s](%d)", enumTypeName, value)
  end
end

function BattleDebugger:ToString_MessageId(messageId)
  return ProtoCMD.MessageMap[messageId] or string.format("unknow_message_id(%d)", messageId)
end

return BattleDebugger
