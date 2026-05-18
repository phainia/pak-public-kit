local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_MiniGame_StarPiece_C = Base:Extend("BP_MiniGame_StarPiece_C")

function BP_MiniGame_StarPiece_C:Ctor()
  Base.Ctor(self)
end

function BP_MiniGame_StarPiece_C:OnVisible()
  local SceneCharacter = self.sceneCharacter
  if SceneCharacter then
    SceneCharacter.bDisappearPerform = true
    SceneCharacter:LockVisibility(true)
  end
  self.Niagara1.OnSystemFinished:Clear()
  Base.OnVisible(self)
end

function BP_MiniGame_StarPiece_C:PlayDisappearPerform()
  self.Beam:SetVisibility(false)
  self.Niagara:SetVisibility(false)
  self.Niagara1.OnSystemFinished:Add(self, self.NiagaraDone)
  self.Niagara1:SetVisibility(true)
  self.Niagara1:Activate(true)
  self.Mesh:SetVisibility(false)
end

function BP_MiniGame_StarPiece_C:NiagaraDone()
  Base.PlayDisappearPerform(self)
end

return BP_MiniGame_StarPiece_C
