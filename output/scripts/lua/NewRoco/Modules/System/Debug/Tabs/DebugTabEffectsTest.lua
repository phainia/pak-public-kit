local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabEffectsTest = Base:Extend("DebugTabEffects")

function DebugTabEffectsTest:SetupTabs()
  self:Add("800001\n\231\137\185\230\149\136\228\184\147\231\148\168\229\156\186\230\153\175", self.Teleport, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabEffectsTest:Teleport(name, panel)
  panel:DoClose()
  self:_EnableOrDisablePlayerInputState(false)
  local open_dungeon_req = ProtoMessage.newZoneGmOpenDungeonReq()
  open_dungeon_req.dungeon_cfg_id = 800001
  Log.Warning("GM Open Dungeon:", open_dungeon_req.dungeon_cfg_id, "\231\137\185\230\149\136\228\184\147\231\148\168\229\156\186\230\153\175")
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPEN_DUNGEON_REQ, open_dungeon_req, self, self._OnOpenDungeonRsp, true)
end

function DebugTabEffectsTest:_EnableOrDisablePlayerInputState(enable)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if nil == localPlayer then
    return
  end
  localPlayer.inputComponent:SetInputEnable(self, enable)
  localPlayer.inputComponent:SetCameraControlEnable(self, enable)
end

function DebugTabEffectsTest:_OnOpenDungeonRsp(rsp)
  self:_EnableOrDisablePlayerInputState(true)
end

return DebugTabEffectsTest
