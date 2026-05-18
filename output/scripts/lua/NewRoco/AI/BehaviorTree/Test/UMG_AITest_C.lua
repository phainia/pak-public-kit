require("UnLuaEx")
local UMG_AITest_C = NRCClass()

function UMG_AITest_C:CallCtrlUserWidgetEvent(funcName, ...)
  if self.ctrl and self.ctrl[funcName] then
    return tcall(self.ctrl, self.ctrl[funcName], ...)
  elseif self.Overridden[funcName] then
    return tcall(self, self.Overridden[funcName], ...)
  end
end

function UMG_AITest_C:Construct()
  self.npcInsId = 0
end

function UMG_AITest_C:OnCommand(Text, CommitMethod)
  Log.Debug("OnCommand " .. Text .. " CommitMethod " .. tostring(CommitMethod))
  if CommitMethod == UE4.ETextCommit.OnEnter then
    local commandStr = Text
    local commandStrArr = string.Split(commandStr, " ")
    local commandArr = Array()
    for i, v in ipairs(commandStrArr) do
      commandArr:Add(v)
    end
    local commandArrCount = commandArr:Size()
    if commandArrCount > 0 then
      local command = commandArr:Get(1)
      if not string.IsNilOrEmpty(command) then
        if "CreatePet" == command then
          if commandArrCount > 1 then
            local petId = tonumber(commandArr:Get(2))
            local petCount = 1
            if commandArrCount > 2 then
              petCount = tonumber(commandArr:Get(3))
            end
            for i = 1, petCount do
              self:CreatePet(petId)
            end
          end
          return
        end
        if "PauseAI" == command then
          if commandArrCount > 1 then
            local petInsId = tonumber(commandArr:Get(2))
            local npc = SceneManager:GetNpcByConfId(petInsId)
            if npc and npc.AIController then
              npc.AIController:ForceLock(true)
            end
          else
            for k, v in pairs(SceneManager._npcDic) do
              local npc = v
              if npc and npc.AIController then
                npc.AIController:ForceLock(true)
              end
            end
          end
          return
        end
        if "ResumeAI" == command then
          if commandArrCount > 1 then
            local petInsId = tonumber(commandArr:Get(2))
            local npc = SceneManager:GetNpcByConfId(petInsId)
            if npc and npc.AIController then
              npc.AIController:ForceLock(false)
            end
          else
            for k, v in pairs(SceneManager._npcDic) do
              local npc = v
              if npc and npc.AIController then
                npc.AIController:ForceLock(false)
              end
            end
          end
          return
        end
        if "ReleaseNpc" == command then
          if commandArrCount > 1 then
            local petInsId = tonumber(commandArr:Get(2))
            local npc = SceneManager:GetNpcByConfId(petInsId)
            if npc then
              SceneManager:RemoveNpc(npc:GetServerId())
            end
          else
            for k, v in pairs(SceneManager._npcDic) do
              local npc = v
              if npc then
                SceneManager:RemoveNpc(npc:GetServerId())
              end
            end
          end
          return
        end
        if "MoveForward" == command then
          local localPlayer = SceneManager.localPlayer.viewObj
          local localPlayerPos = localPlayer:Abs_K2_GetActorLocation()
          local forward = localPlayer:GetActorForwardVector()
          local targetPos = localPlayerPos + forward * 1000
          if not localPlayer:IsMoving() then
            UE4.UAIBlueprintHelperLibrary.SimpleMoveToLocation(localPlayer:GetController(), targetPos)
          end
        end
        if "RunTestAI" == command then
          local bRunTest = true
          if commandArrCount > 1 then
            do
              local bRunTestStr = commandArr:Get(2)
              bRunTest = "true" == bRunTestStr
            end
          end
          for k, v in pairs(SceneManager._npcDic) do
            local npc = v
            if npc.AIController then
              if npc.AIController.BrainComponent then
                npc.AIController.BrainComponent:StopLogic(command)
              end
              if bRunTest then
                local btreePath = "/Game/NewRoco/AI/BehaviorTree/Test/BT_TestAI.BT_TestAI"
                local bTree = LoadObject(btreePath)
                if not bTree then
                  Log.Debug("Load btree failed")
                  return
                end
                npc.AIController:RunBehaviorTree(bTree)
              else
                npc.AIController:StartAI()
              end
            end
          end
        end
      end
    end
  end
end

function UMG_AITest_C:CreatePet(PetId)
  self.npcInsId = self.npcInsId + 1
  local npcInfo = self:CreateNpcInfo(PetId)
  _G.SceneManager:CreateLocalNpc(npcInfo, 0)
end

function UMG_AITest_C:CreateNpcInfo(npcId)
  local npcInfo = ProtoMessage:newSceneNPCInfo()
  npcInfo.id = self.npcInsId
  npcInfo.conf_id = npcId
  npcInfo.status = 0
  npcInfo.pos = ProtoMessage:newPosition()
  local player = SceneManager.localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.pos.x = player.X + math.random(50, 150)
  npcInfo.pos.y = player.Y + math.random(50, 150)
  npcInfo.pos.z = player.Z + 50
  npcInfo.act_info = ProtoMessage:newSceneNPCACTInfo()
  npcInfo.area_id = 1001025
  npcInfo.bit_flag = 0
  npcInfo.level = 0
  npcInfo.rand = 1
  npcInfo.perform_info = ProtoMessage:newNPCPerformInfo()
  return npcInfo
end

return UMG_AITest_C
