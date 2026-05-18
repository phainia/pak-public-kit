local PropsStatus_C = Class("PropsStatus_C")

function PropsStatus_C:Ctor()
  self.DynamicMaterial = nil
  self.bEnable = true
end

function PropsStatus_C:ReceiveBeginPlay()
  self.StaticMesh:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Camera, UE.ECollisionResponse.ECR_Ignore)
end

function PropsStatus_C:SetPlaceEnabled(bEnable)
  if bEnable ~= self.bEnable then
    self.bEnable = bEnable
    local DM = self:GetOrCreateDynamicMaterial()
    if bEnable then
      DM:SetVectorParameterValue("Color", UE4.FLinearColor(0, 1, 0, 1))
    else
      DM:SetVectorParameterValue("Color", UE4.FLinearColor(1, 0, 0, 1))
    end
  end
end

function PropsStatus_C:GetOrCreateDynamicMaterial()
  if not self.DynamicMaterial then
    self.DynamicMaterial = self.StaticMesh:CreateDynamicMaterialInstance(0)
  end
  return self.DynamicMaterial
end

function PropsStatus_C:IsPlaceEnabled()
  return self.bEnable
end

return PropsStatus_C
