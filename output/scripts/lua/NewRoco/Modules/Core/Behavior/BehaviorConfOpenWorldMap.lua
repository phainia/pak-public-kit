local BehaviorConfBase = require("NewRoco.Modules.Core.Behavior.BehaviorConfBase")
local Base = BehaviorConfBase
local BehaviorConfOpenWorldMap = Base:Extend("BehaviorConfOpenWorldMap")

function BehaviorConfOpenWorldMap:Ctor(Type, Param)
  Base.Ctor(self, Type, Param)
end

function BehaviorConfOpenWorldMap:Check()
  local worldMapConfigId = tonumber(self.Param)
  local worldMapConfig = _G.DataConfigManager:GetWorldMapConf(worldMapConfigId)
  if worldMapConfig.unexplored_in_map == false or false == worldMapConfig.explored_in_map or false == worldMapConfig.unfinished_in_map then
    self:Execute()
  end
end

function BehaviorConfOpenWorldMap:Execute()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  local npcinfo = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, tonumber(self.Param))
  if nil == npcinfo then
    return
  end
  local npcPos = UE4.FVector2D(npcinfo.npc_pos.x, npcinfo.npc_pos.y)
  if npcinfo.status == _G.ProtoEnum.LockStatus.ENUM.LOCKED then
    local showTip = _G.DataConfigManager:GetLocalizationConf("Tips_Behavior_Item")
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, showTip.msg)
  end
  local panelDict = _G.NRCPanelManager:GetPanelDict()
  local hasDialoguePanel = false
  local hasLevelUpRewardsPanel = false
  for k, v in pairs(panelDict) do
    if "DialogueModule" == k and 0 ~= #v.DialoguePanel then
      hasDialoguePanel = true
    end
    if "LevelUpUIModule" == k and 0 ~= #v.LevelUpRewards then
      hasLevelUpRewardsPanel = true
    end
  end
  if not hasDialoguePanel and not hasLevelUpRewardsPanel then
    for k, v in pairs(panelDict) do
      if "MainUIModule" ~= k and "LoginModule" ~= k and "LoadingUIModule" ~= k and "DebugModule" ~= k and "BigMapModule" ~= k and "TaskModule" ~= k then
        local module = _G.NRCModuleManager:GetModule(k)
        for k, val in pairs(v) do
          if not (#val > 0) or val[1].panelName == "UMG_TopHUD" or nil ~= val[1].panelName then
          end
        end
      end
    end
  end
  local range = _G.DataConfigManager:GetGlobalConfigNumByKeyType("item_acquire_jump_distance", _G.DataConfigManager.ConfigTableId.NPC_GLOBAL_CONFIG, 5000)
  local distance = self:DistSquared2D(player:GetActorLocationFrameCache(), npcPos)
  if distance > range ^ 2 and not hasDialoguePanel and not hasLevelUpRewardsPanel then
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.BehaviorOpenWorldMap, npcinfo)
  end
end

function BehaviorConfOpenWorldMap:DistSquared2D(a, b)
  if not a or not b then
    return math.maxinteger
  end
  local X = (a.X or a.x) - (b.X or b.x)
  local Y = (a.Y or a.y) - (b.Y or b.y)
  return X * X + Y * Y
end

return BehaviorConfOpenWorldMap
