local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local HiddenPluginFx = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginFx")
local HiddenPluginSkill = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginSkill")
local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenActionBase")
local FxPath_XX_Star = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/hide/NR_Hide_XX.NR_Hide_XX'"
local BPPath_XX_Star = "Blueprint'/Game/ArtRes/Effects/Particle/Res/Scene/hide/BP_Hide_XX.BP_Hide_XX_C'"
local FxPath_XX_Beam = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/hide/NR_Hide_XX_Yuan.NR_Hide_XX_Yuan'"
local BPPath_XX_Beam = "Blueprint'/Game/ArtRes/Effects/Particle/Res/Scene/hide/BP_Hide_XX_Yuan.BP_Hide_XX_Yuan_C'"
local FxPath_XX_Idle = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/hide/NR_Hide_XX_Idle.NR_Hide_XX_Idle'"
local SkillPath_XX_Idle = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_XX_Idle.Pet_Hide_XX_Idle_C'"
local HiddenActionMeteor = Base:Extend("HiddenActionMeteor")

function HiddenActionMeteor:Ctor()
  self.idleFx = HiddenPluginFx(FxPath_XX_Idle, true, true)
end

function HiddenActionMeteor:Init(comp)
  self.destroyed = false
  Base.Init(self, comp)
  self.meteorReq = nil
  self.meteorObj = nil
  self.meteorObjRef = nil
  self.beamReq = nil
  self.beamObj = nil
  self.idleFx:Init(comp.owner)
  self.star_falled = false
  if not self.owner:IsLocal() and self.owner.serverData.base.enter_scene_times > 1 then
    self.star_falled = true
  end
  self.SpawnPos = comp.owner.serverPos
end

function HiddenActionMeteor:Release()
  self.destroyed = true
  self.idleFx:Release()
  self:ReleaseMeteorObj()
  Base.Release(self)
end

function HiddenActionMeteor:OnInitialHide()
  self:SetVisibility(false)
  self:LoadMeteorObj()
end

function HiddenActionMeteor:OnHidden()
  self.SpawnPos = self.comp.owner.serverPos
  self:SetVisibility(false)
  self:LoadMeteorObj()
  self.comp:EnterHidden(AIDefines.ActionResult.Success)
end

function HiddenActionMeteor:AssureHidden(imme)
  self.idleFx:Show()
end

function HiddenActionMeteor:OnUnhidden()
  self.idleFx:UnShow()
  if self.meteorObj then
    self.meteorObj:AbortMove()
  end
  self:ReleaseMeteorObj()
  self:SetVisibility(true)
  self.comp:FinalizeHidden(AIDefines.ActionResult.Success)
end

function HiddenActionMeteor:AssureUnhidden(imme)
  self.idleFx:UnShow()
  self:ReleaseMeteorObj()
  self:SetVisibility(true)
end

function HiddenActionMeteor:EnablePinToGround()
  return false
end

function HiddenActionMeteor:SetVisibility(visible)
  if not self.owner then
    return
  end
  if visible and not self.owner:GetVisible() then
    self.owner:SetActorLocation(self.SpawnPos + UE.FVector(0, 0, 100))
  end
  self.owner:SetHidden(not visible)
  self.owner:SetCollisionDisable(not visible, 4)
end

function HiddenActionMeteor:LoadMeteorObj()
  self.owner.AIComponent:ForceLockForReason(true, false, AIDefines.LockReason.HIDDEN)
  self.meteorReq = _G.NRCResourceManager:LoadResAsync(self, BPPath_XX_Star, PriorityEnum.Passive_World_NPC_Hidden_Meteor, 60, self.LoadMeteorObjSucc, self.LoadMeteorObjFail)
end

