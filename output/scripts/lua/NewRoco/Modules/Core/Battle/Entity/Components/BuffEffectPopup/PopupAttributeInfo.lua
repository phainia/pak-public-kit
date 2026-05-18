local PopupAttributeInfo = NRCClass()
PopupAttributeInfo.AttributeType = {
  EFFECT = 1,
  BUFF = 2,
  NORMAL = 3
}

function PopupAttributeInfo:Ctor(attrType, id, UINum)
  self.attrType = attrType
  self.id = id
  self.UINum = UINum
end

function PopupAttributeInfo.FromEffect(ID, Num)
  local data = PopupAttributeInfo()
  data.attrType = PopupAttributeInfo.AttributeType.EFFECT
  data.id = ID
  data.UINum = Num
  if not Num then
    data.UINum = 0
  end
  return data
end

return PopupAttributeInfo
