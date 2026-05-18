local ServerAICommandEnum = require("NewRoco.Modules.Core.Scene.Component.AI.ServerAICommandEnum")
local SceneAnimEnum = require("NewRoco.Modules.Core.Scene.Common.SceneAnimEnum")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ServerAIDebugger = _G.Class("ServerAIDebugger")

function ServerAIDebugger:Ctor()
  self.comp = nil
  self.ticking = false
end

local EventMap = {}
local binded = false

function ServerAIDebugger.BindFunc()
  if binded then
    return
  end
  EventMap[ServerAICommandEnum.ServerAICommandEvent.PlayAnimation] = ServerAIDebugger._PlayAnimation
  EventMap[ServerAICommandEnum.ServerAICommandEvent.StopAnimation] = ServerAIDebugger._StopAnimation
  EventMap[ServerAICommandEnum.ServerAICommandEvent.AnimPauseOrResume] = ServerAIDebugger._AnimPauseOrResume
  EventMap[ServerAICommandEnum.ServerAICommandEvent.ServerMove] = ServerAIDebugger._ServerMove
  EventMap[ServerAICommandEnum.ServerAICommandEvent.InterruptServerMove] = ServerAIDebugger._InterruptServerMove
  EventMap[ServerAICommandEnum.ServerAICommandEvent.TurnTo] = ServerAIDebugger._TurnTo
  EventMap[ServerAICommandEnum.ServerAICommandEvent.CancelTurnTo] = ServerAIDebugger._CancelTurnTo
  EventMap[ServerAICommandEnum.ServerAICommandEvent.WorldAttack] = ServerAIDebugger._WorldAttack
  EventMap[ServerAICommandEnum.ServerAICommandEvent.StopWorldAttack] = ServerAIDebugger._StopWorldAttack
  EventMap[ServerAICommandEnum.ServerAICommandEvent.PlayPerceptionEffect] = ServerAIDebugger._PlayPerceptionEffect
  EventMap[ServerAICommandEnum.ServerAICommandEvent.PlayPerceptionHud] = ServerAIDebugger._PlayPerceptionHud
  EventMap[ServerAICommandEnum.ServerAICommandEvent.ServerAttach] = ServerAIDebugger._ServerAttach
  EventMap[ServerAICommandEnum.ServerAICommandEvent.CancelServerAttach] = ServerAIDebugger._CancelServerAttach
  EventMap[ServerAICommandEnum.ServerAICommandEvent.PlaySkill] = ServerAIDebugger._PlaySkill
  EventMap[ServerAICommandEnum.ServerAICommandEvent.StopSkill] = ServerAIDebugger._StopSkill
  binded = true
end

function ServerAIDebugger:Bind(comp)
  self.comp = comp
  self.ticking = false
  self.BindFunc()
end

function ServerAIDebugger:Unbind()
  self:EnableTick(false)
  self.comp = nil
end

local localGetWorld = _G.UE4Helper.GetCurrentWorld

function ServerAIDebugger:NewFrame(deltatime)
  self.deltatime = deltatime
  self.duration = deltatime * 3
  self.location = self.comp.owner:GetActorLocation()
  self.world = localGetWorld()
end

local Color_Compensation = UE.FLinearColor(1, 0.5, 0, 1)

function ServerAIDebugger:OnTick(deltatime)
  self:NewFrame(deltatime)
  self:DrawQueue()
  self:DrawMoves()
  self:DrawLineStatus(self.comp.timeCompensation, 200, 5, Color_Compensation)
end

function ServerAIDebugger:DrawQueue()
  local queue = self.comp:GetEventQueue()
  local queueCount = 0
  for _, event in queue:pairs() do
    queueCount = queueCount + 1
    if EventMap[event.command_enum] then
      EventMap[event.command_enum](self, event.server_data, queueCount)
    end
  end
  if self.comp.MoveCache then
    EventMap[ServerAICommandEnum.ServerAICommandEvent.ServerMove](self, self.comp.MoveCache, queueCount)
  end
end

local Color_Reached = UE.FLinearColor(0.2, 1, 0.2, 1)
local Color_Future = UE.FLinearColor(1, 0.2, 0.2, 1)
local Color_ServerDesire = UE.FLinearColor(1, 0.5, 0.5, 1)
local Color_Error = UE.FLinearColor(1, 0, 0, 1)

