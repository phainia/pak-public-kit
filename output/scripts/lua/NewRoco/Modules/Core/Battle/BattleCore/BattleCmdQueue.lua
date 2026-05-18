local BattleCmdQueue = NRCClass:Extend()

function BattleCmdQueue:Ctor()
  self.lst = {}
end

function BattleCmdQueue:AddListener()
  self.battleNetManager:AddEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY, self.OnEnterBattleNotify)
  self.battleNetManager:AddEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PRE_PLAY_NOTIFY, self.OnBattlePrePlayNotify)
  self.battleNetManager:AddEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_START_NOTIFY, self.OnBattleRoundStartNotify)
  self.battleNetManager:AddEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PERFORM_START_NOTIFY, self.OnBattlePerformNotify)
  self.battleNetManager:AddEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_FINISH_NOTIFY, self.OnBattleFinishNotify)
end

function BattleCmdQueue:RemoveListener()
  self.battleNetManager:RemoveEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY, self.OnEnterBattleNotify)
  self.battleNetManager:RemoveEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PRE_PLAY_NOTIFY, self.OnBattlePrePlayNotify)
  self.battleNetManager:RemoveEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_START_NOTIFY, self.OnBattleRoundStartNotify)
  self.battleNetManager:RemoveEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PERFORM_START_NOTIFY, self.OnBattlePerformNotify)
  self.battleNetManager:RemoveEventListener(self, ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_FINISH_NOTIFY, self.OnBattleFinishNotify)
end

function BattleCmdQueue:OnBattleNotify(type, notify)
end

function BattleCmdQueue:Push(cmd)
end

function BattleCmdQueue:Pop()
end

function BattleCmdQueue:Empty()
end

return BattleCmdQueue
