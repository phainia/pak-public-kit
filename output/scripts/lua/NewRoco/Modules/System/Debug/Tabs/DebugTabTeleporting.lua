local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DebugTabTeleporting = Base:Extend("DebugTabTeleporting")

function DebugTabTeleporting:Ctor()
  Base.Ctor(self)
end

function DebugTabTeleporting:SetupTabs()
  local world = _G.UE4Helper.GetCurrentWorld()
  local foundActors = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(world, UE4.AActor, "--poi--"):ToTable()
  for i = 1, #foundActors do
    local curActor = foundActors[i]
    self:Add(curActor:GetName(), self.MoveToTestActor, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\159\144\231\167\141\228\188\160\233\128\129\230\128\167\232\131\189\231\148\168")
  end
end

function DebugTabTeleporting:MoveToPos(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if "" == value then
    Log.w("Please input teleport target")
    return
  end
  local inputText = value
  self:Teleport(inputText)
end

function DebugTabTeleporting:MoveToEveryWhere(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if "" == value then
    Log.w("Please input teleport target")
    return
  end
  local inputText = value
  self:Teleport(inputText)
end

function DebugTabTeleporting:MoveToTestActor(name, panel, InputText)
  local value
  if panel then
    value = panel.InputBox:GetText()
  else
    value = InputText
  end
  if "" == value and "MoveToActor" == name then
    Log.Error("Move to Nil")
    return
  else
    value = name
  end
  local cmd = string.format("AutoTestTool.MoveToTestActor %s", value)
  UE4Helper.PrintScreenMsg(cmd)
  UE4.UNRCStatics.ExecConsoleCommand(cmd)
end

function DebugTabTeleporting:Teleport(inputText)
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  if string.IsNilOrEmpty(inputText) then
    Log.w("Please input teleport target")
    return
  end
  teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  local sceneCfgIdSepPos = string.find(inputText, ";")
  local firstPosVecSepPos = string.find(inputText, ",")
  if sceneCfgIdSepPos or not firstPosVecSepPos then
    if sceneCfgIdSepPos then
      teleReq.to_scene_cfg_id = tonumber(string.sub(inputText, 1, sceneCfgIdSepPos - 1))
      inputText = string.sub(inputText, sceneCfgIdSepPos + 1)
    else
      teleReq.to_scene_cfg_id = tonumber(inputText)
      inputText = ""
    end
  end
  local posVecs = string.split(inputText, ",")
  local posVecsLen = #posVecs
  local toPoint = teleReq.to_point
  if posVecsLen >= 2 then
    toPoint.pos.x = tonumber(posVecs[1])
    toPoint.pos.y = tonumber(posVecs[2])
  end
  if posVecsLen >= 3 then
    toPoint.pos.z = tonumber(posVecs[3])
  end
  if posVecsLen >= 4 then
    toPoint.dir = UE.FVector(0, 0, tonumber(posVecs[4]))
  end
  Log.fd("Teleport, toSceneCfgId:%s, toPos:(%s,%s,%s), toDirZ:%s", teleReq.to_scene_cfg_id, toPoint.x, toPoint.y, toPoint.z, teleReq.to_point.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, self._OnTeleportRsp, false, true)
end

function DebugTabTeleporting:_OnTeleportRsp(rsp)
end

return DebugTabTeleporting
