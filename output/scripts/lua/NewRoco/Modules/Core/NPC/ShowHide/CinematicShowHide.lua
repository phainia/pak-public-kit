local ShowHideBase = require("NewRoco.Modules.Core.NPC.ShowHide.ShowHideBase")
local Base = ShowHideBase
local CinematicShowHide = Base:Extend("CinematicShowHide")

function CinematicShowHide:Ctor()
  Base.Ctor(self)
end

function CinematicShowHide:GetReason()
  return 3
end

function CinematicShowHide:ShouldPauseFind()
  return true
end

function CinematicShowHide:ShouldPauseTick()
  return true
end

function CinematicShowHide:StartHide()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, true, UE4.EPlayerForceHiddenType.Cinematic)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player:IsInTogetherMove() and player:IsTogetherMove2P() then
    local other_player = player:GetAnotherTogetherMovePlayer()
    if other_player and other_player.viewObj then
      other_player.viewObj:SetHiddenMask(false, UE4.EPlayerForceHiddenType.Cinematic)
    end
    if other_player and other_player.hudComponent then
      other_player.hudComponent:SetHeadWidgetRenderStatus(false, _G.MainUIModuleEnum.DisableHudOpSource.Cinematic)
    end
    _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, true, UE4.EPlayerForceHiddenType.Cinematic)
  end
  local Module = _G.NRCModuleManager:GetModule("CinematicModule")
  self.SeqConf = Module.SeqConf
  if not self.SeqConf then
    return false
  end
  if 1 == self.SeqConf.is_hide_npc then
    return true
  end
  return false
end

function CinematicShowHide:CheckShouldHide(npc)
  self:ToggleHUD(npc, false)
  if 1 ~= npc.config.can_hide_in_sequence then
    return false
  end
  return true
end

function CinematicShowHide:EndHide()
end

function CinematicShowHide:StartShow()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_ALL, false, UE4.EPlayerForceHiddenType.Cinematic)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player:IsInTogetherMove() and player:IsTogetherMove2P() then
    local other_player = player:GetAnotherTogetherMovePlayer()
    if other_player and other_player.hudComponent then
      other_player.hudComponent:SetHeadWidgetRenderStatus(true, _G.MainUIModuleEnum.DisableHudOpSource.Cinematic)
    end
  end
  self.SeqConf = nil
  return true
end

function CinematicShowHide:CheckShouldShow(npc)
  self:ToggleHUD(npc, true)
  return true
end

function CinematicShowHide:EndShow()
end

function CinematicShowHide:ToggleHUD(npc, enable)
  local HUD = npc and npc.PetHUDComponent
  if HUD then
    HUD:SetVisible(enable)
  end
end

return CinematicShowHide
