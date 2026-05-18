local Class = _G.MakeSimpleClass
local SceneDataModel = Class("SceneDataModel")

function SceneDataModel:Ctor(module)
  self.sceneModule = module
end

function SceneDataModel:Init()
  self.FirstEnter = false
  self.rotation = nil
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_ENTER_SCENE_RSP, self._OnEnterScene)
end

function SceneDataModel:_OnEnterScene(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.FirstEnter = true
    self.sceneModule:EnterScene(rsp)
  end
end

function SceneDataModel:GetFirstEnter()
  return self.FirstEnter
end

function SceneDataModel:SetEntered()
  self.FirstEnter = false
end

function SceneDataModel:UnInit()
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_ENTER_SCENE_RSP, self._OnEnterScene)
end

return SceneDataModel
