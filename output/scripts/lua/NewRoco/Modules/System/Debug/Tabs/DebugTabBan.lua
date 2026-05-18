local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabBan = Base:Extend("DebugTabBan")

function DebugTabBan:Ctor()
  Base.Ctor(self)
end

function DebugTabBan:SetupTabs()
  self:Add("\230\183\187\229\138\160\228\186\146\230\150\165\231\138\182\230\128\129", self.ApplyBanStatus, self)
  self:Add("\231\167\187\233\153\164\228\186\146\230\150\165\231\138\182\230\128\129", self.RemoveBanStatus, self)
end

function DebugTabBan:ShowPlayerLogicStatus(Name, Panel)
  local Player = self:GetPlayer()
  local Comp = Player.LogicStatusComponent
  self:Inspect(Comp:GetSummary(), "PlayerLogicStatus")
end

function DebugTabBan:ShowBanState(name, panel)
  local BanData = {}
  local RawData = _G.FunctionBanManager.functionStateDic
  local endIdx = Enum.PlayerFunctionBanType.PFBT_END - 1
  local startIdx = Enum.PlayerFunctionBanType.PFBT_BEGIN + 1
  for i = endIdx, startIdx, -1 do
    BanData[table.getKeyName(Enum.PlayerFunctionBanType, i)] = RawData[i] or "\230\151\160"
  end
  self:Inspect(BanData, "\228\186\146\230\150\165\231\138\182\230\128\129")
end

function DebugTabBan:ShowPlayerState(name, panel)
  local BanData = {}
  local RawData = _G.FunctionBanManager.playerConditionDic
  for key, cfg in pairs(RawData) do
    BanData[table.getKeyName(Enum.PlayerConditionType, key)] = cfg
  end
  self:Inspect(BanData, "\231\142\169\229\174\182\231\138\182\230\128\129")
end

function DebugTabBan:ApplyBanStatus(Name, Panel)
  local Input = self:GetInputString()
  local MaybeID = tonumber(Input)
  MaybeID = MaybeID or Enum.PlayerConditionType[Input]
  _G.FunctionBanManager:AddPlayerConditionType(MaybeID, "GM")
end

function DebugTabBan:RemoveBanStatus(Name, Panel)
  local Input = self:GetInputString()
  local MaybeID = tonumber(Input)
  MaybeID = MaybeID or Enum.PlayerConditionType[Input]
  _G.FunctionBanManager:RemovePlayerConditionType(MaybeID, "GM")
end

function DebugTabBan:TestPauseWorld(Name, Panel)
  self:ClosePanel()
  UE.UNRCStatics.TickPlayersOnly(true)
end

function DebugTabBan:TestResumeWorld(Name, Panel)
  UE.UNRCStatics.TickPlayersOnly(false)
end

return DebugTabBan
