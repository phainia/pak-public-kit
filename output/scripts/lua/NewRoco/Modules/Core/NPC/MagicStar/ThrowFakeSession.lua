local Base = require("NewRoco.Modules.Core.NPC.ThrowSessionBase")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowFakeSession = Base:Extend("ThrowStarSession")

function ThrowFakeSession:Ctor()
  Base.Ctor(self)
end

function ThrowFakeSession:BeginThrow(npcIndex)
  self.npcIndex = npcIndex
  local req = ProtoMessage:newZoneSceneBeginThrowReq()
  local ItemInfo = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetCurEquipItemInfo)
  req.gid = ItemInfo.gid
  req.throw_id = self.SeqID
  req.throw_type = ProtoEnum.ThrowType.THROW_BAGITEM
  req.item_conf_id = ItemInfo.id or 0
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_BEGIN_THROW_REQ, req, self, self.OnBeginThrowRsp, false, true)
end

function ThrowFakeSession:OnBeginThrowRsp(rsp)
  local endThrowReq = ProtoMessage:newZoneSceneEndThrowReq()
  endThrowReq.throw_type = ProtoEnum.ThrowType.THROW_BAGITEM
  local ItemInfo = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetCurEquipItemInfo)
  endThrowReq.gid = ItemInfo.gid
  endThrowReq.throw_id = self.SeqID
  endThrowReq.fly_distance = 100
  endThrowReq.end_throw_pos = nil
  endThrowReq.throw_effect = ProtoEnum.ThrowEffect.CATCH
  endThrowReq.item_conf_id = ItemInfo.id or 0
  local targetInfo = ProtoMessage:newThrowTargetNpcInfo()
  local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
  local npcNum = 0
  for i, npc in pairs(npcs) do
    if npc.viewObj and npc.viewObj.sceneCharacter and npc.viewObj.sceneCharacter.config.throwing_interact_type == Enum.THROWING_INTERACT_TYPE.TIT_WILD_PET then
      npcNum = npcNum + 1
    end
  end
  if 0 == npcNum then
    Log.Error("\230\178\161\230\156\137\229\143\175\228\187\165\230\141\149\230\141\137\231\154\132\231\178\190\231\129\181\228\186\134\230\141\143\239\188\140\229\142\187\229\136\171\231\154\132\229\156\176\230\150\185\231\156\139\231\156\139\229\144\167")
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, endThrowReq, self, self.EndThrow, false, true)
    return
  end
  self.npcIndex = self.npcIndex % npcNum
  for i, npc in pairs(npcs) do
    if npc.viewObj and npc.viewObj.sceneCharacter and npc.viewObj.sceneCharacter.config.throwing_interact_type == Enum.THROWING_INTERACT_TYPE.TIT_WILD_PET then
      self.npcIndex = self.npcIndex - 1
      if self.npcIndex <= 0 then
        targetInfo.npc_id = npc.viewObj.sceneCharacter.serverData.base.actor_id
        targetInfo.npc_conf_id = npc.viewObj.sceneCharacter.config.id
        targetInfo.npc_ai_status = ProtoEnum.ThrowTargetNpcAIStatus.DETECTED_AVATAR
        targetInfo.npc_ai_behavior = npc.AIComponent and npc.AIComponent.battleState or 0
        break
      end
    end
  end
  table.insert(endThrowReq.throw_target_npc_infos, targetInfo)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, endThrowReq, self, self.EndThrow, false, true)
end

function ThrowFakeSession:EndThrow(rsp)
  if 0 ~= rsp.ret_info.ret_code then
  else
  end
end

return ThrowFakeSession
