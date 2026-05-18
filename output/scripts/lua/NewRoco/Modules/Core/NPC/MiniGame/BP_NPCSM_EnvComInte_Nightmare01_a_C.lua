local LockWeatherReason = require("NewRoco.Modules.System.EnvSystem.LockWeatherReason")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCSM_EnvComInte_Nightmare01_a_C = Base:Extend("BP_NPCSM_EnvComInte_Nightmare01_a_C")
local OpenNightmareEndPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_NightMare_End.G6_Scene_NightMare_End_C"

function BP_NPCSM_EnvComInte_Nightmare01_a_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  _G.NRCEventCenter:RegisterEvent("BP_NPCSM_EnvComInte_Nightmare01_a_C", self, MiniGameModuleEvent.Start, self.MiniGameStart)
  _G.NRCEventCenter:RegisterEvent("BP_NPCSM_EnvComInte_Nightmare01_a_C", self, MiniGameModuleEvent.End, self.MiniGameEnd)
  _G.NRCEventCenter:RegisterEvent("BP_NPCSM_EnvComInte_Nightmare01_a_C", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:OnFirstVisible()
  Base.OnFirstVisible(self)
  self:OpenFX()
  self:PreloadSkill()
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:PreloadSkill()
  _G.NRCResourceManager:LoadResAsync(self, OpenNightmareEndPath, PriorityEnum.Active_World_NPC_Nightmare, 0, self.OnPreloadFinish, self.OnPreloadFailed)
  self.bPreloadSkill = true
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:OnPreloadFinish(resRequest, skillObj)
  if not self.RocoSkill and self.OpenNightmareEndObject then
    return
  end
  if skillObj then
    self.OpenNightmareEndObject = UnLua.Ref(skillObj)
  end
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:OnPreloadFailed()
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:MiniGameStart()
  if not self.WeatherType then
    local MiniGameModule = _G.NRCModuleManager:GetModule("MiniGameModule")
    local NightmareType = MiniGameModule:GetNightmareType()
    if NightmareType then
      if NightmareType == Enum.MiniGameType.MINIGAME_NIGHTMARE_SPACE then
        self.WeatherType = Enum.WeatherType.WT_NIGHTMARE
      elseif NightmareType == Enum.MiniGameType.MINIGAME_NIGHTMARE_SPACE_SP then
        self.WeatherType = Enum.WeatherType.WT_NIGHTMARE_SP
      end
    end
  end
  local NeedPlayNightmareAction = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.NeedPlayNightmareAction)
  local bInNightmare = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare)
  if not NeedPlayNightmareAction and bInNightmare then
    if self.resourceLoaded then
      self:OpenLoopFX()
    end
    _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, self.WeatherType, LockWeatherReason.MiniGameNightmare)
  end
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:OpenFX()
  if not _G.MiniGameModuleCmd then
    Log.Error("BP_NPCSM_EnvComInte_Nightmare01_a_C:OpenFX  MiniGameModuleCmd is not ready")
    return
  end
  local bInNightmare = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare)
  if bInNightmare then
    if self.WeatherType then
      _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, self.WeatherType, LockWeatherReason.MiniGameNightmare)
    end
    self:OpenLoopFX()
  end
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:MiniGameEnd()
  if self.resourceLoaded then
    self:CloseFx()
  end
  _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:Recycle()
  if self.resourceLoaded then
    self:CloseFx()
  end
  _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
  Base.Recycle(self)
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:OnReconnect()
  if not _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare) then
    if self.resourceLoaded then
      self:CloseFx()
    end
    _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
  end
end

function BP_NPCSM_EnvComInte_Nightmare01_a_C:ReceiveDestroyed()
  if self.resourceLoaded then
    self:CloseFx()
  end
  _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.LockWeather, Enum.WeatherType.WT_NONE, LockWeatherReason.MiniGameNightmare)
  _G.NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.End, self.MiniGameEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.Start, self.MiniGameStart)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
  self.OpenNightmareEndObject = nil
end

return BP_NPCSM_EnvComInte_Nightmare01_a_C
