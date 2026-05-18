local UMG_BattleControllerPanel_C = _G.NRCPanelBase:Extend("UMG_BattleControllerPanel_C")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")

function UMG_BattleControllerPanel_C:OnActive()
  self:ClearData()
  self:LoadAllData()
  self:AddTextListener()
end

function UMG_BattleControllerPanel_C:ClearData()
  self.ComboBoxTarget_0Op = {}
  self.ComboBoxTarget_1Op = {}
  self.ComboBoxString_0Op = {}
  self.ComboBoxStringOp = {}
  self.ComboBoxString_2Op = {}
  self.ComboBoxStringBuff_0Op = {}
  self.ComboBoxStringBuff_1Op = {}
  self.ComboBoxString_1Op = {}
end

function UMG_BattleControllerPanel_C:LoadAllData()
  self.ComboBoxTarget_0Op["\228\189\141\231\189\1741"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_TEAM, 1)
  self.ComboBoxTarget_0Op["\228\189\141\231\189\1742"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_TEAM, 2)
  self.ComboBoxTarget_1Op["\228\189\141\231\189\1741"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_ENEMY, 1)
  self.ComboBoxTarget_1Op["\228\189\141\231\189\1742"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_ENEMY, 2)
  self.ComboBoxTarget_0:AddOption("\228\189\141\231\189\1741")
  self.ComboBoxTarget_0:AddOption("\228\189\141\231\189\1742")
  self.ComboBoxTarget_1:AddOption("\228\189\141\231\189\1741")
  self.ComboBoxTarget_1:AddOption("\228\189\141\231\189\1742")
  self.ComboBoxTarget_0:SetSelectedIndex(0)
  self.ComboBoxTarget_1:SetSelectedIndex(0)
  self.sortPets = {}
  local AllPet = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_CONF):GetAllDatas()
  for _, v in pairs(AllPet) do
    local PetBase = _G.DataConfigManager:GetPetbaseConf(v.base_id)
    local Model = PetBase and _G.DataConfigManager:GetModelConf(PetBase.model_conf)
    if Model then
      Log.Debug("Model.path:", Model.path)
      local Exist = PetBase and Model and UE4.UNRCStatics.CheckAssetExists(Model.path)
      table.insert(self.sortPets, {Conf = v, Exist = Exist})
    end
  end
  table.sort(self.sortPets, function(a, b)
    if a.Exist ~= b.Exist then
      local anum = a.Exist and 1 or 0
      local bnum = b.Exist and 1 or 0
      return anum > bnum
    else
      return a.Conf.id < b.Conf.id
    end
  end)
  for _, v in ipairs(self.sortPets) do
    local data = string.format("[%s] %d %s", v.Exist and "O" or "X", v.Conf.id, v.Conf.name)
    self.ComboBoxString_0Op[data] = v.Conf.id
    self.ComboBoxString_1Op[data] = v.Conf.id
    self.ComboBoxString_0:AddOption(data)
    self.ComboBoxString_1:AddOption(data)
  end
  self.sortSkills = {}
  local AllSkill = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
  for _, v in pairs(AllSkill) do
    if UE4.UNRCStatics.CheckAssetExists(v.res_id) then
      table.insert(self.sortSkills, {Conf = v, Exist = true})
    end
  end
  table.sort(self.sortSkills, function(a, b)
    if a.Exist ~= b.Exist then
      local anum = a.Exist and 1 or 0
      local bnum = b.Exist and 1 or 0
      return anum > bnum
    else
      return a.Conf.id < b.Conf.id
    end
  end)
  for _, v in ipairs(self.sortSkills) do
    local short_res = v.Conf.res_id
    if nil ~= short_res then
      local str_array = short_res:split("/")
      short_res = str_array[#str_array]
    end
    local Option = string.format("[%s] %s %s %d", v.Exist and "O" or "X", short_res, v.Conf.name, v.Conf.id)
    self.ComboBoxStringOp[Option] = v.Conf.id
    self.ComboBoxString_2Op[Option] = v.Conf.id
    self.ComboBoxString:AddOption(Option)
    self.ComboBoxString_2:AddOption(Option)
  end
  self.sortBuffs = {}
  local AllBuffs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BUFF_CONF):GetAllDatas()
  for _, v in pairs(AllBuffs) do
    table.insert(self.sortBuffs, {
      Conf = v,
      Exist = UE4.UNRCStatics.CheckAssetExists(v.res_id)
    })
  end
  table.sort(self.sortBuffs, function(a, b)
    if a.Exist ~= b.Exist then
      local anum = a.Exist and 1 or 0
      local bnum = b.Exist and 1 or 0
      return anum > bnum
    else
      return a.Conf.id < b.Conf.id
    end
  end)
  for _, v in ipairs(self.sortBuffs) do
    local short_res = v.Conf.res_id
    if nil ~= short_res then
      local str_array = short_res:split("/")
      short_res = str_array[#str_array]
    end
    local Option = string.format("[%s] %s %s %d", v.Exist and "O" or "X", short_res, v.Conf.name, v.Conf.id)
    self.ComboBoxStringBuff_0Op[Option] = v.Conf.id
    self.ComboBoxStringBuff_1Op[Option] = v.Conf.id
    self.ComboBoxStringBuff_0:AddOption(Option)
    self.ComboBoxStringBuff_1:AddOption(Option)
  end
end

function UMG_BattleControllerPanel_C:AddTextListener()
  self.ComboBoxTarget_0.OnSelectionChanged:Add(self, self.ChangePlayerSelectedPet)
  self.ComboBoxTarget_1.OnSelectionChanged:Add(self, self.ChangeEnemySelectedPet)
  self.ComboBoxString.OnSelectionChanged:Add(self, self.PlayerSkillChange)
  self.ComboBoxString_2.OnSelectionChanged:Add(self, self.EnemySkillChange)
  self.ComboBoxString_0.OnSelectionChanged:Add(self, self.PlayerPetChange)
  self.ComboBoxString_1.OnSelectionChanged:Add(self, self.EnemyPetChange)
  self.ComboBoxStringBuff_0.OnSelectionChanged:Add(self, self.PlayerBuffChange)
  self.ComboBoxStringBuff_1.OnSelectionChanged:Add(self, self.EnemyBuffChange)
  self.ComboBoxString_0ET.OnTextChanged:Add(self, self.FilterMyPet)
  self.ComboBoxString_1ET.OnTextChanged:Add(self, self.FilterEnemyPet)
  self.ComboBoxStringET.OnTextChanged:Add(self, self.FilterMySkill)
  self.ComboBoxString_2ET.OnTextChanged:Add(self, self.FilterEnemySkill)
  self.ComboBoxStringBuff_0ET.OnTextChanged:Add(self, self.FilterMyBuff)
  self.ComboBoxStringBuff_1ET.OnTextChanged:Add(self, self.FilterEnemyBuff)
  self.CloseBtn.OnClicked:Add(self, self.OnCloseUI)
end

function UMG_BattleControllerPanel_C:RemoveTextListener()
  self.ComboBoxTarget_0.OnSelectionChanged:Remove(self, self.ChangePlayerSelectedPet)
  self.ComboBoxTarget_1.OnSelectionChanged:Remove(self, self.ChangeEnemySelectedPet)
  self.ComboBoxString.OnSelectionChanged:Remove(self, self.PlayerSkillChange)
  self.ComboBoxString_2.OnSelectionChanged:Remove(self, self.EnemySkillChange)
  self.ComboBoxString_0.OnSelectionChanged:Remove(self, self.PlayerPetChange)
  self.ComboBoxString_1.OnSelectionChanged:Remove(self, self.EnemyPetChange)
  self.ComboBoxStringBuff_0.OnSelectionChanged:Remove(self, self.PlayerBuffChange)
  self.ComboBoxStringBuff_1.OnSelectionChanged:Remove(self, self.EnemyBuffChange)
  self.ComboBoxString_0ET.OnTextChanged:Remove(self, self.FilterMyPet)
  self.ComboBoxString_1ET.OnTextChanged:Remove(self, self.FilterEnemyPet)
  self.ComboBoxStringET.OnTextChanged:Remove(self, self.FilterMySkill)
  self.ComboBoxString_2ET.OnTextChanged:Remove(self, self.FilterEnemySkill)
  self.ComboBoxStringBuff_0ET.OnTextChanged:Remove(self, self.FilterMyBuff)
  self.ComboBoxStringBuff_1ET.OnTextChanged:Remove(self, self.FilterEnemyBuff)
  self.CloseBtn.OnClicked:Remove(self, self.OnCloseUI)
end

function UMG_BattleControllerPanel_C:OnCloseUI()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleControllerPanel)
end

