local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabEffectsTestWorldCombat = Base:Extend("DebugTabEffectsTestWorldCombat")

function DebugTabEffectsTestWorldCombat:SetupTabs()
  self:Add("\231\148\159\230\136\144\230\138\128\232\131\189\230\181\139\232\175\149Npc", self.SpawnSkillDebugNpc, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SpawnSkillDebugNpc")
  self:Add("\230\181\139\232\175\149Npc\233\135\138\230\148\190\230\138\128\232\131\189", self.DebugNpcCastSkill, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugNpcCastSkill")
  self:Add("\233\148\128\230\175\129\230\181\139\232\175\149Npc", self.DebugDestroyNpc, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugDestroyNpc")
end

function DebugTabEffectsTestWorldCombat:SpawnSkillDebugNpc(Name, Panel, InputText)
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

function DebugTabEffectsTestWorldCombat:DebugNpcCastSkill(Name, Panel, InputText)
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

function DebugTabEffectsTestWorldCombat:DebugDestroyNpc(Name, Panel, InputText)
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

return DebugTabEffectsTestWorldCombat
