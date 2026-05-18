local ShowHideBase = require("NewRoco.Modules.Core.NPC.ShowHide.ShowHideBase")
local Base = ShowHideBase
local BattlePvpRankMatchingShowHide = Base:Extend("BattlePvpRankMatchingShowHide")

function BattlePvpRankMatchingShowHide:Ctor()
  Base.Ctor(self)
end

function BattlePvpRankMatchingShowHide:GetReason()
  return 5
end

function BattlePvpRankMatchingShowHide:StartHide()
  local PvpId = _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.GetCurMatchPvpId)
  local pvpConf = _G.DataConfigManager:GetPvpConf(PvpId)
  local areaId = pvpConf.hide_npc_area
  if not areaId or 0 == areaId then
    return false
  end
  local AreaConf = _G.DataConfigManager:GetAreaConf(areaId)
  if AreaConf then
    self.Region = NewObject(UE.URegion, _G.UE4Helper.GetCurrentWorld())
    self.Region_Ref = UnLua.Ref(self.Region)
    local Verts = UE4.TArray(UE4.FVector2D)
    for _, point in ipairs(AreaConf.pos) do
      if point.position_xyz and #point.position_xyz >= 2 then
        Verts:Add(UE4.FVector2D(point.position_xyz[1], point.position_xyz[2]))
      end
    end
    self.Region:SetMainRegionVerts(Verts)
  else
    self.Region = nil
  end
  return true
end

function BattlePvpRankMatchingShowHide:CheckShouldHide(npc)
  if 1 ~= npc.config.can_hide_in_pvp then
    return false
  end
  if not self.Region or not UE4.UObject.IsValid(self.Region) then
    return false
  end
  if not self.Region:ContainPoint(npc:GetActorLocation()) then
    return false
  end
  if npc.AIComponent then
    Log.PrintScreenMsg("\229\129\156\230\142\137AI %s", npc.config.name)
    npc.AIComponent:ForceLockForReason(true, false, AIDefines.LockReason.RANK_MATCH)
  end
  _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.AddHideNpcViews, npc.viewObj)
  return true
end

function BattlePvpRankMatchingShowHide:EndHide()
  Base.EndHide(self)
end

function BattlePvpRankMatchingShowHide:StartShow()
  self.Region = nil
  self.Region_Ref = nil
  return true
end

function BattlePvpRankMatchingShowHide:CheckShouldShow(npc)
  if npc.AIComponent then
    npc.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.RANK_MATCH)
  end
  _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.RemoveHideNpcViews, npc.viewObj)
  return true
end

function BattlePvpRankMatchingShowHide:EndShow()
  Base.EndShow(self)
end

function BattlePvpRankMatchingShowHide:ShouldPauseTick()
  return false
end

return BattlePvpRankMatchingShowHide
