local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local TowerModeEvent = reload("NewRoco.Modules.Core.TowerMode.TowerModeEvent")
local towerModeUtils = require("NewRoco.Modules.Core.TowerMode.TowerModeUtils")
local Base = NPCActionBase
local NPCActionTowerAscension = Base:Extend("NPCActionTowerAscension")

function NPCActionTowerAscension:OnDialogueAction()
  Log.Debug("OpenTower")
  local module = NRCModuleManager:GetModule("TowerModeModule")
  self.data = module:GetData("TowerModeData")
  self.data.NPC = self.Owner
  self.data.stageID = toNumber(self.Config.action_param1, 0)
  local playerdt = DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter
  if playerdt then
    local index = towerModeUtils:findIndex(self.data.stageID, DataModelMgr.PlayerDataModel.playerInfo.common_info.climb_chapter.chapter_list)
    local IND = {}
    for k, v in pairs(DataConfigManager:GetClimbChapterConf(self.data.stageID).stage) do
      IND[v] = k
    end
    if 0 ~= index and playerdt.chapter_list[index].now_finish_stage ~= nil then
      local stage = DataConfigManager:GetStageConf(playerdt.chapter_list[index].now_finish_stage).next_id
      if nil == stage then
        self.data.curStage = IND[playerdt.chapter_list[index].now_finish_stage] + 1
      else
        self.data.curStage = IND[stage]
      end
    else
      self.data.curStage = 1
    end
  else
    self.data.curStage = 1
  end
  if nil == self.data.curStage then
    self.data.curStage = 99
  end
  local ChapConf = DataConfigManager:GetClimbChapterConf(self.data.stageID)
  self.data.battleID = ChapConf.stage[self.data.curStage]
  if nil == self.data.battleID then
    self.data.battleID = ChapConf.stage[#ChapConf.stage]
  end
  self.data.StageConfigure = DataConfigManager:GetStageConf(self.data.battleID)
  NRCModuleManager:DoCmd(TowerModeCmd.OpenMainPanel)
end

function NPCActionTowerAscension:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

return NPCActionTowerAscension
