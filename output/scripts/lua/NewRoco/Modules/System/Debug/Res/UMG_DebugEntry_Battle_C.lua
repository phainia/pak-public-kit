local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_DebugEntry_Battle_C = _G.NRCPanelBase:Extend("UMG_DebugEntry_Battle_C")

function UMG_DebugEntry_Battle_C:OnActive()
  self:OnAddEventListener()
  self:OnCmdSendZoneBattleGmReq()
end

function UMG_DebugEntry_Battle_C:OnDeactive()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_DebugEntry_Battle_C:OnAddEventListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.START_BATTLE_PERFORM, BattleEvent.START_BATTLE_ATTACK, BattleEvent.BATTLE_ROUND_START)
  self:AddButtonListener(self.OpenButton, self.OnClickOpenButton)
end

function UMG_DebugEntry_Battle_C:OnTick()
end

function UMG_DebugEntry_Battle_C:OnLogin()
end

function UMG_DebugEntry_Battle_C:OnConstruct()
end

function UMG_DebugEntry_Battle_C:OnDestruct()
end

function UMG_DebugEntry_Battle_C:OnAnimationFinished(anim)
end

function UMG_DebugEntry_Battle_C:RefreshUI()
  local PlayerTeamPets = _G.BattleManager.battlePawnManager:GetPlayerTeamPets()
  local playerPet1, playerPet2 = PlayerTeamPets[1], PlayerTeamPets[2]
  local EnemyPets = _G.BattleManager.battlePawnManager:GetEnemyAllPets()
  local EnemyPet1, EnemyPet2 = EnemyPets[1], EnemyPets[2]
  self:ShowStr(playerPet1, self.TimeText_1V1, BattleEnum.Team.ENUM_TEAM)
  self:ShowStr(playerPet2, self.TimeText_2V2, BattleEnum.Team.ENUM_TEAM)
  self:ShowStr(EnemyPet1, self.TimeText_1V1_1)
  self:ShowStr(EnemyPet2, self.TimeText_2V2_1)
end

function UMG_DebugEntry_Battle_C:ShowStr(pet, TextStr, team)
  if pet then
    TextStr:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local str = self:GetStrInfoByPet(pet, team)
    TextStr:SetText(str)
  else
    TextStr:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_DebugEntry_Battle_C:GetStrInfoByPet(pet, team)
  local PetData, PetInfo
  PetInfo = self.petAttrMap[pet.guid]
  if not PetInfo then
    return
  end
  local petName = PetInfo.name
  PetData = PetInfo.battle_attr
  local hp = PetData[Enum.AttributeType.AT_HPCUR + 1]
  local attack = PetData[Enum.AttributeType.AT_PHYATK + 1]
  local specialAttack = PetData[Enum.AttributeType.AT_SPEATK + 1]
  local defense = PetData[Enum.AttributeType.AT_PHYDEF + 1]
  local specialDefense = PetData[Enum.AttributeType.AT_SPEDEF + 1]
  local speed = PetData[Enum.AttributeType.AT_SPEED + 1]
  local str = string.format("\231\178\190\231\129\181\229\144\141:%s\n\231\148\159\229\145\189:%s\n\231\137\169\230\148\187\239\188\154%s\n\233\173\148\230\148\187\239\188\154%s\n\231\137\169\233\152\178\239\188\154%s\n\233\173\148\233\152\178\239\188\154%s\n\233\128\159\229\186\166\239\188\154%s\n", petName, hp, attack, specialAttack, defense, specialDefense, speed)
  return str
end

function UMG_DebugEntry_Battle_C:OnClickOpenButton()
  self:DoClose()
end

function UMG_DebugEntry_Battle_C:OnCmdSendZoneBattleGmReq()
  local req = ProtoMessage:newZoneBattleGmReq()
  req.gm_type = ProtoEnum.ZoneBattleGmReq.BATTLE_GM_TYPE.B_GM_TYPE_QUERY
  req.gm_op_type = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_BATTLE_GM_REQ, req, self, self.RestartRsp, false, false)
end

function UMG_DebugEntry_Battle_C:RestartRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.petAttrMap = {}
    for _, pet in pairs(rsp.pets) do
      local petData = pet.battle_inside_pet_info
      self.petAttrMap[petData.pet_id] = petData
    end
    self:RefreshUI()
  end
end

function UMG_DebugEntry_Battle_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.START_BATTLE_PERFORM then
    self:OnCmdSendZoneBattleGmReq()
  elseif eventName == BattleEvent.START_BATTLE_ATTACK then
    self:OnCmdSendZoneBattleGmReq()
  elseif eventName == BattleEvent.BATTLE_ROUND_START then
    self:OnCmdSendZoneBattleGmReq()
  end
end

return UMG_DebugEntry_Battle_C
