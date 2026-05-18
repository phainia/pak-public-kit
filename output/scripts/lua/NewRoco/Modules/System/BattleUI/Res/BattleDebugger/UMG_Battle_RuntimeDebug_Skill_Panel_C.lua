local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_Battle_RuntimeDebug_Skill_Panel_C = _G.NRCPanelBase:Extend("UMG_Battle_RuntimeDebug_Skill_Panel_C")

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnConstruct()
  self.debugControl = _G.BattleManager.battleRuntimeData.battleDebugControl
  self.debugControl:SetTestData()
  self.roundParam = {}
  self.EditableTextBoxTime:SetText("12:00")
  self.EditableTextBoxTime.OnTextChanged:Add(self, self.OnTimeTextChange)
  local weatherList = self.debugControl:GetAllWeatherList()
  for i, v in pairs(weatherList) do
    self.ComboBoxStringWeather:AddOption(v)
  end
  self.ComboBoxStringWeather:SetSelectedIndex(2)
  self.ComboBoxStringWeather.OnSelectionChanged:Add(self, self.OnWeatherChange)
  self.NRCButtonStart.OnClicked:Add(self, self.OnRoundPlay)
  self.NRCButtonSaveBattleData.OnClicked:Add(self, self.SaveBattleData)
  local petBallList = self.debugControl:GetAllPetBallList()
  for i, v in ipairs(petBallList) do
    self.ComboBoxStringBall:AddOption(v)
  end
  self.ComboBoxStringBall:SetSelectedIndex(0)
  local playerSkillList = self.debugControl:GetAllPlayerSkillList()
  for i, v in ipairs(playerSkillList) do
    self.ComboBoxStringPlayMagic:AddOption(v)
    self.ComboBoxStringNPCMagic:AddOption(v)
  end
  self.ComboBoxStringPlayMagic:SetSelectedIndex(0)
  self.ComboBoxStringNPCMagic:SetSelectedIndex(0)
  local battleType = self.debugControl.cacheBattleParams.battleType
  self.NRCTextBattleType:SetText(self.debugControl.BattleTypeName[battleType])
  self.teamPets = {}
  self.enemyPets = {}
  self.CloseButton.OnClicked:Add(self, self.OnCloseClick)
  NRCEventCenter:RegisterEvent("RuntimeDebug_Skill_Panel", self, TaskModuleEvent.BattleOver, self.OnExitBattleEvent)
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnTimeTextChange()
  local gameTime = self:GetTimeFromInput()
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, gameTime, false)
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnWeatherChange()
  local weather = self.debugControl:GetWeatherByKey(self.ComboBoxStringWeather:GetSelectedOption())
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  EnvSys:SetWeatherStat(weather, true, false)
  self.debugControl:ZoneSceneGmReq(ProtoEnum.SceneGmType.SGT_WEATHER, ProtoEnum.SceneGmOpType.SGOT_SET, weather)
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnCloseClick()
  local req = _G.ProtoMessage:newZoneGmBattleEndReq()
  req.battle_result = 0
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_BATTLE_END_REQ, req, self, self.OnQuitBattle)
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnQuitBattle()
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnExitBattleEvent()
  self:DoClose()
  if _G.AppMain:HasDebug() then
    NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, true)
  end
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnRoundPlay()
  self.roundParam = {}
  self.roundParam.gameTime = self:GetTimeFromInput()
  self.roundParam.weather = self.debugControl:GetWeatherByKey(self.ComboBoxStringWeather:GetSelectedOption())
  self.roundParam.playerMagicCMDs = {}
  self:AddMagicInfo(self.ComboBoxStringPlayMagic:GetSelectedOption(), BattleEnum.Team.ENUM_TEAM)
  self:AddMagicInfo(self.ComboBoxStringNPCMagic:GetSelectedOption(), BattleEnum.Team.ENUM_ENEMY)
  local isOpenCatch = self.CheckBoxOpenCatch:IsChecked()
  if isOpenCatch then
    local petBall = self.ComboBoxStringBall:GetSelectedOption()
    local Cmd = {
      ballItemId = self.debugControl:GetPetBallIdByKey(petBall) or 100002,
      isSucceed = self.CheckBoxCatchSucceed:IsChecked(),
      isCrit = self.CheckBoxCatchCrit:IsChecked()
    }
    self.roundParam.playerCatchCMD = Cmd
  end
  self.roundParam.teamCMDs = {}
  for i, v in ipairs(self.teamPets) do
    if not isOpenCatch or 1 ~= i then
      local petItem = self.List_TeamPet:GetItemByIndex(i - 1)
      table.insert(self.roundParam.teamCMDs, petItem:GetSkillParam())
    end
  end
  self.roundParam.enemyCMDs = {}
  for i, v in ipairs(self.enemyPets) do
    local petItem = self.List_EnemyPet:GetItemByIndex(i - 1)
    table.insert(self.roundParam.enemyCMDs, petItem:GetSkillParam())
  end
  Log.Dump(self.roundParam, 4, "UMG_Battle_RuntimeDebug_Skill_Panel_C:OnRoundPlay")
  self.debugControl:RoundStart(self.roundParam)
  self:Disable()
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:GetTimeFromInput()
  local RawTime = self.EditableTextBoxTime:GetText()
  local RawSecond = tonumber(RawTime)
  if nil ~= RawSecond then
    if RawSecond < 2400 then
      local time = math.floor(RawSecond / 100) * 3600 + RawSecond % 100 * 60
      return time
    else
      return RawSecond
    end
  end
  local TimeArrayList = string.Split(RawTime, ":")
  local TargetTime = 0
  for i, value in pairs(TimeArrayList) do
    if not string.IsNilOrEmpty(value) then
      local Time = tonumber(value) * 60 ^ (3 - i)
      TargetTime = TargetTime + Time
    end
  end
  return TargetTime
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:AddMagicInfo(magicInfo, team)
  local magicId = self.debugControl:GetPlayerSkillIdByKey(magicInfo)
  if magicId then
    local teamPet = _G.BattleManager.battlePawnManager:GetFirstPet(team)
    local cmd = {
      target_pet_id = teamPet.guid,
      team = team,
      magicId = magicId
    }
    table.insert(self.roundParam.playerMagicCMDs, cmd)
  end
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:SaveBattleData()
  BattleReplayCachePool:SaveCurBattleData()
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnActive(...)
  self.teamPets = {}
  local battlePetCount = self.debugControl:GetBattlePetCount()
  local canSummonNumber = 0
  local teamPlayer = self.debugControl.pawnManager:GetPlayerMyTeam()
  for i, v in ipairs(teamPlayer.deck.cards) do
    if v:IsExistAtField() or v:CanSummon() then
      canSummonNumber = canSummonNumber + 1
    end
  end
  Log.Debug("UMG_Battle_RuntimeDebug_Skill_Panel_C:OnActive ", canSummonNumber, battlePetCount)
  battlePetCount = math.min(canSummonNumber, battlePetCount)
  for i = 1, battlePetCount do
    table.insert(self.teamPets, {
      panel = self,
      team = BattleEnum.Team.ENUM_TEAM
    })
  end
  self.enemyPets = {}
  local enemyBattlePetCount = self.debugControl:GetEnemyBattlePetCount()
  canSummonNumber = 0
  local enemyPlayer = self.debugControl.pawnManager:GetPlayerEnemyTeam()
  for i, v in ipairs(enemyPlayer.deck.cards) do
    if v:IsExistAtField() or v:CanSummon() then
      canSummonNumber = canSummonNumber + 1
    end
  end
  enemyBattlePetCount = math.min(canSummonNumber, enemyBattlePetCount)
  for i = 1, enemyBattlePetCount do
    table.insert(self.enemyPets, {
      panel = self,
      team = BattleEnum.Team.ENUM_ENEMY
    })
  end
  self.List_TeamPet:InitList(self.teamPets)
  self.List_EnemyPet:InitList(self.enemyPets)
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:OnDestruct()
  self.NRCButtonStart.OnClicked:Remove(self, self.OnRoundPlay)
  self.NRCButtonSaveBattleData.OnClicked:Remove(self, self.SaveBattleData)
  self.EditableTextBoxTime.OnTextChanged:Remove(self, self.OnTimeTextChange)
  self.ComboBoxStringWeather.OnSelectionChanged:Remove(self, self.OnWeatherChange)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleOver, self.OnExitBattleEvent)
end

function UMG_Battle_RuntimeDebug_Skill_Panel_C:GetFirstSelectSkill(team)
  local petItem
  if team == BattleEnum.Team.ENUM_TEAM then
    petItem = self.List_EnemyPet:GetItemByIndex(0)
  else
    petItem = self.List_TeamPet:GetItemByIndex(0)
  end
  return petItem:GetCurSelectSkill()
end

return UMG_Battle_RuntimeDebug_Skill_Panel_C
