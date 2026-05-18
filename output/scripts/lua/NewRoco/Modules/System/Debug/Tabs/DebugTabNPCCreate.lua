local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabNPCCreate = Base:Extend("DebugTabNPCCreate")

function DebugTabNPCCreate:Ctor(...)
  Base.Ctor(self, ...)
  self.needRefresh = true
end

local CanCreateType = {
  [Enum.RefreshType.RFT_BYTAG] = true,
  [Enum.RefreshType.RFT_BYTAGID] = true,
  [Enum.RefreshType.RFT_AREA] = true,
  [Enum.RefreshType.RFT_AREA_NEAREST] = true
}

function DebugTabNPCCreate:SetupTabs()
  local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
  if not SceneModule then
    return
  end
  local SceneID = SceneUtils.GetSceneID()
  if nil == SceneID then
    return
  end
  local RefreshType, NpcID, NPC_CONF, AreaID
  local NPC_REFRESH_CONTENT_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NPC_REFRESH_CONTENT_CONF):GetAllDatas()
  for _, RefreshConf in pairs(NPC_REFRESH_CONTENT_CONF) do
    if RefreshConf.disable then
    else
      RefreshType = RefreshConf.refresh_type
      if not CanCreateType[RefreshType] then
      else
        NpcID = RefreshConf.npc_id
        if 0 == NpcID then
        else
          NPC_CONF = _G.DataConfigManager:GetNpcConf(NpcID)
          if not NPC_CONF then
          else
            AreaID = RefreshConf.refresh_param
            if not AreaID or 0 == AreaID then
            else
              if RefreshType == Enum.RefreshType.RFT_BYTAG or RefreshType == Enum.RefreshType.RFT_BYTAGID then
                local SceneObjConf = _G.DataConfigManager:GetSceneObjectConf(AreaID)
                if not SceneObjConf or SceneObjConf.scene_cfg_id ~= SceneID then
                  goto lbl_108
                end
              else
                local AreaConf = _G.DataConfigManager:GetAreaConf(AreaID)
                if nil == AreaConf then
                  goto lbl_108
                end
                if AreaConf.scene_id ~= SceneID then
                  goto lbl_108
                end
              end
              self:Add(string.format([[
NPC:%s
%s
%s]], NPC_CONF.name, NpcID, RefreshConf.id), function(this)
                this:DebugCreateNPC(NpcID, RefreshConf.id)
              end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\160\185\230\141\174ID\229\136\155\229\187\186NPC")
            end
          end
        end
      end
    end
    ::lbl_108::
  end
end

function DebugTabNPCCreate:DebugCreateNPC(ID, RefreshID)
  local flag = SceneUtils.debugCloseCreateNPC
  SceneUtils.debugCloseCreateNPC = false
  self:InterDebugCreateNPC(ID, RefreshID)
  _G.DelayManager:DelaySeconds(1.5, self.ToggleCreateFlag, self, flag)
end

function DebugTabNPCCreate:ToggleCreateFlag(flag)
  SceneUtils.debugCloseCreateNPC = flag
end

function DebugTabNPCCreate:InterDebugCreateNPC(id, refreshID)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocationFrameCache()
  local Rot = Player:GetActorRotationFrameCache()
  local Point = ProtoMessage:newPoint()
  Pos = Pos + Rot:RotateVector(UE.FVector(300, 0, 0))
  Point.pos.x = math.round(Pos.X)
  Point.pos.y = math.round(Pos.Y)
  Point.pos.z = math.round(Pos.Z)
  local Rotator = Rot:ToRotator()
  Point.dir.z = math.round((-Rotator.Yaw or 0) * 10)
  Point.dir.x = 0
  Point.dir.y = 0
  local req = ProtoMessage:newZoneGmCreateNpcReq()
  req.content_cfg_id = refreshID
  req.npc_pos = Point
  req.only_test = self:GetInputNumber(0) > 0
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, self, self.OnServerCreateDebugNPC)
end

function DebugTabNPCCreate:OnServerCreateDebugNPC(rsp)
end

function DebugTabNPCCreate:Explode(Name, Panel)
  local ContentID = self:GetInputNumber()
  local Module = _G.NRCModuleManager:GetModule("NPCModule")
  local Runner = Module.EQSManager:Get("Spiral")
  local Request = Runner:MakeRequest(nil, self:GetPlayer().viewObj)
  Runner.ContentID = ContentID
  self.Runner = Runner
  Runner:StartQueryWithRequest(UE.EEnvQueryRunMode.AllMatching, Request, self, self.CreateNPC)
end

function DebugTabNPCCreate:CreateNPC(Result)
  local Content = self.Runner.ContentID
  Log.Error("Show Content", Content)
  self.Runner = nil
  if not Result.bFinished or not Result.bSuccess then
    return
  end
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerPos = Player:GetActorLocationFrameCache()
  for _, Pos in tpairs(Result.AbsoluteResultLocations) do
    local Point = ProtoMessage:newPoint()
    Point.pos.x = math.round(Pos.X)
    Point.pos.y = math.round(Pos.Y)
    Point.pos.z = math.round(Pos.Z)
    local LookAt = PlayerPos - Pos
    local Rotator = LookAt:ToRotator()
    Point.dir.z = math.round((-Rotator.Yaw or 0) * 10)
    Point.dir.x = 0
    Point.dir.y = 0
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.content_cfg_id = Content
    req.npc_pos = Point
    req.only_test = false
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, false)
  end
end

return DebugTabNPCCreate
