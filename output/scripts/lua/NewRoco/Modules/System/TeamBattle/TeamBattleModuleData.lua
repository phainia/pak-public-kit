local TeamBattleModuleData = _G.NRCData:Extend("TeamBattleModuleData")
local TeamBattleModuleEnum = require("NewRoco.Modules.System.TeamBattle.TeamBattleModuleEnum")

function TeamBattleModuleData:Ctor()
  NRCData.Ctor(self)
  self.TeamMateInfoList = nil
  self.ChangePetPanelChoosePet = nil
  self.curChoosePet = 0
  self.TargetNPCLogicId = 0
  self.TargetNPCActorId = 0
  self.curStage = TeamBattleModuleEnum.PrepareState.None
  self.medal_id = nil
  self.bGetMedal = false
end

function TeamBattleModuleData:GetTeamBattleAwards(star, blood)
  local TeamBattleAwardTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TEAM_BATTLE_AWARD)
  local TeamBattleAwardDatas = TeamBattleAwardTable:GetAllDatas()
  for k, v in pairs(TeamBattleAwardDatas) do
    if v.star == star and v.blood == blood then
      return v.show_award
    end
  end
end

function TeamBattleModuleData:GetTeamMateInfoByUin(uin)
  if self.TeamMateInfoList and #self.TeamMateInfoList > 0 then
    for k, v in ipairs(self.TeamMateInfoList) do
      if v.uin == uin then
        return v
      end
    end
  end
  return nil
end

function TeamBattleModuleData:AllPrepared()
  local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  local preparedNum = 0
  local TeamMatePlayerNum = 0
  if self.TeamMateInfoList then
    for i, TeamMateInfo in ipairs(self.TeamMateInfoList) do
      if 0 ~= TeamMateInfo.uin then
        TeamMatePlayerNum = TeamMatePlayerNum + 1
      end
    end
    if TeamMatePlayerNum == #visitorList then
      for k, v in ipairs(self.TeamMateInfoList) do
        if v.prepare_state == _G.ProtoEnum.TeamBattleMatePrepareState.TBMPS_OK then
          preparedNum = preparedNum + 1
        end
      end
    end
    if preparedNum == #self.TeamMateInfoList then
      return true
    else
      return false
    end
  end
  return false
end

function TeamBattleModuleData:SetChangePetPanelChoosePet(petData)
  self.ChangePetPanelChoosePet = petData
end

function TeamBattleModuleData:SetCurChoosePet(petGid)
  self.curChoosePet = petGid
end

function TeamBattleModuleData:GetCurNPCActorId()
  return self.TargetNPCActorId
end

function TeamBattleModuleData:SetHardSeedMedalData(medal_id, bGet)
  self.medal_id = medal_id
  self.bGetMedal = bGet
end

function TeamBattleModuleData:GetHardSeedMedalData()
  return self.medal_id, self.bGetMedal
end

return TeamBattleModuleData