function UMG_BattleControllerPanel_C:ChangePlayerSelectedPet(SelectedItem, SelectionType)
  if -1 == self.ComboBoxTarget_0:GetSelectedIndex() then
    return
  end
  ServerData.values.CurSelectedPetPlayer = self.ComboBoxTarget_0Op[SelectedItem]
  ServerData.values.CurSelectedPlayerPetPos = ServerData.values.CurSelectedPetPlayer
  Log.Debug("UMG_BattleControllerPanel_Ctrl CurSelectedPetPlayer:", ServerData.values.CurSelectedPetPlayer)
end

function UMG_BattleControllerPanel_C:ChangeEnemySelectedPet(SelectedItem, SelectionType)
  if -1 == self.ComboBoxTarget_1:GetSelectedIndex() then
    return
  end
  ServerData.values.CurSelectedPetEnemy = self.ComboBoxTarget_1Op[SelectedItem]
  ServerData.values.CurSelectedEnemyPetPos = ServerData.values.CurSelectedPetEnemy - 400
  Log.Debug("UMG_BattleControllerPanel_Ctrl CurSelectedPetPlayer:", ServerData.values.CurSelectedPetEnemy)
end

function UMG_BattleControllerPanel_C:PlayerPetChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_0:GetSelectedIndex() then
    return
  end
  local req = self:GetChangePetCMDReq(self.ComboBoxString_0, self.ComboBoxString_0Op)
  req.__isplayer = true
  self:ChangeModel(req, true)
