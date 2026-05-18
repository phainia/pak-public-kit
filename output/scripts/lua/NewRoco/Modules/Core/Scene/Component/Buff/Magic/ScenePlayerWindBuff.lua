local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ScenePlayerWindBuff = Base:Extend("ScenePlayerWindBuff")
local WindClassPath = "/Game/NewRoco/Modules/Core/Scene/BP_RocoWindVolume.BP_RocoWindVolume"

function ScenePlayerWindBuff:OnBegin()
  Base.OnBegin(self)
  self.Actions = nil
  local bagItemWind = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, 100702)
  self.gid = bagItemWind and bagItemWind.gid
  self.item_id = bagItemWind and bagItemWind.id
end

function ScenePlayerWindBuff:OnUpdate(deltaTime)
end

function ScenePlayerWindBuff:AddWind(pos, radius, lifeTime, windAcc, level, progress)
  local req = ProtoMessage:newZoneSceneEndThrowReq()
  req.throw_type = ProtoEnum.ThrowType.THROW_MAGIC
  req.params[1] = math.ceil(radius)
  req.params[2] = math.ceil(lifeTime)
  req.params[3] = math.ceil(windAcc)
  req.params[4] = 0
  req.params[5] = level or 0
  req.params[6] = math.ceil(progress * 100)
  if not self.gid then
    local bagItemWind = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, 100702)
    self.gid = bagItemWind and bagItemWind.gid
    self.item_id = bagItemWind and bagItemWind.id
  end
  req.gid = self.gid
  req.item_conf_id = self.item_id
  req.end_throw_pos = SceneUtils.ClientPos2ServerPos(pos)
  local RelativePos = SceneUtils.ConvertAbsoluteToRelative(pos)
  local Actions, TargetInfos
  Actions, TargetInfos = ThrowUtils.GatherMagicActions(nil, RelativePos, 21, 1, 300)
  if Actions and TargetInfos then
    self.Actions = Actions
    req.throw_target_npc_infos = TargetInfos
  else
    self.Actions = {}
  end
  req.throw_effect = ProtoEnum.ThrowEffect.TRIG_MAGIC_INTERACT
  req.throw_magic_info.strength_level = level
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, req, self, self.OnEndThrowRsp, false, true)
end

function ScenePlayerWindBuff:OnEndThrowRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("ScenePlayerWindBuff:OnEndThrowRsp", rsp.ret_info.ret_code)
  end
  if self.Actions then
    for _, action in ipairs(self.Actions) do
      action:OnSubmit(rsp)
    end
    table.clear(self.Actions)
  end
end

return ScenePlayerWindBuff
