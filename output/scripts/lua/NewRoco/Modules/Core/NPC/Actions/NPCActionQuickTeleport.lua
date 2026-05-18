local pb = require("pb")
local QuickTeleport = require("NewRoco.Modules.Core.Scene.Common.QuickTeleport")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionQuickTeleport = Base:Extend("NPCActionQuickTeleport")

function NPCActionQuickTeleport:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionQuickTeleport:OnNpcAction()
  if self.Worker and self.Worker.Teleporting then
    return false
  end
  return Base.OnNpcAction(self)
end

function NPCActionQuickTeleport:Execute()
  Base.Execute(self)
  local Raw = string.split(self.Config.action_param1, ";")
  if string.IsNilOrEmpty(Raw) then
    self:Finish(false)
    return
  end
  for i = 1, #Raw do
    Raw[i] = tonumber(Raw[i]) or 0
  end
  self.DestPos = UE.FVector(Raw[1] or 0, Raw[2] or 0, Raw[3] or 0)
  if #Raw > 3 then
    self.DestRot = UE.FRotator(Raw[5] or 0, Raw[6] or 0, Raw[4] or 0)
    local Player = self:GetPlayer()
    Player:SetActorRotation(self.DestRot)
  end
  local TP = QuickTeleport()
  TP.Block = true
  TP.SendReq = false
  self.Worker = TP
  TP:Go(self.DestPos, self, self.OnTeleportFinish)
end

function NPCActionQuickTeleport:OnTeleportFinish(Success)
  if Success then
    self:Finish(true)
  else
    self.bIsSuccess = false
    local Rsp = ProtoMessage:newZoneSceneNpcNextActRsp()
    Rsp.ret_info.ret_code = 0
    Base.OnCommit(self, Rsp)
  end
end

function NPCActionQuickTeleport:FillCommit(req)
  local Player = self:GetPlayer()
  local ExtraData = _G.ProtoMessage:newPointList()
  table.insert(ExtraData.points, Player:GetServerPoint())
  local Encoded = pb.encode(".Next.PointList", ExtraData)
  req.extra_data = Encoded
end

function NPCActionQuickTeleport:OnCommit(rsp)
  Base.OnCommit(self, rsp)
  self.Worker = false
end

function NPCActionQuickTeleport:OnMoveRsp(Rsp)
  self:Log("MoveRsp", Rsp.ret_info.ret_code)
end

return NPCActionQuickTeleport