function HiddenActionMeteor:LoadMeteorObjSucc(req, starAsset)
  local serverTrans = UE.FTransform()
  serverTrans.Translation = self.SpawnPos
  if not self.star_falled then
    self.meteorObj = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(starAsset, serverTrans, UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    self.meteorObjRef = UnLua.Ref(self.meteorObj)
    self.meteorObj.sceneCharacter = self.owner
    self.meteorObj:SplineMove(self:CalcStartPos(), self:GetRelServerPos() - UE.FVector(0, 0, 100), self, self.StarFalledDown)
  else
    self:StarFalledDown(AIDefines.ActionResult.Success)
  end
end

function HiddenActionMeteor:StarFalledDown(result)
  if not _G.AIDefines.ActionResult.Ok(result) then
    Log.Warning("HiddenActionMeteor:StarFalledDown failed", result, self.owner.config.name)
    self.owner.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.HIDDEN)
    return
  end
  self.star_falled = true
  if self.meteorObj then
    local starPos = self.meteorObj.XingXing:Abs_K2_GetComponentLocation()
    if starPos:Dist(self.SpawnPos) > 300 then
      self.SpawnPos = starPos
    end
  end
  self:PlayerDistanceCheck(true)
  self.owner.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.HIDDEN)
end

function HiddenActionMeteor:LoadMeteorObjFail(req, msg)
  Log.Error("[HiddenActionMeteor]Failed to load MeteorObj", BPPath_XX_Star)
  self.owner.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.HIDDEN)
end

function HiddenActionMeteor:ReleaseMeteorObj()
  if self.meteorObj then
    self.meteorObj:AbortMove()
    self.meteorObj:K2_DestroyActor()
    self.meteorObj = nil
  end
  self.meteorObjRef = nil
  if self.meteorReq then
    local request = self.meteorReq
    self.meteorReq = nil
    _G.NRCResourceManager:UnLoadRes(request)
  end
  if self.beamObj then
    self.beamObj:K2_DestroyActor()
    self.beamObj = nil
  end
  if self.beamReq then
    local request = self.beamReq
    self.beamReq = nil
    _G.NRCResourceManager:UnLoadRes(request)
  end
end

function HiddenActionMeteor:PlayerDistanceCheck(bInRange)
  self:SetVisibility(bInRange)
  if bInRange then
    self.idleFx:Show()
  else
    self.idleFx:UnShow()
  end
end

local StartPosHeightOffset = _G.DataConfigManager:GetNpcGlobalConfig("hd_meteor_height_offset").num
local StartPosBias = _G.DataConfigManager:GetNpcGlobalConfig("hd_meteor_width_offset").num
local StartPosWind = _G.DataConfigManager:GetNpcGlobalConfig("hd_meteot_wind_offset").num

function HiddenActionMeteor:CalcStartPos()
  local CenterPos
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local PlayerPos = player.cachePlayerTransform.Translation
    local biasDir = PlayerPos - self.owner.serverPos
    biasDir.Z = 0
    biasDir:Normalize()
    local windDir = UE4.UKismetMathLibrary.RotateAngleAxis(biasDir, 90, _G.FVectorUp)
    CenterPos = PlayerPos + biasDir * StartPosBias + windDir * StartPosWind
    if GlobalConfig.DebugLuaBTree then
      UE.UKismetSystemLibrary.Abs_DrawDebugLine(player.viewObj, PlayerPos, self.owner.serverPos, UE.FLinearColor(0, 0, 1), 20, 10)
      UE.UKismetSystemLibrary.Abs_DrawDebugLine(player.viewObj, PlayerPos, PlayerPos + biasDir * StartPosBias, UE.FLinearColor(1, 0, 0), 20, 10)
      UE.UKismetSystemLibrary.Abs_DrawDebugLine(player.viewObj, PlayerPos, PlayerPos + windDir * StartPosWind, UE.FLinearColor(1, 0, 0), 20, 10)
      UE.UKismetSystemLibrary.Abs_DrawDebugLine(player.viewObj, PlayerPos, PlayerPos + UE.FVector(0, 0, StartPosHeightOffset), UE.FLinearColor(1, 0, 0), 20, 10)
      UE.UKismetSystemLibrary.Abs_DrawDebugLine(player.viewObj, PlayerPos, CenterPos + UE.FVector(0, 0, StartPosHeightOffset), UE.FLinearColor(0, 1, 0), 20, 10)
    end
  else
    CenterPos = self.owner.serverPos
  end
  local result = CenterPos + UE.FVector(0, 0, StartPosHeightOffset)
  return SceneUtils.ConvertAbsoluteToRelative(result)
end

function HiddenActionMeteor:GetRelServerPos()
  return SceneUtils.ConvertAbsoluteToRelative(self.owner.serverPos)
end

return HiddenActionMeteor
