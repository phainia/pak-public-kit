function UE4.FLinearColor.FromHex(hexColor)
  if string.StartsWith(hexColor, "#") then
    if 7 == #hexColor then
      local hex_R = hexColor:Substr(2, 3)
      
      local hex_G = hexColor:Substr(4, 5)
      local hex_B = hexColor:Substr(6, 7)
      local R = tonumber(hex_R, 16)
      local G = tonumber(hex_G, 16)
      local B = tonumber(hex_B, 16)
      local color = UE4.FColor(R, G, B, 255)
      return UE4.UKismetMathLibrary.Conv_ColorToLinearColor(color)
    elseif 9 == #hexColor then
      local hex_R = hexColor:Substr(2, 3)
      local hex_G = hexColor:Substr(4, 5)
      local hex_B = hexColor:Substr(6, 7)
      local hex_Alpha = hexColor:Substr(8, 9)
      local R = tonumber(hex_R, 16)
      local G = tonumber(hex_G, 16)
      local B = tonumber(hex_B, 16)
      local A = tonumber(hex_Alpha, 16)
      local color = UE4.FColor(R, G, B, A)
      return UE4.UKismetMathLibrary.Conv_ColorToLinearColor(color)
    end
  end
  return UE4.FLinearColor(1, 1, 1, 1)
end
