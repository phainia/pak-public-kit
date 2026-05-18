local ExplodeActorComponent = require("NewRoco.Modules.Core.NPC.ViewNPCComponent.ExplodeActorComponent")
local ZVelocityModule = require("NewRoco.Modules.Core.NPC.Velocity.ZVelocityModule")
local CylinderModule = require("NewRoco.Modules.Core.NPC.Velocity.CylinderVelocityModule")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BattleNPCGenerator = Class()

function BattleNPCGenerator:Ctor()
  self.ActorEmitter = ExplodeActorComponent()
  local ZModule = ZVelocityModule(0.8, 1)
  local CModule = CylinderModule(0.1, 0.1)
  self.ActorEmitter:AddForceModule(ZModule)
  self.ActorEmitter:AddForceModule(CModule)
  self.ActorEmitter.force = 4500
end

function BattleNPCGenerator:SetCreateNPCTotalNum(num)
  self.createNum = num
  self.createdNPC = {}
end

function BattleNPCGenerator:ReSetCreateNPCTotalNum(num)
  Log.Debug("BattleNPCGenerator:ReSetCreateNPCTotalNum")
  self.createNum = num
  if #self.createdNPC == self.createNum then
    Log.Debug("\229\136\155\229\187\186\229\174\140\230\175\149, \230\149\176\233\135\143\239\188\154" .. tostring(self.createNum))
    self:Show()
  end
end

function BattleNPCGenerator:SetPos(pos)
  self.ActorEmitter.startPos = SceneUtils.GetPosInLand(pos, 60) or pos
end

function BattleNPCGenerator:Show()
  Log.Debug("BattleNPCGenerator:Show")
  self.ActorEmitter:Explode(self.createdNPC)
  self.createdNPC = {}
  self.createNum = nil
end

function BattleNPCGenerator:SetCreateNPC(npc)
  Log.Debug("BattleNPCGenerator:SetCreateNPC")
  if not npc.viewObj then
    npc:CreateView(false)
  end
  if not self.createdNPC then
    Log.Warning("BattleNPCGenerator:SetCreateNPC \228\184\141\229\186\148\232\175\165\230\156\137\231\154\132\230\131\133\229\134\181\239\188\140\229\137\141\233\157\162\230\156\170\233\128\154\231\159\165\230\142\137\232\144\189\230\149\176\233\135\143")
    return
  end
  table.insert(self.createdNPC, npc.viewObj)
  if #self.createdNPC == self.createNum then
    self:Show()
  end
end

return BattleNPCGenerator
