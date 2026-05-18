local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.MagicAbility.CastMagicAbilityBase")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local CastMagicTransform = Base:Extend("CastMagicTransform")

function CastMagicTransform:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self._abilityId = AbilityID.MAGIC_TRANSFORM
  self.SkillTime = 0
end

function CastMagicTransform:CastMagic(...)
  self.SkillTime = 0
  Log.Debug("CastMagicTransform")
  self.hasOnMozhangDisappear = false
  local helper = AbilityHelperManager.GetHelper(self._abilityId)
  self.buff = self.caster.buffComponent:GetBuff(helper:GetBuffName())
  if not self.buff then
    Log.Error("No Buff")
    self:Finish()
    return
  end
  self:PlayAnimAndSkill()
end

function CastMagicTransform:Interrupt()
  self:Recover()
end

function CastMagicTransform:Recover()
  if self.buff == nil then
    self.buff = AbilityHelperManager.GetHelper(self._abilityId):GetBuff(self.caster)
  end
  if self.buff == nil then
    return
  end
  if self.buff and not self.buff.is_magic_cancel then
    self.buff:GetController().PlayerCameraManager:Reset()
  end
  if self.buff.magicInfo.AudioId then
    _G.NRCAudioManager:ReleaseSession(self.buff.magicInfo.AudioId, true, "MagicTransformAbility")
  end
  if not self.caster.isLocal then
    self.caster.viewObj:SetAimMode(false, 0)
  else
    self.caster:SendEvent(PlayerModuleEvent.ON_INTERRUPT_THROW)
    self.caster.viewObj:ChangeThrowAnim(0)
  end
  self:Finish()
end

function CastMagicTransform:PlayAnimAndSkill()
  _G.UpdateManager:Register(self)
  if self.buff.CastSelf then
    self.Anim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicTransformCastSelf")
  else
    self.Anim = self.caster.viewObj:GetAnimComponent():GetAnimSequenceByName("MagicTransformCast")
  end
  local AnimInstance = self.caster.viewObj.Mesh:GetAnimInstance()
  local ThrowAnimInstance = AnimInstance:GetLinkedAnimGraphInstanceByTag("Locomotion"):GetLinkedAnimGraphInstanceByTag("Aim")
  if nil == ThrowAnimInstance then
    AnimInstance:PlaySlotAnimation(self.Anim, "UpperBody", 0, 0)
  else
    ThrowAnimInstance:PlaySlotAnimation(self.Anim, "UpperBody", 0, 0)
  end
end

function CastMagicTransform:OnTick(DeltaTime)
  self.SkillTime = self.SkillTime + DeltaTime
  if self.SkillTime > 0.5 and not self.hasOnMozhangDisappear then
    self.hasOnMozhangDisappear = true
    self:OnMozhangDisappear()
    if self.buff and self.buff.magicInfo.AudioId then
      _G.NRCAudioManager:ReleaseSession(self.buff.magicInfo.AudioId, true, "MagicTransformAbility")
    end
    return
  end
  if self.SkillTime > 0.67 then
    if self.buff.CastSelf and self.caster.isLocal then
      local canApplyRide, _, _ = self.caster.statusComponent:PreApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
      local canApplyTrans, _, _ = self.caster.statusComponent:PreApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM)
      if not canApplyRide or not canApplyTrans then
        self.buff.CastSelf = false
        self.buff:SetDisableReason("Error_Code_50740")
      end
    end
    self:SendTrasnformReq(self.buff.CastPlayerId, self.buff.LastEnable or self.buff.CastSelf, self.buff.DisableReason)
    self:Finish()
    return
  end
end

function CastMagicTransform:SendTrasnformReq(ID, LastEnable, DisableReason)
  if not self.caster.isLocal then
    return
  end
  if not ID or not LastEnable then
    if DisableReason then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText[DisableReason])
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.TryCastMagic_TargetNotFound)
    end
    return
  end
  local req = ProtoMessage:newZoneSceneEndThrowReq()
  req.throw_type = ProtoEnum.ThrowType.THROW_MAGIC
  if not self.gid then
    local bagItemWind = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, 100728)
    self.gid = bagItemWind and bagItemWind.gid
    self.item_id = bagItemWind and bagItemWind.id
  end
  req.gid = self.gid
  req.throw_magic_info.target_avatar_ids = {ID}
  req.item_conf_id = self.item_id or 0
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, ID)
  if player then
    req.throw_magic_info.target_avatar_uins = {
      player.serverData.base.logic_id
    }
  end
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, req, self, self.OnEndThrowRsp, false, true)
end

function CastMagicTransform:OnEndThrowRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    return
  end
  local Key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
  local ErrorText = _G.LuaText[Key]
  if ErrorText then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, ErrorText)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "Error_Code_" .. rsp.ret_info.ret_code)
end

function CastMagicTransform:Finish(Force)
  _G.UpdateManager:UnRegister(self)
  Base.Finish(self, Force)
end

return CastMagicTransform
