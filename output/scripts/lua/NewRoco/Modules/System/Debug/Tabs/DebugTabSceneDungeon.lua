local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabSceneDungeon = Base:Extend("DebugTabSceneDungeon")

function DebugTabSceneDungeon:Ctor(...)
  Base.Ctor(self, ...)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self._OnOpenDungeonRsp)
end

function DebugTabSceneDungeon:SetupTabs()
  local DungeonConfs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.DUNGEON_CONF):GetAllDatas()
  for _, DungeonConf in pairs(DungeonConfs) do
    local SceneResID = _G.DataConfigManager:GetSceneConf(DungeonConf.scene_id).scene_res_id
    if _G.DataConfigManager:GetSceneResConf(SceneResID).is_unused then
    elseif self:DungeonMatch(self.tabName, DungeonConf.region_name) then
      local DungeonName = DungeonConf.name or "\230\156\170\231\159\165\229\137\175\230\156\172:" .. DungeonConf.id
      self:Add(string.format([[
%d
%s]], DungeonConf.id, DungeonName), function(Owner, name, panel)
        panel:DoClose()
        self:_EnableOrDisablePlayerInputState(false)
        local open_dungeon_req = ProtoMessage.newZoneGmOpenDungeonReq()
        open_dungeon_req.dungeon_cfg_id = DungeonConf.id
        Log.Warning("GM Open Dungeon:", open_dungeon_req.dungeon_cfg_id, DungeonName)
        ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPEN_DUNGEON_REQ, open_dungeon_req, self, self._OnOpenDungeonRsp, true)
        self.waitingRsp = true
      end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\229\188\128\229\144\175\229\137\175\230\156\172")
    end
  end
end

function DebugTabSceneDungeon:DummyRsp()
end

function DebugTabSceneDungeon:_EnableOrDisablePlayerInputState(enable)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if nil == localPlayer then
    return
  end
  localPlayer.inputComponent:SetInputEnable(self, enable, "GM")
  localPlayer.inputComponent:SetCameraControlEnable(self, enable)
end

function DebugTabSceneDungeon:_OnOpenDungeonRsp(_)
  if self.waitingRsp then
    self:_EnableOrDisablePlayerInputState(true)
    self.waitingRsp = false
  end
end

function DebugTabSceneDungeon:DungeonMatch(ParentString, SubString)
  if "\229\133\182\229\174\131\229\137\175\230\156\172" == ParentString and nil == SubString then
    return true
  end
  if nil == ParentString or nil == SubString then
    return false
  end
  if "\229\133\182\229\174\131\229\137\175\230\156\172" == ParentString and not table.contains(self.module.data.DungeonTypes, SubString) then
    return true
  end
  return string.find(ParentString, SubString)
end

return DebugTabSceneDungeon
