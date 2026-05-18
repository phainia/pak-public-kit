local PlayerModuleData = NRCData:Extend("PlayerModuleData")

function PlayerModuleData:Ctor()
  NRCData.Ctor(self)
  self.localPlayer = nil
  self.FriendRidePetMap = {}
end

PlayerModuleData.playerCtrlEnable = true
return PlayerModuleData