end

function UMG_BattleControllerPanel_C:EnemyPetChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_1:GetSelectedIndex() then
    return
  end
  local req = self:GetChangePetCMDReq(self.ComboBoxString_1, self.ComboBoxString_1Op)
  req.__isplayer = false
  self:ChangeModel(req, false)
end

function UMG_BattleControllerPanel_C:PlayerSkillChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString:GetSelectedIndex() then
    return
  end
  local req = self:GetSkillCMDReq(self.ComboBoxString, self.ComboBoxStringOp)
  ServerData.ChangeBattleType("self")
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
  ServerData.ChangeBattleType("enemy")
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
  self:Hide()
  self.playerPlayed = true
end

function UMG_BattleControllerPanel_C:EnemySkillChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_2:GetSelectedIndex() then
    return
  end
  local req = self:GetSkillCMDReq(self.ComboBoxString_2, self.ComboBoxString_2Op)
  req.__local_isEnemy = true
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
  self.playerPlayed = false
end

function UMG_BattleControllerPanel_C:PlayerBuffChange()
  if -1 == self.ComboBoxStringBuff_0:GetSelectedIndex() then
    return
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  req.__local_isBuff = true
  req.__local_isEnemy = false
  local op = self.ComboBoxStringBuff_0:GetSelectedOption()
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = self.ComboBoxStringBuff_0Op[op]
  BattleRoundFlowReq.cast_skill.caster_pet_id = ServerData.GetPlayerBattlePetID()
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
end

function UMG_BattleControllerPanel_C:EnemyBuffChange()
  if -1 == self.ComboBoxStringBuff_1:GetSelectedIndex() then
    return
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  req.__local_isBuff = true
  req.__local_isEnemy = false
  local op = self.ComboBoxStringBuff_1:GetSelectedOption()
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = self.ComboBoxStringBuff_1Op[op]
  BattleRoundFlowReq.cast_skill.caster_pet_id = ServerData.GetEnemyBattlePetID()
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
end

function UMG_BattleControllerPanel_C:OnDeactive()
  self:RemoveTextListener()
end

function UMG_BattleControllerPanel_C:OnAddEventListener()
end

function UMG_BattleControllerPanel_C:OnTick()
end

function UMG_BattleControllerPanel_C:OnLogin()
end

function UMG_BattleControllerPanel_C:OnConstruct()
end

function UMG_BattleControllerPanel_C:OnDestruct()
end

function UMG_BattleControllerPanel_C:OnAnimationFinished(anim)
end

function UMG_BattleControllerPanel_C:FilterMyPet()
  self:FilterOptions(self.ComboBoxString_0Op, self.ComboBoxString_0, self.ComboBoxString_0ET:GetText())
end

function UMG_BattleControllerPanel_C:FilterEnemyPet()
  self:FilterOptions(self.ComboBoxString_1Op, self.ComboBoxString_1, self.ComboBoxString_1ET:GetText())
end

function UMG_BattleControllerPanel_C:FilterMySkill()
  self:FilterOptions(self.ComboBoxStringOp, self.ComboBoxString, self.ComboBoxStringET:GetText())
end

function UMG_BattleControllerPanel_C:FilterEnemySkill()
  self:FilterOptions(self.ComboBoxString_2Op, self.ComboBoxString_2, self.ComboBoxString_2ET:GetText())
end

function UMG_BattleControllerPanel_C:FilterMyBuff()
  self:FilterOptions(self.ComboBoxStringBuff_0Op, self.ComboBoxStringBuff_0, self.ComboBoxStringBuff_0ET:GetText())
end

function UMG_BattleControllerPanel_C:FilterEnemyBuff()
  self:FilterOptions(self.ComboBoxStringBuff_1Op, self.ComboBoxStringBuff_1, self.ComboBoxStringBuff_1ET:GetText())
end

