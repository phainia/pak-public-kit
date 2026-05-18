require("UnLuaEx")
local FsmVar = require("NewRoco.Modules.Core.Fsm.FsmVar")
local EUW_FsmPropertyItem_C = NRCClass()

function EUW_FsmPropertyItem_C:SetData(ItemData)
  self.Property = ItemData.data
  if not self.Property then
    return
  end
  local name = self.Property.define.name
  self.Name:SetText(name)
  self.VarName:SetText("")
  local Value = self.Property.properties and self.Property.properties[name]
  if Value then
    if type(Value) == "table" and Value.InstanceOf and Value:InstanceOf(FsmVar) and Value.isVar then
      self.Value:SetText(tostring(Value:Get()))
      self.VarName:SetText(Value.name)
      return
    end
    self.Value:SetText(tostring(Value))
  else
    self.Value:SetText("<not found>")
  end
end

return EUW_FsmPropertyItem_C
