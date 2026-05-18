local MagicMsgFrame = _G.MakeSimpleClass("MagicMsgFrame")

function MagicMsgFrame:Ctor(protocolId, playActName, frameTime, msgSize, msg)
  self.protocolId = protocolId
  self.playActName = playActName
  self.frameTime = frameTime
  self.msgSize = msgSize
  self.msg = msg
end

function MagicMsgFrame:GetProtocolFullName()
  local protocolName = _G.ProtoCMD:GetMessageName(self.protocolId)
  local protocolFullName = protocolName
  if self.protocolId == _G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAY_ACTS_NOTIFY then
    protocolFullName = protocolName .. "_" .. self.playActName
  end
  return protocolFullName
end

return MagicMsgFrame
