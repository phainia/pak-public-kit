require("UnLuaEx")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local TaskParagraphHintTimeoutConf = _G.DataConfigManager:GetTaskGlobalConfig("task_paragraph_tip", 3000)
local TaskParagraphHintTimeout = (TaskParagraphHintTimeoutConf and TaskParagraphHintTimeoutConf.num or 3000) / 1000
local UMG_TaskTips_C = _G.NRCViewBase:Extend("UMG_TaskTips_C")
local TipObjectType = TipEnum.TipObjectType

function UMG_TaskTips_C:OnConstruct()
  Log.Debug("UMG_TaskTips_C:Construct")
  self.tipsMap = {
    [TipObjectType.TaskAccept] = {
      obj = self.Task_Begin,
      ani = self.Anim,
      soundId = 1220002123,
      DispatchEvent = TaskModuleEvent.TipsTaskStart
    },
    [TipObjectType.TaskComplete] = {
      obj = self.Task_Completed,
      ani = self.completed
    },
    [TipObjectType.DungeonStateCompleted] = {
      obj = self.Dungeon_Running,
      text = self.NRCTextDungeonRunning,
      ani = self.Anim_3,
      soundId = 1391
    },
    [TipObjectType.DungeonCompleted] = {
      obj = self.Dungeon_Completed,
      text = self.NRCTextDungeonCompleted,
      ani = self.Anim_2,
      soundId = 1390,
      soundId2 = 10020002,
      DispatchEvent = TipsModuleEvent.Tips_DungeonTipShowFinish
    }
  }
  self.CurrentTip = nil
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_TaskTips_C:OnDestruct()
  Log.Debug("UMG_TaskTips_C:Destruct")
  self.CurrentTip = nil
  table.clear(self.tipsMap)
  self.tipsMap = nil
end

function UMG_TaskTips_C:SetParent(parent)
  self.ParentPanel = parent
end

function UMG_TaskTips_C:ConsumeTips(tip)
  if not self:Show(tip) then
    self.ParentPanel:ConsumeNext()
  end
end

function UMG_TaskTips_C:Show(tip)
  local inTipType = tip.tipType or TipObjectType.TaskAccept
  self.CurrentTip = self.tipsMap[inTipType]
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetRenderOpacity(1)
  self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.CurrentTip and self.CurrentTip.ani then
    if self:IsAnimationPlaying(self.CurrentTip.ani) then
      Log.Debug("[TaskFlow] Animation playing... return", UE.UObject.GetName(self.CurrentTip.ani))
      return false
    end
    if self:IsPlayingAnimation() then
      self:StopAllAnimations()
    end
  end
  local IsTaskTips = inTipType == TipObjectType.TaskAccept or inTipType == TipObjectType.TaskComplete
  if IsTaskTips and tip:GetTimeSinceCreation() > TaskParagraphHintTimeout then
    local Task = tip.source
    Log.Error("[TaskFlow]\228\187\187\229\138\161Tips\232\182\133\230\151\182\228\186\134", table.getKeyName(TipObjectType, inTipType), Task.id, tip:GetTimeSinceCreation())
    self:OnAnimationFinished(self.tipsMap[inTipType].ani)
    return true
  end
  if inTipType == TipObjectType.DungeonCompleted and not _G.DataModelMgr.PlayerDataModel:IsInDungeon() then
    self:OnAnimationFinished(self.tipsMap[inTipType].ani)
    return true
  end
  for tipsType, info in pairs(self.tipsMap) do
    info.obj:SetVisibility(tipsType == inTipType and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
    info.obj:SetRenderOpacity(tipsType == inTipType and 1 or 0)
  end
  if not self.CurrentTip then
    Log.ErrorFormat("UMG_TaskTips_C:Show \228\184\141\230\148\175\230\140\129\231\154\132tips\231\177\187\229\158\139(%d)\239\188\140\233\128\128\229\135\186", inTipType)
    self:OnAnimationFinished(self, self.Anim)
    return true
  end
  if self.CurrentTip.ani then
    self:PlayAnimation(self.CurrentTip.ani)
  else
    Log.ErrorFormat("UMG_TaskTips_C:Show \232\175\165\231\177\187\229\158\139Tips\231\137\185\230\149\136\232\181\132\230\186\144\232\191\152\230\178\161\229\129\154(%d)\239\188\140\233\128\128\229\135\186", inTipType)
    self:OnAnimationFinished(self, self.Anim)
    return true
  end
  if self.CurrentTip.soundId then
    _G.NRCAudioManager:PlaySound2DAuto(self.CurrentTip.soundId, "UMG_TaskTips_C:Show")
  end
  if self.CurrentTip.soundId2 then
    _G.NRCAudioManager:PlaySound2DAuto(self.CurrentTip.soundId2, "UMG_TaskTips_C:Show")
  end
  if IsTaskTips then
    local Info = tip.source
    local Conf = Info and _G.DataConfigManager:GetTaskConf(Info.id, true)
    local Paragraph = Conf and _G.DataConfigManager:GetParagraphConf(Conf.paragraph_id, true)
    if Paragraph then
      self.Title_Describe:SetText(Paragraph.title)
      self.Title_Describe:SetVisibility(UE.ESlateVisibility.Visible)
      self.Title_Describe_1:SetText(Paragraph.title)
      self.Title_Describe_1:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Title_Describe:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Title_Describe_1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    self.Title_Describe:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Title_Describe_1:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.CurrentTip.text then
    self.CurrentTip.text:SetText(tip.source)
  end
  return true
end

function UMG_TaskTips_C:OnAnimationFinished(Animation)
  local TargetAnim = self.CurrentTip and self.CurrentTip.ani
  if TargetAnim == Animation then
    local DispatchEventName = self.CurrentTip and self.CurrentTip.DispatchEvent or ""
    if not string.IsNilOrEmpty(DispatchEventName) then
      _G.NRCEventCenter:DispatchEvent(DispatchEventName)
    end
  end
  self.CurrentTip = nil
  self:SetRenderOpacity(0)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ParentPanel:ConsumeNext()
end

return UMG_TaskTips_C
