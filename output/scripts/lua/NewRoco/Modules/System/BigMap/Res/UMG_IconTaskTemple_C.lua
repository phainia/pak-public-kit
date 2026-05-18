local bigMapModuleEnum = require("NewRoco.Modules.System.BigMap.BigMapModuleEnum")
local Base = require("NewRoco/Modules/System/BigMap/Res/UMG_IconTempBasic_C")
local UMG_IconTaskTemple_C = Base:Extend("UMG_IconTaskTemple_C")

function UMG_IconTaskTemple_C:OnConstruct()
end

function UMG_IconTaskTemple_C:OnDestruct()
  self.uiData = nil
end

function UMG_IconTaskTemple_C:SetData(_data)
  self.uiData = _data
end

function UMG_IconTaskTemple_C:GetData()
  return self.uiData
end

function UMG_IconTaskTemple_C:DrawFlipbook(Canvas, Flipbook, Rotation, DeltaTime)
end

function UMG_IconTaskTemple_C:PlayTraceEffect(_show)
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if self.isShowTraceEffect ~= _show then
    self.isShowTraceEffect = _show
    if _show then
      self:PlayAnimation(self.TraceStart)
    elseif self:IsAnimationPlaying(self.TraceLoop) then
      self:StopAnimation(self.TraceStart)
      self:StopAnimation(self.TraceLoop)
      self:PlayAnimation(self.TraceEnd)
    end
  end
end

function UMG_IconTaskTemple_C:OnAnimationFinished(anim)
  if anim == self.TraceStart then
    self:PlayAnimation(self.TraceLoop, 0, 0)
  end
end

function UMG_IconTaskTemple_C:ShowDiffByTaskClass(_taskConf, _taskShowType)
  if not _taskConf then
    return
  end
  local _taskClass = _taskConf.task_class
  local _taskAvatar = _taskConf.map_avatar
  if _taskClass == Enum.TaskClassType.TCT_CAMPAIGN then
    self.icon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if nil == _taskAvatar then
    self.TypeSwitcher:SetActiveWidgetIndex(0)
    if _taskShowType == bigMapModuleEnum.TaskShowType.UNDO then
      if _taskClass == Enum.TaskClassType.TCT_MAIN then
        self.icon:SetPath(UEPath.TASK_ICON_MAIN_WENHAO)
      elseif _taskClass == Enum.TaskClassType.TCT_SUB or _taskClass == Enum.TaskClassType.TCT_EVOLUTION or _taskClass == Enum.TaskClassType.TCT_CAMPAIGN then
        self.icon:SetPath(UEPath.TASK_ICON_SUB_WENHAO)
      elseif _taskClass == Enum.TaskClassType.TCT_DUNGEON or _taskClass == Enum.TaskClassType.TCT_JOURNEY then
        self.icon:SetPath(UEPath.TASK_ICON_JOURNEY_WENHAO)
      else
        self.icon:SetPath(UEPath.TASK_ICON_WENHAO)
      end
    else
      self:SetIcon(_taskClass, self.icon)
    end
  else
    self.TypeSwitcher:SetActiveWidgetIndex(1)
    self:SetIcon(_taskClass, self.icon3)
    self.icon1:SetPath(self:GetBigMapIconRes(_taskAvatar))
  end
end

function UMG_IconTaskTemple_C:SetIcon(_taskClass, Icon)
  if _taskClass == _G.Enum.TaskClassType.TCT_MAIN then
    Icon:SetPath(UEPath.TASK_ICON_ZHUXIAN)
  elseif _taskClass == _G.Enum.TaskClassType.TCT_SUB then
    Icon:SetPath(UEPath.TASK_ICON_ZHIXIAN)
  elseif _taskClass == _G.Enum.TaskClassType.TCT_JOURNEY then
    Icon:SetPath(UEPath.TASK_ICON_SHILIAN)
  else
    Icon:SetPath(UEPath.TASK_ICON_ZHUXIAN)
  end
end

function UMG_IconTaskTemple_C:GetBigMapIconRes(IconName)
  return string.format("PaperSprite'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/WorldMapNpc/Frames/%s'", IconName)
end

return UMG_IconTaskTemple_C
