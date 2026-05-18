require("UnLuaEx")
local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local UMG_TraceTaskItem_C = NRCViewBase:Extend("UMG_TraceTaskItem_C")
local Alignment = UE4.FVector2D(0.5, 0)

function UMG_TraceTaskItem_C:GetPosition()
  return self.Tracker:GetPosition()
end

function UMG_TraceTaskItem_C:HasPosition()
  local Position = self:GetPosition()
  return Position and not UE.FVector.IsNearlyZero(Position, 0.01)
end

function UMG_TraceTaskItem_C:CheckValid()
  if not self.Tracker then
    return false
  end
  if not self.Tracker.Valid then
    return false
  end
  if not self.Tracker.Synchronized then
    return false
  end
  if not self.Tracker.TargetInSameSceneGroup then
    return false
  end
  return true
end

function UMG_TraceTaskItem_C:CheckInSameGroup()
  if not self.Tracker then
    return false
  end
  return self.Tracker.TargetInSameSceneGroup
end

function UMG_TraceTaskItem_C:ShouldForceShow()
  if not self.Tracker then
    return false
  end
  return self.Tracker:ShouldForceShow()
end

function UMG_TraceTaskItem_C:UnFocus()
  if not self.Tracker then
    return
  end
  self.Tracker.FocusShine = false
end

function UMG_TraceTaskItem_C:SetTracker(item)
  self.Tracker = item
  self.Slot:SetAlignment(Alignment)
  TaskUtils.SetupTaskStateIcon(item.TaskObject, self.Icon)
  self.TaskClass = self:GetTaskClass()
end

local VisibleEnum = UE.ESlateVisibility.Visible
local CollapseEnum = UE.ESlateVisibility.Collapsed

function UMG_TraceTaskItem_C:ToggleArrow(show, dist)
  if show then
    self.Arrow:SetVisibility(VisibleEnum)
    self.Distance:SetVisibility(CollapseEnum)
  else
    self.Arrow:SetVisibility(CollapseEnum)
    self.Distance:SetVisibility(VisibleEnum)
    if nil ~= dist then
      dist = dist / 100
      self.Distance:SetText(string.format(LuaText.umg_tracetaskitem_1, math.round(dist)))
    end
  end
end

function UMG_TraceTaskItem_C:UpdateArrow(theta)
  self:ToggleArrow(true)
  self.Arrow:SetRenderTransformAngle(math.deg(theta) + 90)
end

function UMG_TraceTaskItem_C:SetPosition(position)
  self.Slot:SetPosition(position)
end

function UMG_TraceTaskItem_C:UpdateAnimation()
  if self.Tracker.Shine then
    if self.Icon_Tips then
      self:PlayAnimation(self.Icon_Tips)
    end
    self.Tracker.Shine = false
  elseif self.Tracker.FocusShine then
    local TaskClass = self.TaskClass
    if TaskClass == Enum.TaskClassType.TCT_SUB then
      self:StartAnimationByName("TaskTracking")
    elseif TaskClass == Enum.TaskClassType.TCT_MAIN then
      self:StartAnimationByName("TaskTracking_0")
    elseif TaskClass == Enum.TaskClassType.TCT_JOURNEY then
      self:StartAnimationByName("TaskTracking_1")
    else
      self:StartAnimationByName("TaskTracking")
    end
    self.Tracker.FocusShine = false
    local CurrentlyVisible = self.GetIsVisible and self:GetIsVisible()
    if not CurrentlyVisible then
      local Info = self.Tracker and self.Tracker.Info
      if Info then
        local TaskID = Info and Info.id or 0
        local GoIndex = self.Tracker and self.Tracker.go_index
        Log.ErrorFormat("[TaskFlow] UMG_TraceTaskItem_C Task Track Item not visible, Task %d, Go Index %d", TaskID, GoIndex)
      end
    end
  end
end

function UMG_TraceTaskItem_C:GetTaskClass()
  local Tracker = self.Tracker
  if not Tracker then
    return
  end
  local Task = Tracker.TaskObject
  if not Task then
    return
  end
  local Conf = Task.Config
  if not Conf then
    return
  end
  return Conf.task_class
end

function UMG_TraceTaskItem_C:StartAnimationByName(AnimationName)
  local Anim = self[AnimationName]
  if Anim and not self:IsAnimationPlaying(Anim) then
    self:PlayAnimation(Anim)
  end
end

function UMG_TraceTaskItem_C:OnAnimationStarted(Animation)
  if Animation == self.Icon_Tips then
    _G.NRCAudioManager:PlaySound2DAuto(1042, "UMG_TraceTaskItem_C:UpdateAnimation")
  elseif Animation == self.TaskTracking or Animation == self.TaskTracking_0 or Animation == self.TaskTracking_1 then
    _G.NRCAudioManager:PlaySound2DAuto(1042, "UMG_TraceTaskItem_C:UpdateAnimation")
  end
end

function UMG_TraceTaskItem_C:Destruct()
  self.Icon:ReleaseForce()
end

return UMG_TraceTaskItem_C
