local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local TaskTrackItem = require("NewRoco.Modules.Core.Task.TaskTrackItem")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local Base = TaskTrackItem
local PointTaskTrackItem = Base:Extend("PointTaskTrackItem")
local MarkInvalidReason = {
  [0] = "Invalid",
  [1] = "ExtraTrackingInfo is nil",
  [2] = "ExtraTrackingInfo.guide_list is nil",
  [3] = "SceneModule is nil",
  [4] = "ExtraTrackingInfo.guide_list[1] is nil",
  [5] = "PlayerPosCache is nil"
}

function PointTaskTrackItem:Ctor(config, info, go, TaskObject, Index)
  Base.Ctor(self, config, info, go, TaskObject, Index)
end

function PointTaskTrackItem:FindNPC()
  local ExtraTrackingInfo = self:GetExtraTrackingInfo()
  if not ExtraTrackingInfo then
    self:MarkInvalid(MarkInvalidReason[1])
    return
  end
  if not ExtraTrackingInfo.guide_list or 0 == #ExtraTrackingInfo.guide_list then
    self:MarkInvalid(MarkInvalidReason[2])
    return
  end
  local SceneModule = TaskUtils:getSceneModule()
  if not SceneModule then
    self:MarkInvalid(MarkInvalidReason[3])
    return
  end
  local FirstItem = ExtraTrackingInfo.guide_list[1]
  if not FirstItem then
    self:MarkInvalid(MarkInvalidReason[4])
    return
  end
  if not self:UpdatePlayerPosCache() then
    self:MarkInvalid(MarkInvalidReason[5])
    return
  end
  local CurrentMapID = SceneModule.mapResId
  local CurrentSceneResConf = _G.DataConfigManager:GetSceneResConf(CurrentMapID)
  local CurrentSceneGroup = CurrentSceneResConf and CurrentSceneResConf.task_scene_group or 0
  local DestSceneConf = _G.DataConfigManager:GetSceneResConf(FirstItem.dest_res_cfg_id)
  local DestSceneGroup = DestSceneConf and DestSceneConf.task_scene_group or 0
  local InSameSceneGroup = CurrentSceneGroup == DestSceneGroup
  self.TargetInSameSceneGroup = InSameSceneGroup
  self.TargetSceneResID = FirstItem.dest_res_cfg_id
  if not InSameSceneGroup then
    self.Valid = false
    self.MinimapValid = false
    return
  end
  local InDungeon = _G.DataModelMgr.PlayerDataModel:IsInDungeon()
  self.TargetInSameScene = DestSceneConf.id == CurrentSceneResConf.id
  if not self.TargetInSameScene and InDungeon then
    self.Valid = false
    self.MinimapValid = false
    return
  end
  local Pos = self:GetGuidePos(FirstItem)
  self:UpdatePosition(Pos.x, Pos.y, Pos.z)
  self:UpdateDirectionSign()
  self:UpdateDistance()
  self.Valid = true
  self.MinimapValid = true
  if not self.TaskObject:IsTrack() then
    self:StopTick()
  end
end

return PointTaskTrackItem
