require("UnLua")
local MapPetTrigger = Class("")

function MapPetTrigger:OnOverlap(OtherActor)
  if not OtherActor:IsA(UE.ANPCBaseCharacter) then
    return
  end
  local NPC = OtherActor.sceneCharacter
  if not NPC then
    return
  end
  if self.ConfIDs:Contains(NPC.serverData.npc_base.npc_cfg_id) then
    self:ReportState(NPC, true)
  end
end

function MapPetTrigger:OnEndOverlap(OtherActor)
  if not OtherActor:IsA(UE.ANPCBaseCharacter) then
    return
  end
  local NPC = OtherActor.sceneCharacter
  if not NPC then
    return
  end
  if self.ConfIDs:Contains(NPC.serverData.npc_base.npc_cfg_id) then
    self:ReportState(NPC, false)
  end
end

function MapPetTrigger:ReportState(npc, is_enter)
  Log.PrintScreenMsg("MapPetTrigger:ReportState %s, is_enter: %s", npc.config.name, tostring(is_enter))
  npc:ReportPosition()
  local req = _G.ProtoMessage:newZoneClientReportNpcForAreaReq()
  table.insert(req.npc_obj_id, npc:GetServerId())
  req.is_enter = is_enter
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_REPORT_NPC_FOR_AREA_REQ, req)
end

return MapPetTrigger
