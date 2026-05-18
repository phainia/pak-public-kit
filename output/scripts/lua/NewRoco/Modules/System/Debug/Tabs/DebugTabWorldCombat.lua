local WorldCombatBuffComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffComponent")
local LogicStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.LogicStatusComponent")
local WorldCombatModuleCmd = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleCmd")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local JsonUtils = require("Common.JsonUtils")
local Base = DebugTabBase
local DebugTabWorldCombat = Base:Extend("DebugTabWorldCombat")

function DebugTabWorldCombat:Ctor()
  Base.Ctor(self)
end

function DebugTabWorldCombat:SetupTabs()
end

function DebugTabWorldCombat:FakeBegin(Name, Panel)
  local Payload = _G.ProtoMessage:newSpaceAct_WorldCombatEnter()
  Payload.world_combat_id = 1
  Payload.avatar_id = 0
  Payload.world_combat_phase = 0
  _G.NRCModuleManager:DoCmd(WorldCombatModuleCmd.WorldCombatEnter, Payload, nil, nil)
end

function DebugTabWorldCombat:FakeEnd(Name, Panel)
  local Payload = _G.ProtoMessage:newSpaceAct_WorldCombatExit()
  Payload.world_combat_id = 1
  Payload.avatar_id = 0
  _G.NRCModuleManager:DoCmd(WorldCombatModuleCmd.WorldCombatExit, Payload, nil, nil)
end

function DebugTabWorldCombat:OpenLogicStatusLog(Name, Panel)
  LogicStatusComponent.Debug = true
end

function DebugTabWorldCombat:CloseLogicStatusLog(Name, Panel)
  LogicStatusComponent.Debug = false
end

function DebugTabWorldCombat:OpenBuffLog(Name, Panel)
  WorldCombatBuffComponent.Debug = true
end

function DebugTabWorldCombat:CloseBuffLog(Name, Panel)
  WorldCombatBuffComponent.Debug = false
end

function DebugTabWorldCombat:VisualizeAirWall(Name, Panel)
  local Module = self:GetModule("AirWallModule")
  for _, AirWall in pairs(Module.AirWalls) do
    AirWall:MakeDebugWall()
  end
  local Klass = UE.UClass.Load("/Game/NewRoco/Modules/System/WorldCombat/AirWalls/BP_AirWall_Dungeon.BP_AirWall_Dungeon")
  local World = _G.UE4Helper.GetCurrentWorld()
  local Actors = UE.UGameplayStatics.GetAllActorsOfClass(World, Klass)
  for _, Wall in tpairs(Actors) do
    if Wall.ToggleDebug then
      Wall.UseDebugMaterial = true
      Wall:ToggleDebug()
    end
  end
end

function DebugTabWorldCombat:CreateAirWall(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.CreateWall, self:GetInputNumber(121030062), false)
end

function DebugTabWorldCombat:CheckSkillNonMD5(Name, Panel, InputText)
  local inputText = ""
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local skillIds = {}
  if "" == inputText then
    local WorldCombatSkillConf = _G.DataConfigManager:GetAllByTableID(_G.DataConfigManager.ConfigTableId.WORLD_COMBAT_SKILL_CONF)
    for _, skillConf in pairs(WorldCombatSkillConf) do
      if skillConf.skill_ref and "" ~= skillConf.skill_ref then
        table.insert(skillIds, skillConf.id)
      end
    end
  else
    for w in string.gmatch(inputText, "%S+") do
      if tonumber(w) then
        table.insert(skillIds, tonumber(w))
      end
    end
  end
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = ProtoEnum.SceneGmType.SGT_DOTS_SKILL_MD5
  req.rpt_params = skillIds
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, self, function(this, rsp)
    if 0 ~= rsp.ret_info.ret_code then
      Log.Error("CheckSkillNonMD5Rsp Failed!!!")
      return
    end
    local serverMD5s = {}
    for _, serverMD5 in ipairs(string.split(rsp.ret_value, ";")) do
      serverMD5 = string.gsub(serverMD5, "[^%w]", "")
      table.insert(serverMD5s, serverMD5)
    end
    local md5 = JsonUtils.LoadBinMD5Non()
    local bMatchServer = true
    local wrongSkills = {}
    for idx, skillId in pairs(skillIds) do
      local skillConf = _G.DataConfigManager:GetWorldCombatSkillConf(skillId, true)
      local skillPath = skillConf.skill_ref
      if not skillPath or "" == skillPath then
      else
        local skillName
        for name in string.gmatch(skillPath, "[^/]+") do
          skillName = name
        end
        if not skillName then
        else
          local clientMD5 = md5[skillName]
          local serverMD5 = serverMD5s[idx]
          if clientMD5 and "" ~= serverMD5 and clientMD5 ~= serverMD5 or clientMD5 and "" == serverMD5 or not clientMD5 and "" ~= serverMD5 then
            bMatchServer = false
            local wrongSkill = {
              skillId,
              skillName,
              clientMD5,
              serverMD5
            }
            table.insert(wrongSkills, wrongSkill)
          end
        end
      end
    end
    if not bMatchServer then
      for idx, wrongSkill in pairs(wrongSkills) do
        DelayManager:DelaySeconds((idx - 1) * 2.1, function()
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\229\143\140\231\171\175\230\138\128\232\131\189\229\173\152\229\156\168\228\184\141\228\184\128\232\135\180\239\188\129\230\138\128\232\131\189id: %d, \230\138\128\232\131\189\229\144\141\231\167\176: %s, \n\229\174\162\230\136\183\231\171\175md5: %s, \n\230\156\141\229\138\161\229\153\168md5: %s", wrongSkill[1], wrongSkill[2], wrongSkill[3], wrongSkill[4]), nil, nil, 2)
        end)
        Log.Debug("CheckSkillNonMD5Rsp Failed!!!", wrongSkill[1], wrongSkill[2], wrongSkill[3], wrongSkill[4])
      end
    end
  end, false, true)
