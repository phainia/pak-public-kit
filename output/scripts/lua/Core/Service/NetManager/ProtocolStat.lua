local ProtocolStat = Class()
local DEFAULT_MAX_STAT_COUNT = 100
local DEFAULT_MAX_STAT_TIME = 1000
local DEFAULT_MAX_WARN_FREQ = 30
local DEFAULT_WARN_CD = 10000
local CustomWarFreq = {
  [".Next.ZoneScenePlayActsNotify_actor_enter"] = 200,
  [".Next.ZoneScenePlayActsNotify_actor_leave"] = 200,
  [".Next.ZoneScenePlayActsNotify_client_move"] = 1000,
  [".Next.ZoneScenePlayActsNotify_server_move"] = 100,
  [".Next.ZoneScenePlayActsNotify_interrupt_server_move"] = 100,
  [".Next.ZoneScenePlayActsBatchNotify"] = 1000,
  [".Next.ZoneTaskQueryRsp"] = 100,
  [".Next.ZonePlayerSyncNotify"] = 100,
  [".Next.ZoneScenePlayActsNotify_attr_change"] = 100,
  [".Next.ZoneScenePlayActsNotify_npc_option_info_change"] = 100,
  [".Next.ZoneScenePlayActsNotify_sync_player_status"] = 100,
  [".Next.ZoneScenePlayActsNotify_update_actor_logic_status"] = 100,
  [".Next.ZoneScenePlayActsNotify_battle_ai_status_changed"] = 100,
  [".Next.ZoneScenePlayActsNotify_play_animation"] = 100,
  [".Next.ZoneScenePlayActsNotify_scene_ai_control_flags_changed"] = 100,
  [".Next.ZoneScenePlayActsNotify_aura_info_change"] = 100,
  [".Next.ZoneScenePlayActsNotify_body_temp_notify"] = 100,
  [".Next.ZoneFriendGetFriendListRsp"] = 100
}

function ProtocolStat:Ctor(protocolID, protocolName, extraName, warnCaller, warnCallback)
  self.ProtocolID = protocolID
  self.ProtocolName = protocolName
  self.extraName = extraName
  self.MaxStatTime = DEFAULT_MAX_STAT_TIME
  local statKey = self:GetStatKey()
  self.MaxWarnFreq = CustomWarFreq[statKey] or DEFAULT_MAX_WARN_FREQ
  self.ReceiveTimeQueue = _G.Queue(DEFAULT_MAX_STAT_COUNT)
  self.MaxFreqRecorded = 0
  self.WarnCaller = warnCaller
  self.WarnCallback = warnCallback
  self.lastWarnTime = 0
end

function ProtocolStat:Stat(receiveTimeMs)
  self.ReceiveTimeQueue:Enqueue(receiveTimeMs)
  local validOldestTime = receiveTimeMs - self.MaxStatTime
  while self.ReceiveTimeQueue:Size() > 0 and validOldestTime > self.ReceiveTimeQueue:First() do
    self.ReceiveTimeQueue:Dequeue()
  end
  local Freq = self.ReceiveTimeQueue:Size()
  local nowTime = UE4.UNRCStatics.GetTimestampMS()
  if Freq > self.MaxWarnFreq and nowTime - self.lastWarnTime > DEFAULT_WARN_CD then
    self.MaxFreqRecorded = math.max(self.MaxFreqRecorded, Freq)
    Log.ErrorFormat("[ZoneServer][NetMsg]ProtocolStat:%s high freq! Freq(%f) > MaxWarnFreq(%f), MaxFreqRecorded(%f)", self:GetStatKey(), Freq, self.MaxWarnFreq, self.MaxFreqRecorded)
    if self.WarnCaller and self.WarnCallback then
      _G.tcall(self.WarnCaller, self.WarnCallback, self:GetStatKey(), Freq, self.MaxWarnFreq, self.MaxFreqRecorded)
    end
    self.ReceiveTimeQueue:Clear()
    self.lastWarnTime = UE4.UNRCStatics.GetTimestampMS()
  end
end

function ProtocolStat:GetStatKey()
  return ProtocolStat.GetKey(self.ProtocolName, self.extraName)
end

function ProtocolStat.GetKey(protocolName, extraName)
  if protocolName then
    if extraName then
      return string.format("%s_%s", protocolName, extraName)
    else
      return protocolName
    end
  end
  return nil
end

return ProtocolStat
