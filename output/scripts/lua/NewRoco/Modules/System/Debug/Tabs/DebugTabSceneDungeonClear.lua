local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabSceneDungeonClear = Base:Extend("DebugTabSceneDungeonClear")

function DebugTabSceneDungeonClear:SetupTabs()
  local dgnCfgs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.DUNGEON_CONF):GetAllDatas()
  for _, dgnCfg in pairs(dgnCfgs) do
    local SceneResID = _G.DataConfigManager:GetSceneConf(dgnCfg.scene_id).scene_res_id
    if _G.DataConfigManager:GetSceneResConf(SceneResID).is_unused then
    else
      self:Add(string.format("\230\184\133\233\153\164\229\137\175\230\156\172\232\191\155\229\186\166\n%d\n%s", dgnCfg.id, dgnCfg.name), function(Owner, name, panel)
        panel:DoClose()
        local req = ProtoMessage:newZoneClearDungeonReq()
        req.dungeon_cfg_id = dgnCfg.id
        _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CLEAR_DUNGEON_REQ, req, self, self.DummyRsp, true)
      end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\184\133\233\153\164\229\137\175\230\156\172\232\191\155\229\186\166")
    end
  end
end

function DebugTabSceneDungeonClear:DummyRsp()
end

return DebugTabSceneDungeonClear