end

function DebugTabWorldCombat:SpawnSkillDebugNpc(Name, Panel, InputText)
  local World = UE4Helper.GetCurrentWorld()
  if not World or not UE.UObject.IsValid(World) then
    return
  end
  local Controller = UE.UGameplayStatics.GetPlayerController(World, 0)
  if not Controller or not UE.UObject.IsValid(Controller) then
    return
  end
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if string.IsNilOrEmpty(inputText) then
    Log.Error("SpawnSkillDebugNpc Failed!!! \232\175\183\232\190\147\229\133\165\233\156\128\232\166\129\231\148\159\230\136\144NPC\231\154\132ID!")
    return
  end
  local inputTextArr = string.Split(inputText, " ")
  local npcId = tonumber(inputTextArr[1])
  local npcPos
  if #inputTextArr >= 2 then
    string.gsub(inputTextArr[2], " ", "")
    local posX, posY, posZ = inputTextArr[2]:match("=*(-*%d+%.%d*),%a*=*(-*%d+%.%d*),%a*=*(-*%d+%.%d*)")
    npcPos = UE.FVector(posX or 0, posY or 0, posZ or 0)
  end
  local yaw = tonumber(inputTextArr[3]) or 0
  local skillId = tonumber(inputTextArr[4]) or 0
  Controller:DebugSpawnNpc(npcId, npcPos, yaw, skillId)
end

function DebugTabWorldCombat:DebugNpcCastSkill(Name, Panel, InputText)
  local World = UE4Helper.GetCurrentWorld()
  if not World or not UE.UObject.IsValid(World) then
    return
  end
  local Controller = UE.UGameplayStatics.GetPlayerController(World, 0)
  if not Controller or not UE.UObject.IsValid(Controller) then
    return
  end
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if string.IsNilOrEmpty(inputText) then
    Log.Error("SpawnSkillDebugNpc Failed!!! \232\175\183\232\190\147\229\133\165\233\156\128\232\166\129\230\181\139\232\175\149\231\154\132ActorID!")
    return
  end
  local inputTextArr = string.Split(inputText, " ")
  if #inputTextArr < 2 then
    Log.Error("DebugNpcCastSkill Failed!!! \232\175\183\232\190\147\229\133\165\233\156\128\232\166\129\230\181\139\232\175\149\231\154\132\230\138\128\232\131\189ID!")
    return
  end
  local actorId = tonumber(inputTextArr[1]) or 0
  local skillId = tonumber(inputTextArr[2]) or 0
  local targetId = tonumber(inputTextArr[3]) or 0
  local creatureSkillId = 0
  local recycleUse = false
  local interval = 0
  local skillStart = 0
  local skillEnd = 0
  local skillRange = {}
  if #inputTextArr >= 4 then
    string.gsub(inputTextArr[4], " ", "")
    for idx = 4, #inputTextArr do
      local creatureSkillIdTemp = inputTextArr[idx]:match("creater_skill_id=(%d+)")
      if creatureSkillIdTemp then
        creatureSkillId = tonumber(creatureSkillIdTemp) or 0
      end
      local recycleUseTemp, intervalTemp = inputTextArr[idx]:match("cycle_use=(%S+),(%S+)")
      if recycleUseTemp and intervalTemp then
        recycleUse = _G.toBool(recycleUseTemp)
        interval = tonumber(intervalTemp) or 0
      end
      local skillStartTemp, skillEndTemp = inputTextArr[idx]:match("skill_range=(%d+),(%d+)")
      if skillStartTemp and skillEndTemp then
        skillStart = tonumber(skillStartTemp) or 0
        skillEnd = tonumber(skillEndTemp) or 0
      end
    end
    if skillStart and skillEnd then
      skillRange = {skillStart, skillEnd}
    end
  end
  Controller:DebugCastSkill(actorId, skillId, targetId, creatureSkillId, recycleUse, interval, skillRange)
end

function DebugTabWorldCombat:DebugDestroyNpc(Name, Panel, InputText)
  local World = UE4Helper.GetCurrentWorld()
  if not World or not UE.UObject.IsValid(World) then
    return
  end
  local Controller = UE.UGameplayStatics.GetPlayerController(World, 0)
  if not Controller or not UE.UObject.IsValid(Controller) then
    return
  end
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if string.IsNilOrEmpty(inputText) then
    Log.Error("DebugDestroyNpc Failed!!! \232\175\183\232\190\147\229\133\165\233\156\128\232\166\129\231\167\187\233\153\164\231\154\132ActorID!")
    return
  end
  local inputTextArr = string.Split(inputText, " ")
  local actorId = tonumber(inputTextArr[1]) or 0
  Controller:DebugDestroyNpc(actorId)
end

function DebugTabWorldCombat:ToggleWeakLog()
  _G.GlobalConfig.BossHitLog = not _G.GlobalConfig.BossHitLog
  if _G.GlobalConfig.BossHitLog then
    Log.Error("boss\229\188\177\231\130\185\230\151\165\229\191\151\229\183\178\229\188\128\229\144\175")
  else
    Log.Error("boss\229\188\177\231\130\185\230\151\165\229\191\151\229\183\178\229\133\179\233\151\173")
  end
end

function DebugTabWorldCombat:ToggleEditorPerformanceImprovement()
  _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.ToggleEditorPerformanceImprovement)
end

return DebugTabWorldCombat
