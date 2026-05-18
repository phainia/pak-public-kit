local Base = require("NewRoco.Modules.System.MainUI.Res.UMG_Hud_Base")
local SceneEnum = require("NewRoco.Modules.Core.Scene.Common.SceneEnum")
local NpcAction = SceneEnum.PerceptionHudType
local DeviceUtils = require("NewRoco.Modules.Core.App.DeviceUtils")
local UMG_Hud_Perception_C = Base:Extend("UMG_Hud_Perception_C")

function UMG_Hud_Perception_C:OnConstruct()
  self.isPlayingAnim = false
  self.CurType = NpcAction.None
  self.sceneNpc = nil
  self.Owner = nil
  self.updateNumber = 0
  self.updateGap = 5
  self.IsAddUpdate = true
end

function UMG_Hud_Perception_C:OnDestruct()
  self:RegisterUpdate(false)
  self.sceneNpc = nil
  self.target = nil
  self.Owner = nil
end

function UMG_Hud_Perception_C:OnEnable(hudLoad, npc, type, owner, target)
  if hudLoad then
    self.IsSceneHead = true
    self:InitData(npc, type, owner, target)
  end
end

function UMG_Hud_Perception_C:RegisterUpdate(register)
  if register then
    if not self.IsAddUpdate then
      self.IsAddUpdate = true
      _G.UpdateManager:Register(self)
    end
  elseif self.IsAddUpdate then
    self.IsAddUpdate = false
    _G.UpdateManager:UnRegister(self)
  end
end

function UMG_Hud_Perception_C:PointToTarget(target)
  if target then
    self.playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
    self:RegisterUpdate(true)
    self.TargetArrow:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.playerController = nil
    self.TargetAngle = nil
    self:RegisterUpdate(false)
    self.TargetArrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.updateNumber = 0
  self.target = target
end

function UMG_Hud_Perception_C:TransformAngle(angle)
  while angle > 180 or angle < -180 do
    if angle > 180 then
      angle = angle - 360
    else
      angle = angle + 360
    end
  end
  return angle
end

local TargetScreenPos = UE.FVector2D()
local SelfScreenPos = UE.FVector2D()

function UMG_Hud_Perception_C:OnTick(deltaTime)
  if self.updateNumber > self.updateGap then
    self.updateNumber = 0
    if self.target and self.sceneNpc then
      local widgetComp = self.sceneNpc.viewObj.HeadWidget
      if not widgetComp then
        return
      end
      local targetPos = self.target:GetActorLocation()
      local myselfPos = widgetComp:Abs_K2_GetComponentLocation()
      local widgeSize = widgetComp:GetCurrentDrawSize()
      local scale = widgetComp:K2_GetComponentScale()
      myselfPos.Z = myselfPos.Z + widgeSize.Y * scale.Z
      UE4.UNRCStatics.Abs_ProjectWorldToScreen(self.playerController, targetPos, TargetScreenPos)
      UE4.UNRCStatics.Abs_ProjectWorldToScreen(self.playerController, myselfPos, SelfScreenPos)
      local delta = TargetScreenPos - SelfScreenPos
      local theta = math.atan(delta.Y, delta.X)
      self.TargetAngle = self:TransformAngle(math.deg(theta) - 90)
    end
  else
    self.updateNumber = self.updateNumber + 1
  end
  if self.TargetAngle and self.TargetArrow then
    local curAngle = self:TransformAngle(self.TargetArrow:GetRenderTransformAngle())
    local target = self.TargetAngle
    local reduce = target - curAngle
    local change = deltaTime * 360
    if reduce > 180 then
      target = target - 360
      reduce = target - curAngle
    elseif reduce < -180 then
      target = target + 360
      reduce = target - curAngle
    end
    if reduce < 0 then
      change = -1 * change
      change = math.max(change, reduce)
    else
      change = math.min(change, reduce)
    end
    self.TargetArrow:SetRenderTransformAngle(self:TransformAngle(curAngle + change))
  end
end

function UMG_Hud_Perception_C:InitData(npc, type, owner, target)
  self.Owner = owner
  if self:CheckCollision() then
    self.CurType = type
    self.sceneNpc = npc
    self.target = target
    self.NeedInit = true
    return
  end
  self.NeedInit = false
  self:SetType(type)
  if self.sceneNpc ~= npc then
    self.sceneNpc = npc
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MenInBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MenInBlack1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MenInBlack2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if npc.config then
      local modelConf = _G.DataConfigManager:GetModelConf(npc.config.model_conf)
      if modelConf and modelConf.small_icon then
        self.Icon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        if npc:IsPet() then
          self.Icon:SetIconPathAndMaterial(npc:GetPetbaseId(), npc.serverData.npc_base.mutation_type, npc.serverData.npc_base.glass_info)
        elseif string.find(modelConf.small_icon, "/") then
          if string.find(modelConf.small_icon, "/WorldMapNpc/Frames/") then
            self.Icon:SetIconPath(NRCUtils:FormatConfIconPath(modelConf.small_icon, _G.UIIconPath.NPCHeadIconPath))
          else
            self.Icon:SetIconPath(NRCUtils:FormatConfIconPath(modelConf.small_icon, _G.UIIconPath.HeadIconPath))
          end
        else
          self.Icon:SetIconPath(NRCUtils:FormatConfIconPath(modelConf.small_icon, _G.UIIconPath.HeadIconPath))
        end
      elseif npc.config.model_conf == 12035 then
        self.MenInBlack:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      elseif npc.config.model_conf == 12036 then
        self.MenInBlack2:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      elseif npc.config.model_conf == 12037 then
        self.MenInBlack1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      else
        self.MenInBlack2:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
    elseif npc.card then
      self.Icon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      if npc.card.petBaseConf and npc.card.petInfo then
        self.Icon:SetIconPathAndMaterial(npc.card.petBaseConf.id, npc.card.petInfo.battle_common_pet_info.mutation_type, npc.card.petInfo.battle_common_pet_info.glass_info)
      else
        self.Icon:SetIconPath(npc.card.icon)
      end
      self.Icon.Slot:SetZOrder(1)
    end
  end
  if type == NpcAction.TackAction then
    self:PlayAni(self.appear_Action)
  elseif type == NpcAction.HardAction then
    self:PlayAni(self.appear_Action)
  elseif type == NpcAction.Perceive then
    self:PlayAni(self.appear_Action_Y)
  else
    self:PlayAni(self.appear_Perceive)
  end
  if DeviceUtils.OptimizeNameLabel() then
    self.CanvasPanel_0:SetRenderOpacity(1)
  end
  self:PointToTarget(target)
