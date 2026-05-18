local Timer = require("Utils.Timer")
local UMG_Pass_C = _G.NRCUmgClass:Extend("UMG_Pass_C")

function UMG_Pass_C:Construct()
  self:InitUI()
  self.lastOpenState = nil
end

function UMG_Pass_C:Destruct()
  if self.CheckBpOpenTimer then
    _G.TimerManager:RemoveTimer(self.CheckBpOpenTimer)
    self.CheckBpOpenTimer = nil
  end
end

function UMG_Pass_C:InitUI()
  local bpTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.BATTLE_PASS_CONF)
  local bpCfgs = bpTable:GetAllDatas()
  local UIBanConf = _G.DataConfigManager:GetUiEnterBanConf(_G.Enum.FunctionEntrance.FE_BP)
  self.OpenLevel = tonumber(UIBanConf.unlock_cond_list[1].unlock_param[1])
  local t = {}
  local curTime = self:GetCurServerTime()
  for _, cfg in pairs(bpCfgs) do
    local open_time = self:ConvertToTimeSeconds(cfg.open_time)
    local close_time = self:ConvertToTimeSeconds(cfg.close_time)
    if curTime <= open_time or curTime <= close_time then
      t[#t + 1] = {
        id = cfg.id,
        open_time = open_time,
        close_time = close_time
      }
    end
  end
  table.sort(t, function(a, b)
    return a.id < b.id
  end)
  self.CacheTimeCfgs = t
  local isOpen = self:CheckBpIsOpen()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_BP)
  local isShow = not isBan and isOpen
  self.Btn_Pass:SetVisibility(UE4.ESlateVisibility.Visible)
  self:SetVisibility(isShow and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  if false == isShow then
    Log.Debug("\230\181\139\232\175\149\230\151\165\229\191\151pass icon\239\188\154\229\189\147\229\137\141\230\180\187\229\138\168\229\188\128\229\144\175\231\138\182\230\128\129", isOpen, "isBan:", isBan, isShow)
  end
  self.Dot_1:SetupKey(149)
  if #t > 0 then
    self.CheckBpOpenTimer = _G.TimerManager:CreateTimer(self, "CheckBpOpenTimer", 1000, self.OnTimerUpdate, nil, 1)
  end
  self.Btn_Pass.OnClicked:Add(self, self.OnBtnClick)
end

function UMG_Pass_C:OnBtnClick()
  _G.NRCProfilerLog:NRCClickBtn(true, "BattlePassAwardMain")
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenBattlePass, nil, true)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Pass_C:OnBtnClick()")
end

function UMG_Pass_C:OnTimerUpdate()
  self.CheckBpOpenTimer:SetDuration(1000)
  local isOpen = self:CheckBpIsOpen()
  local isBan = self.OpenLevel > _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  local isShow = not isBan and isOpen and not NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_BP)
  if self.preState == isOpen then
    return
  end
  self:SetVisibility(isShow and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  if self.lastOpenState ~= isShow then
    Log.Debug("\230\181\139\232\175\149\230\151\165\229\191\151pass icon2\239\188\154\229\189\147\229\137\141\230\180\187\229\138\168\229\188\128\229\144\175\231\138\182\230\128\129", isOpen, "isBan:", isBan, isShow)
  end
  self.lastOpenState = isShow
  self.prState = isOpen
end

function UMG_Pass_C:CheckBpIsOpen()
  local curTime = self:GetCurServerTime()
  local timeCfgs = self.CacheTimeCfgs
  for _, cfg in ipairs(timeCfgs) do
    if curTime >= cfg.open_time and curTime <= cfg.close_time then
      return true, cfg.id
    end
  end
  return false
end

function UMG_Pass_C:GetCurServerTime()
  return _G.ZoneServer:GetServerTime() / 1000
end

function UMG_Pass_C:ConvertToTimeSeconds(dateTimeString)
  local year, month, day, hour, min, sec = dateTimeString:match("(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)")
  local local_time = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = tonumber(hour),
    min = tonumber(min),
    sec = tonumber(sec)
  })
  return local_time
end

return UMG_Pass_C
