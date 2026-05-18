local Base = require("NewRoco.Modules.System.MainUI.Res.UMG_Hud_Base")
local UMG_Hud_Track_C = Base:Extend("UMG_Hud_Track_C")
local IconStyle = {
  None = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/Lobby/Frames/img_renwubiaoshi2_png.img_renwubiaoshi2_png'",
  Main = "PaperSprite'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/BigMapStatic/Frames/image_icon_renwu_zhixian_0_png.image_icon_renwu_zhixian_0_png'",
  Sub = "PaperSprite'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/BigMapStatic/Frames/image_icon_renwu_shilian_0_png.image_icon_renwu_shilian_0_png'",
  Journey = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/Lobby/Frames/image_icon_renwu_zhuxian_0_png.image_icon_renwu_zhuxian_0_png'"
}
local IconStyleIndex = {
  None = 0,
  Journey = 9,
  Main = 10,
  Sub = 11
}

function UMG_Hud_Track_C:OnEnable(TaskID)
  self:UpdateTaskInfo(TaskID)
end

function UMG_Hud_Track_C:UpdateTaskInfo(TaskID)
  local TaskConf = _G.DataConfigManager:GetTaskConf(TaskID)
  if not TaskConf then
    return
  end
  local IconIndex = IconStyleIndex.None
  if TaskConf.task_class == Enum.TaskClassType.TCT_MAIN then
    IconIndex = IconStyleIndex.Main
  elseif TaskConf.task_class == Enum.TaskClassType.TCT_SUB or TaskConf.task_class == Enum.TaskClassType.TCT_EVOLUTION or TaskConf.task_class == Enum.TaskClassType.TCT_CAMPAIGN then
    IconIndex = IconStyleIndex.Sub
  elseif TaskConf.task_class == Enum.TaskClassType.TCT_DUNGEON or TaskConf.task_class == Enum.TaskClassType.TCT_JOURNEY then
    IconIndex = IconStyleIndex.Journey
  end
  if self.IconIndex == IconIndex then
    return
  end
  if self.IconIndex ~= IconIndex then
    self.IconIndex = IconIndex
  end
  self.GuideIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.GuideIcon:ChangeImage(IconIndex)
end

function UMG_Hud_Track_C:ShowTrackingEnd()
  self:PlayAnimation(self.Change)
end

return UMG_Hud_Track_C
