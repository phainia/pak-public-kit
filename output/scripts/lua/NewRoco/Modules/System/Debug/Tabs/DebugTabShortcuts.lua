local JsonUtils = require("Common.JsonUtils")
local rapidjson = require("rapidjson")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabShortcuts = Base:Extend("DebugTabShortcuts")

function DebugTabShortcuts:Ctor()
  Base.Ctor(self)
  self.needRefresh = true
end

function DebugTabShortcuts:SetupTabs()
  self:Add("\230\183\187\229\138\160\231\142\176\229\156\168\228\189\141\231\189\174\229\136\176\232\135\170\229\174\154\228\185\137\229\136\151\232\161\168", self.AddCurrentLocation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:ShowJsonPoints()
  local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
  if not SceneModule then
    return
  end
  local SceneID = SceneUtils.GetSceneID()
  if nil == SceneID then
    return
  end
  local SCENE_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SCENE_CONF):GetAllDatas()
  for ID, SceneConf in pairs(SCENE_CONF) do
    if SceneID == ID then
      self:Add(string.format("\229\135\186\231\148\159\231\130\185:%d", SceneConf.id), function(Owner)
        self:ClosePanel()
        Owner:SetPlayerLocation(SceneConf.born_pos_x, SceneConf.born_pos_y, SceneConf.born_pos_z)
      end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\188\160\233\128\129\232\135\179\229\135\186\231\148\159\231\130\185")
    end
  end
  self:SetupTaskPoints()
  local NPC_REFRESH_CONTENT_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NPC_REFRESH_CONTENT_CONF):GetAllDatas()
  for _, RefreshConf in pairs(NPC_REFRESH_CONTENT_CONF) do
    if RefreshConf.disable then
    elseif 0 == RefreshConf.npc_id then
    elseif RefreshConf.refresh_type == Enum.RefreshType.RFT_AREA or RefreshConf.refresh_type == Enum.RefreshType.RFT_AREA_NEAREST then
      local AreaID = RefreshConf.refresh_param
      if not AreaID or 0 == AreaID then
      else
        local AreaConf = _G.DataConfigManager:GetAreaConf(AreaID, true)
        if not AreaConf then
        elseif AreaConf.scene_id ~= SceneID then
        elseif 0 == #AreaConf.pos then
        else
          local Pos = AreaConf.pos[1]
          local NPCID = RefreshConf.npc_id
          local NPC_CONF = _G.DataConfigManager:GetNpcConf(NPCID)
          if not NPC_CONF then
          else
            self:Add(string.format([[
NPC:%s
%s
%s]], NPC_CONF.name, NPCID, RefreshConf.id), function(Owner)
              self:ClosePanel()
              Owner:SetPlayerLocation(Pos.position_xyz[1] + 100, Pos.position_xyz[2] + 100, Pos.position_xyz[3] + 780)
            end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\188\160\233\128\129\232\135\179NPC")
          end
        end
      end
    elseif RefreshConf.refresh_type == Enum.RefreshType.RFT_BYTAGID then
      local objectId = RefreshConf.refresh_param
      if not objectId or 0 == objectId then
      else
        local SceneObjectConf = _G.DataConfigManager:GetSceneObjectConf(objectId, true)
        if not SceneObjectConf then
        elseif SceneObjectConf.scene_cfg_id ~= SceneID then
        else
          local Pos = SceneObjectConf.position_xyz
          local NPCID = RefreshConf.npc_id
          local NPC_CONF = _G.DataConfigManager:GetNpcConf(NPCID)
          if not NPC_CONF then
          else
            self:Add(string.format([[
NPC:%s
%s
%s]], NPC_CONF.name, NPCID, RefreshConf.id), function(Owner)
              self:ClosePanel()
              Owner:SetPlayerLocation(Pos[1] + 100, Pos[2] + 100, Pos[3] + 780)
            end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\188\160\233\128\129\232\135\179NPC")
          end
        end
      end
    end
  end
end

function DebugTabShortcuts:SetupTaskPoints(Name, Panel)
  local Module = NRCModuleManager:GetModule("TaskModule")
  if not Module then
    return
  end
  local Data = Module:GetData("TaskModuleData")
  if not Data then
    return
  end
  for ID, Task in pairs(Data.TaskMap) do
    if Task.Trackers then
      for Index, TrackItem in ipairs(Task.Trackers) do
        local Pos = TrackItem:GetPosition()
        if Pos then
          self:Add(string.format("\228\187\187\229\138\161:%s\n%d", Task.Config.name, Index), function(Owner)
            Owner:SetPlayerLocation(Pos.X, Pos.Y, Pos.Z + 780)
          end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\188\160\233\128\129\232\135\179\228\187\187\229\138\161")
        end
      end
    end
  end
end

function DebugTabShortcuts:ShowJsonPoints()
  local Points = JsonUtils.LoadSaved("Shortcuts")
  if not Points then
    return
  end
  for Key, Point in pairs(Points) do
    self:Add(string.format("\232\135\170\229\174\154\228\185\137:%s", Key), function(Owner)
      Owner:SetPlayerLocation(Point[1], Point[2], Point[3] + 780)
      self.Panel:DoClose()
    end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\228\188\160\233\128\129\232\135\179\232\135\170\229\174\154\228\185\137")
  end
end

function DebugTabShortcuts:AddCurrentLocation(Name, Panel, InputText)
  local Points = JsonUtils.LoadSaved("Shortcuts", {})
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Location = Player:GetActorLocation()
  local Key
  if Panel then
    Key = Panel.InputBox:GetText()
  else
    Key = InputText
  end
  if string.IsNilOrEmpty(Key) then
    Key = os.date("%Y%m%d%H%M%S")
  end
  Points[Key] = {
    Location.X,
    Location.Y,
    Location.Z
  }
  JsonUtils.DumpSaved("Shortcuts", Points)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\229\157\144\230\160\135\231\130\185'%s'\229\183\178\232\174\176\229\189\149", Key))
  if Panel then
    Panel:DoClose()
  end
end

return DebugTabShortcuts