function UMG_BattleControllerPanel_C:FilterOptions(AllOptions, comboBox, filter)
  for i, v in pairs(AllOptions) do
    if i:find(filter) then
      if comboBox:FindOptionIndex(i) < 0 then
        comboBox:AddOption(i)
      end
    elseif comboBox:FindOptionIndex(i) >= 0 then
      comboBox:RemoveOption(i)
    end
  end
end

function UMG_BattleControllerPanel_C:OnCatchButton()
  local Catch = BattleNetManager:BuildBattleCmdPushbackReq()
  Catch.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CATCH_PET
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, Catch)
end

function UMG_BattleControllerPanel_C:ChangeModel(req, isPlayer)
  local battle_pet_id, battle_pet_info, pet
  if req.__isplayer then
    battle_pet_id = ServerData.GetPlayerBattlePetID()
    battle_pet_info = ServerData.GetPlayerBattlePetInfo()
    pet = self.PawnManager.playerTeam:GetPetByGuid(battle_pet_id)
  else
    battle_pet_id = ServerData.GetEnemyBattlePetID()
    battle_pet_info = ServerData.GetEnemyBattlePetInfo()
    Log.Debug("show me pet:", battle_pet_id, battle_pet_info)
    pet = self.PawnManager.enemyTeam:GetPetByGuid(battle_pet_id)
  end
  local oldModel = pet.model
  local baseconf = _G.DataConfigManager:GetPetbaseConf(req.__baseConfId)
  local ModelConf = _G.DataConfigManager:GetModelConf(baseconf.model_conf)
  self.petClassRequest = NRCResourceManager:LoadResAsync(self, ModelConf.path, 255, -1, function(caller, resRequest, petClass)
    local pos = 1
    if isPlayer then
      pos = ServerData.values.CurSelectedPlayerPetPos
    else
      pos = ServerData.values.CurSelectedEnemyPetPos
    end
    local petPos
    if req.__isplayer then
      petPos = self.PawnManager.VBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_TEAM)
    else
      petPos = self.PawnManager.VBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_ENEMY)
    end
    Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl change pet:", pos, petPos)
    local petPosMap = petPos:Get(pos)
    local params = {}
    params.inBattle = true
    local model = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(petClass, petPosMap:Abs_GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, params)
    model:InitOutScene()
    model.EnableHeadLookAt = true
    model:InitHeadLookAt()
    pet:SetModel(model)
    oldModel:K2_DestroyActor()
    pet = self.PawnManager.playerTeam.pets[1]
    if pet then
      local CameraManger = self.BattleManager.vBattleField.battleCameraManager
      pet.card.petBaseConf.pet_scale = baseconf.pet_scale
      if self.BattleManager.battleRuntimeData.operateType == BattleEnum.Operation.ENUM_SKILL then
        if req.__isplayer then
          CameraManger:CalcPos()
        else
          CameraManger:CalcPos()
        end
        CameraManger:ChangeToPlayerPet()
      end
    end
  end, function(caller, resRequest, errMsg)
    Log.Error("UMG_BattleControllerPanel_C LoadResAsync failed ModelConf.path=", ModelConf.path, errMsg)
  end)
end

function UMG_BattleControllerPanel_C:GetChangePetCMDReq(skillComBox, skillOps)
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl:GetChangePetCMDReq")
  local op = skillComBox:GetSelectedOption()
  local petId = skillOps[op]
  local baseConfId = _G.DataConfigManager:GetPetConf(petId).base_id
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.__debugChange = true
  req.__monsterConfId = monsterConfId
  req.__baseConfId = baseConfId
  return req
end

function UMG_BattleControllerPanel_C:GetSkillCMDReq(skillComBox, skillOps)
  ServerData.SetKill(self.EnableSkill:GetCheckedState() == UE4.ECheckBoxState.Checked)
  local op = skillComBox:GetSelectedOption()
  local skillId = skillOps[op]
  local petId
  local logName = "\230\136\145\230\150\185"
  if skillComBox == self.ComboBoxString then
    petId = ServerData.GetPlayerBattlePetID()
  else
    petId = ServerData.GetEnemyBattlePetID()
    logName = "\230\149\140\230\150\185"
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = skillId
  BattleRoundFlowReq.cast_skill.caster_pet_id = petId
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  local SkillConf = _G.DataConfigManager:GetSkillConf(skillId, true)
  self.LastSkillPath = SkillConf.res_id
  Log.Warning("UMG_LocalBattle_Debug_Panel_Ctrl play skill ", logName, SkillConf.res_id)
  return req
end

function UMG_BattleControllerPanel_C:Hide()
  self.DebugPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_BattleControllerPanel_C:Show()
  self.DebugPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

return UMG_BattleControllerPanel_C
