local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local CinematicAutomation = require("Profiler.PerfCat.Cinematic.CinematicAutomation")
local Base = DebugTabBase
local DebugTabCinematicProfiler = Base:Extend("DebugTabCinematicProfiler")

function DebugTabCinematicProfiler:Ctor()
  Base.Ctor(self)
  self.bCinematic = true
  self.bHideDebug = true
  self.Quality = "high"
  self.OverdrawMode = false
  self.BigWorld = false
end

function DebugTabCinematicProfiler:SetupTabs()
  local SEQUENCE_CONFS = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SEQUENCE_CONF):GetAllDatas()
  for k, v in pairs(SEQUENCE_CONFS) do
    local X = v.act_x
    local Y = v.act_y
    local Z = v.act_z
    if X + Y + Z > 1000 then
      self:Add(string.format([[
%d
%s]], v.id, v.editor_name), function(caller, name, panel)
        self:OnPlayButtonClicked(v, name, panel)
      end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\231\156\139\229\138\168\231\148\187")
    end
  end
end

function DebugTabCinematicProfiler:SetQualityHigh(caller, name, panel)
  self.Quality = "high"
  self:ShowTips("\231\148\187\232\180\168: \233\171\152")
end

function DebugTabCinematicProfiler:SetQualityMedium(caller, name, panel)
  self.Quality = "medium"
  self:ShowTips("\231\148\187\232\180\168: \228\184\173")
end

function DebugTabCinematicProfiler:SetQualityLow(caller, name, panel)
  self.Quality = "low"
  self:ShowTips("\231\148\187\232\180\168: \228\189\142")
end

function DebugTabCinematicProfiler:SetLitMode(caller, name, panel)
  self.OverdrawMode = false
  self:ShowTips("Overdraw\230\168\161\229\188\143: NO")
end

function DebugTabCinematicProfiler:SetOverdrawMode(caller, name, panel)
  self.OverdrawMode = true
  self:ShowTips("Overdraw\230\168\161\229\188\143: YES")
end

function DebugTabCinematicProfiler:SetBigworld(caller, name, panel)
  self.Bigworld = true
  self:ShowTips("\231\142\175\229\162\131: \229\164\167\228\184\150\231\149\140")
end

function DebugTabCinematicProfiler:SetMinimal(caller, name, panel)
  self.Bigworld = false
  self:ShowTips("\231\142\175\229\162\131: Minimal")
end

function DebugTabCinematicProfiler:StartWithSavedConfig(caller, name, panel)
  self:ClosePanel()
  CinematicAutomation:StartAutomationWithSavedConfig()
end

function DebugTabCinematicProfiler:StartWithWhiteList(name, panel)
  if panel then
    local input_str = panel:GetInputString()
    if input_str and "" ~= input_str then
      self:ClosePanel()
      local Temp = CinematicAutomation()
      local Config = Temp:LoadConfig()
      Config.white_list = string.split(input_str, ",")
      Temp:StartAutomationWithConfig(Config)
    end
  end
end

function DebugTabCinematicProfiler:OnPlayButtonClicked(sequence_conf, name, panel)
  self:ClosePanel()
  local Temp = CinematicAutomation()
  local Config = Temp:LoadConfig()
  Config.white_list = {
    sequence_conf.id
  }
  Config.overdraw_mode = self.OverdrawMode
  Config.image_quality = self.Quality
  Temp:StartAutomationWithConfig(Config)
end

function DebugTabCinematicProfiler:OnPlayAllClicked(name, panel)
  self:ClosePanel()
  local Temp = CinematicAutomation()
  local Config = Temp:LoadDefaultConfig()
  Config.white_list = {}
  Config.overdraw_mode = self.OverdrawMode
  Config.image_quality = self.Quality
  Temp:StartAutomationWithConfig(Config)
end

return DebugTabCinematicProfiler
