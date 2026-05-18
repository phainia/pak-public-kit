local towerModeUtils = require("NewRoco.Modules.Core.TowerMode.TowerModeUtils")
local TowerMode = NRCModuleBase:Extend("TowerMode")

function TowerMode:OnConstruct()
  _G.TowerModeCmd = reload("NewRoco.Modules.Core.TowerMode.TowerModeCmd")
  self.data = self:SetData("TowerModeData", "NewRoco.Modules.Core.TowerMode.TowerModeData")
  self:RegPanel("TowerModeMainPanel", "UMG_TowerMain", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("TowerRewardPanel", "UMG_TowerReward", _G.Enum.UILayerType.UI_LAYER_MAIN)
end

function TowerMode:OnOpenMainPanel(arg)
  self:Log("OnOpenMainPanel")
  if not self:HasPanel("TowerModeMainPanel") then
    self:OpenPanel("TowerModeMainPanel")
    self.data:initialize()
  else
    self:ClosePanel("TowerModeMainPanel")
  end
end

function TowerMode:OnCmdOpenRewardPanel(_data)
  Log.Dump(_data, 6, "TowerMode:OnCmdOpenRewardPanel")
  self:OpenPanel("TowerRewardPanel", _data)
end

function TowerMode:OnActive()
  Log.Debug("TowerModeModule Activated")
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_CLIMB_CHAPTER_NOTIFY, self.ClimbStaging)
end

function TowerMode:ClimbStaging(rsp)
  if not DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter then
    DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter = ProtoMessage:newPlayerClimbChapterInfo()
    DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter.chapter_list[1] = rsp.chapter_item
  else
    local index = towerModeUtils:findIndex(rsp.chapter_item.chapter_id, DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter.chapter_list)
    if 0 ~= index then
      DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter.chapter_list[index] = rsp.chapter_item
    else
      DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter.chapter_list[#DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter.chapter_list + 1] = rsp.chapter_item
    end
  end
end

function TowerMode:OnRelogin()
end

function TowerMode:OnDeactive()
  Log.Debug("TowerModeModule Deactivated")
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_CLIMB_CHAPTER_NOTIFY, self.ClimbStaging)
end

function TowerMode:RegPanel(name, path, layer)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/TowerModeUI/Res/%s", path)
  registerData.panelLayer = layer
  self:RegisterPanel(registerData)
end

function TowerMode:OnDestruct()
end

return TowerMode
