local MainUIModuleEnum = require("NewRoco.Modules.System.MainUI.MainUIModuleEnum")
local ShowHideBase = require("NewRoco.Modules.Core.NPC.ShowHide.ShowHideBase")
local Base = ShowHideBase
local LegendaryBattleHide = Base:Extend("LegendaryBattleHide")

function LegendaryBattleHide:Ctor()
  Base.Ctor(self)
  local Conf = _G.DataConfigManager:GetGlobalConfig("legendary_battle_entrence_range")
  local R = Conf and Conf.num or 1000 or 1000
  self.Radius = R * R
end

function LegendaryBattleHide:GetReason()
  return 21
end

function LegendaryBattleHide:ShouldPauseFind()
  return true
end

function LegendaryBattleHide:ShouldPauseTick()
  return true
end

function LegendaryBattleHide:StartHide()
  local curLBMatchStage, matchInfo = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetCurMatchInfo)
  local matchActorId = matchInfo and matchInfo.ActorId
  if matchActorId then
    self.CenterActor = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, matchActorId)
  end
  if not self.CenterActor then
    self.CenterActor = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  end
  if self.CenterActor then
    self.CenterLocation = self.CenterActor:GetActorLocation()
  end
  return true
end

function LegendaryBattleHide:CheckShouldHide(npc)
  if npc == self.CenterActor then
    self:ToggleHUD(npc, false)
    return false
  end
  if not npc then
    return false
  end
  if not npc.config then
    return false
  end
  local npcPos = npc:GetActorLocation()
  if not npcPos then
    Log.Error("CheckShouldHide\229\156\168\232\142\183\229\143\150Location\231\154\132\230\151\182\229\128\153\231\169\186\228\186\134!!!!!!!!!!!!!")
    if npc and npc.serverData and npc.serverData.base then
      Log.Error("\230\156\137\233\151\174\233\162\152\231\154\132NPC\230\152\175: ", npc.serverData.base.name, npc.serverData.base.actor_id)
    end
    return false
  end
  local Dist = UE.FVector.DistSquared(npcPos, self.CenterLocation)
  if Dist > self.Radius then
    return false
  end
  self:ToggleHUD(npc, false)
  if npc.config.genre == _G.Enum.ClientNpcType.CNT_LEGENDARY_SPIRIT then
    return false
  end
  if npc:IsLocal() then
    return false
  end
  return true
end

function LegendaryBattleHide:EndHide()
  self.CenterActor = nil
  Base.EndHide(self)
end

function LegendaryBattleHide:StartShow()
  return true
end

function LegendaryBattleHide:CheckShouldShow(npc)
  self:ToggleHUD(npc, true)
  return true
end

function LegendaryBattleHide:EndShow()
  self.CenterLocation = nil
  Base.EndShow(self)
end

function LegendaryBattleHide:ToggleHUD(npc, enable)
  local HUD = npc and npc.PetHUDComponent
  if HUD then
    HUD:SetRenderStatus(enable, MainUIModuleEnum.DisableHudOpSource.Dialogue)
  end
end

return LegendaryBattleHide
