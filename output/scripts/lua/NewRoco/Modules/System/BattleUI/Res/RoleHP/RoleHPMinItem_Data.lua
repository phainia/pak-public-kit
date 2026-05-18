local RoleHPMinItem_Data = NRCClass()

function RoleHPMinItem_Data:Ctor(teamFlag, isFull, isShine, isGrey, isBroken, isShow, isOut)
  self.teamFlag = teamFlag
  self.isFull = isFull
  self.isShine = isShine
  self.isGrey = isGrey
  self.isBroken = isBroken
  self.isShow = isShow
  self.isOut = isOut
end

return RoleHPMinItem_Data