end

function UMG_Hud_Perception_C:CheckCollision()
  if self.IsSceneHead and self.sceneNpc and self.sceneNpc.PetHUDComponent then
    if self.sceneNpc.PetHUDComponent.ShowPerceptionKey then
      self:Hide()
      return true
    else
      self:Show()
      if self.NeedInit then
        local npc = self.sceneNpc
        local target = self.target
        local type = self.CurType
        self.sceneNpc = nil
        self.target = nil
        self.CurType = nil
        self:InitData(npc, type, self.Owner, target)
      end
    end
  end
end

function UMG_Hud_Perception_C:PlayAni(ani)
  if DeviceUtils.OptimizeNameLabel() then
    return
  end
  if not self.isPlayingAnim then
    self.isPlayingAnim = true
    if ani == self.appear_Action or ani == self.appear_Action_Y then
      self.White:SetVisibility(UE4.ESlateVisibility.Hidden)
    elseif ani == self.appear_Perceive then
      self.White:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self:PlayAnimation(ani)
  end
end

function UMG_Hud_Perception_C:OnAnimationFinished(ani)
  if ani ~= self.alter_loop and ani ~= self.alter_loop_Y then
    self.isPlayingAnim = false
    if ani == self.appear_Action or ani == self.appear_Perceive or ani == self.appear_Action_Y then
      self.White:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if ani == self.disappear then
      if self.CurType == NpcAction.Lose then
        if self.disappearDelay then
          _G.DelayManager:CancelDelayById(self.disappearDelay)
        end
        self:LoseSelf()
      elseif self.CurType == NpcAction.TackAction then
        self:PlayAni(self.appear_Action)
      elseif self.CurType == NpcAction.HardAction then
        self:PlayAni(self.appear_Action)
      elseif self.CurType == NpcAction.Perceive then
        self:PlayAni(self.appear_Action_Y)
      else
        self:PlayAni(self.appear_Perceive)
      end
    elseif self.CurType == NpcAction.Lose then
      self:PlayAni(self.disappear)
    end
  end
end

function UMG_Hud_Perception_C:SetType(type)
  if self.CurType ~= type then
    self.CurType = type
    if type == NpcAction.TackAction then
      self.Action:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Attack:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Perceive:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Stealth:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Trace:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:StopAllAnimations()
      self:PlayAnimation(self.alter_loop, 0, 0)
    elseif type == NpcAction.HardAction then
      self.Action:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Attack:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Perceive:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Stealth:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Trace:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:StopAllAnimations()
      self:PlayAnimation(self.alter_loop, 0, 0)
    elseif type == NpcAction.Perceive then
      self.Action:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Attack:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Perceive:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Stealth:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Trace:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:StopAllAnimations()
      self:PlayAnimation(self.alter_loop_Y, 0, 0)
    else
      self:StopAllAnimations()
      if type == NpcAction.Lose then
        if self:IsVisible() then
          self:PlayAni(self.disappear)
          if self.disappearDelay then
            _G.DelayManager:CancelDelayById(self.disappearDelay)
            self.disappearDelay = nil
          end
          self.disappearDelay = _G.DelayManager:DelaySeconds(1, self.LoseSelf, self)
        else
          self:LoseSelf()
        end
      end
    end
  end
end

function UMG_Hud_Perception_C:LoseSelf()
  self:Hide()
  self.disappearDelay = nil
  if self.Owner then
    self.Owner:RemoveNpc(self.sceneNpc)
  end
end

function UMG_Hud_Perception_C:HideOnMain(hide)
  if hide then
    self:Hide()
  else
    self:Show()
  end
  if self.sceneNpc and self.sceneNpc.PetHUDComponent then
    self.sceneNpc.PetHUDComponent:ChangePerceptionKey(not hide)
  end
end

function UMG_Hud_Perception_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Hud_Perception_C:Hide()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Hud_Perception_C:GetPosition()
  if self.sceneNpc then
    return self.sceneNpc:GetActorLocation()
  end
end

function UMG_Hud_Perception_C:UpdateArrow(theta)
  self.Action:SetRenderTransformAngle(theta)
  self.Trace:SetRenderTransformAngle(theta)
  self.Perceive:SetRenderTransformAngle(theta)
end

function UMG_Hud_Perception_C:SetPosition(position)
  self.Slot:SetPosition(position)
end

return UMG_Hud_Perception_C
