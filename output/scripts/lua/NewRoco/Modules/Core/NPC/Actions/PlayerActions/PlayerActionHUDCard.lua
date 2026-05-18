local PlayerActionHUDCard = Class("PlayerActionHUDCard")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")

function PlayerActionHUDCard:Ctor(Owner, Config)
  self.Owner = Owner
  self.Config = Config
end

function PlayerActionHUDCard:Execute()
  if not self.Owner then
    return
  end
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenStudentCardPanel, self.Owner.owner.serverData, FriendEnum.AdminFriendType.Others, FriendEnum.Source.Scene, FriendEnum.SELECT_TAB.FaceToFaceInteraction)
end

function PlayerActionHUDCard:ShouldShowOnUI()
  local option = self.Owner
  if not option then
    return false
  end
  local player = option.owner
  if not player then
    return false
  end
  if player:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_OBSERVING) then
    return false
  end
  return true
end

return PlayerActionHUDCard