function ServerAIDebugger:DrawMoves()
  if self.comp.isServerMoving then
    local from = self.location
    local to
    local idx_now = self.comp:DesiredServerMoveIdx(self.comp:GetCurrentTime())
    for _, pos in ipairs(self.comp.cacheServerMoveReq.to_pos_list) do
      if 1 == _ then
        to = UE4.FVector(pos.x, pos.y, pos.z + 60)
        self:DrawLineRoute(from, to, 1, Color_Error)
      else
        local color = Color_ServerDesire
        if _ < self.comp.currentSvrMoveIdx then
          color = Color_Reached
        end
        if _ > idx_now then
          color = Color_Future
        end
        from = to
        to = UE4.FVector(pos.x, pos.y, pos.z + 60)
        self:DrawLineRoute(from, to, _ == self.comp.currentSvrMoveIdx and 10 or 5, color)
      end
    end
  end
end

function ServerAIDebugger:DrawLineStatus(length, offsetZ, thick, color)
  UE.UKismetSystemLibrary.Abs_DrawDebugLine(self.world, self.location + UE.FVector(0, 0, offsetZ), self.location + UE.FVector(0, 0, offsetZ + length), color or UE.FLinearColor(1, 0.5, 0, 1), self.duration, thick)
end

function ServerAIDebugger:DrawLineRoute(from, to, thick, color)
  UE.UKismetSystemLibrary.Abs_DrawDebugLine(self.world, from, to, color, self.duration, thick)
end

function ServerAIDebugger:DrawPoint(vec, size, color, text)
  UE.UKismetSystemLibrary.Abs_DrawDebugSphere(self.world, vec, size, 6, color, self.duration, 2)
  if text then
    self:DrawText(vec + UE.FVector(0, size * 2, 0), color, text)
  end
end

function ServerAIDebugger:DrawText(vec, color, text)
  UE.UKismetSystemLibrary.Abs_DrawDebugString(self.world, vec, text, nil, color, self.duration)
end

function ServerAIDebugger:EnableTick(enable)
  if self.ticking ~= enable then
    self.ticking = enable
    if enable then
      _G.UpdateManager:Register(self, true)
    else
      _G.UpdateManager:UnRegister(self)
    end
  end
end

local EventQueueOffset = 200

function ServerAIDebugger:_PlayAnimation(action, idx)
  local animName = SceneAnimEnum.AnimationNameRev[action.anim_id]
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 8, UE.FLinearColor(0, 1, 1, 1), animName)
end

function ServerAIDebugger:_StopAnimation(action, idx)
  local animName = SceneAnimEnum.AnimationNameRev[action.anim_id]
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 6, UE.FLinearColor(0, 0.5, 0.5, 1), animName)
end

function ServerAIDebugger:_AnimPauseOrResume(action, idx)
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), action.is_anim_pause and 8 or 6, UE.FLinearColor(0, 0.7, 0.8, 1))
end

function ServerAIDebugger:_TurnTo(action, idx)
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 8, UE.FLinearColor(0.4, 1, 0, 1))
  local LineStart = self.location
  local LineEnd = SceneUtils.ServerPos2ClientPos(action.turn_pos)
  self:DrawLineRoute(LineStart, LineEnd, 1, UE.FLinearColor(0.4, 1, 0, 1))
end

function ServerAIDebugger:_CancelTurnTo(action, idx)
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 6, UE.FLinearColor(0.32, 0.8, 0, 1))
end

function ServerAIDebugger:_PlaySkill(action, idx)
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 8, UE.FLinearColor(0, 1, 0.66, 1), action.skill_path or tostring(action.skill_id))
end

function ServerAIDebugger:_StopSkill(action, idx)
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 6, UE.FLinearColor(0, 0.5, 0.33, 1), action.skill_path or tostring(action.skill_id))
end

function ServerAIDebugger:_ServerMove(action, idx)
  self:DrawPoint(self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20), 8, UE.FLinearColor(1, 0, 0, 1))
  local from, to
  for _, pos in ipairs(action.to_pos_list) do
    if 1 == _ then
      to = UE4.FVector(pos.x, pos.y, pos.z + 40)
    else
      from = to
      to = UE4.FVector(pos.x, pos.y, pos.z + 40)
      self:DrawLineRoute(from, to, 3, UE.FLinearColor(1, 0, 0, 1))
    end
  end
end

function ServerAIDebugger:_InterruptServerMove(action, idx)
  local from = self.location + UE.FVector(0, 0, EventQueueOffset + idx * 20)
  self:DrawPoint(from, 6, UE.FLinearColor(0.5, 0, 0, 1))
  local pos = action.interrupt_point
  self:DrawLineRoute(from, UE.FVector(pos.pos.x, pos.pos.y, pos.pos.z), 1, UE.FLinearColor(0.5, 0, 0, 1))
end

return ServerAIDebugger
