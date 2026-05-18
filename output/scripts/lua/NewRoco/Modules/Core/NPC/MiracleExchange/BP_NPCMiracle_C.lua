require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCMiracle_C = Base:Extend("BP_NPCMiracle_C")

function BP_NPCMiracle_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCMiracle_C:OnLoadResource()
  local ballId = 100002
  if self.sceneCharacter then
    local info = self.sceneCharacter.serverData.miracle_change_info
    if info and info.ball_cfg_id and info.ball_cfg_id > 0 then
      ballId = info.ball_cfg_id
    else
      Log.Warning("BP_NPCMiracle_C:OnLoadResource ball_cfg_id == 0")
    end
  end
  self:LoadBall(ballId)
  Base.OnLoadResource(self)
end

function BP_NPCMiracle_C:LoadBall(ballId)
  local ballCfg = _G.DataConfigManager:GetBallConf(ballId)
  if not ballCfg then
    Log.ErrorFormat("\229\146\149\229\153\156\231\144\131\233\133\141\231\189\174\228\184\186\231\169\186 %d", ballId)
    return
  end
  local npcConfig = _G.DataConfigManager:GetNpcConf(ballCfg.npc_id)
  if not npcConfig then
    Log.ErrorFormat("\229\146\149\229\153\156\231\144\131\233\133\141\231\189\174\229\175\185\229\186\148\231\154\132NPC\233\133\141\231\189\174\228\184\186\231\169\186 %d", ballId)
    return
  end
  local model_Cfg_id = npcConfig.model_conf
  local modelConf = _G.DataConfigManager:GetModelConf(model_Cfg_id)
  if not modelConf then
    Log.ErrorFormat("\229\146\149\229\153\156\231\144\131\233\133\141\231\189\174\229\175\185\229\186\148\231\154\132NPC\233\133\141\231\189\174\231\154\132ModelCfg\228\184\186\231\169\186 %d", ballId)
    return
  end
  self.BallChildActor:SetPath(modelConf.path)
  local ball = self.BallChildActor:GetChildActor()
  if ball then
    ball:SetActorEnableCollision(false)
    ball:InitOutSceneAsync()
  end
end

function BP_NPCMiracle_C:Recycle()
  local ball = self.BallChildActor:GetChildActor()
  if ball then
    NRCResourceManager:UnLoadResByCaller(ball)
  end
  self.BallChildActor:SetChildActorClass(nil)
  Base.Recycle(self)
end

return BP_NPCMiracle_C
