local PufferErrorCodeDesc = {}
local LuaText = require("LuaText")
local Text = {
  NetworkError = LuaText.NetworkError,
  DownloadError = LuaText.UnknownError,
  PermissionError = LuaText.PermissionError,
  FileError = LuaText.FileError,
  FileErrorRestart = LuaText.FileErrorRestart,
  UnzipError = LuaText.UnzipError,
  VersionError = LuaText.VersionError,
  InitError = LuaText.InitError,
  UnknownError = LuaText.UnknownError
}
local ErrorCodeMapping = {
  [-1] = Text.InitError,
  [-2] = Text.InitError,
  [-3] = Text.FileError,
  [68288518] = Text.NetworkError,
  [69206048] = Text.PermissionError,
  [70254599] = Text.InitError,
  [70254604] = Text.PermissionError,
  [269615111] = Text.NetworkError,
  [269615110] = Text.DownloadError,
  [203423772] = Text.PermissionError,
  [269811740] = Text.PermissionError
}

function PufferErrorCodeDesc:AddPufferPrefix(ErrorCode)
  return "P" .. ErrorCode
end

function PufferErrorCodeDesc:GetDesc(ErrorCode)
  if 70254641 == ErrorCode then
    if _G.App.GetFormalPipeline() then
      return string.format(Text.NetworkError, self:AddPufferPrefix(ErrorCode))
    else
      local Desc = "\232\142\183\229\143\150puffer\230\156\141\229\138\161\229\153\168\232\191\148\229\155\158\233\148\153\232\175\175, \232\175\183\229\133\136\232\135\170\230\159\165\228\187\165\228\184\1393\231\167\141\230\131\133\229\134\181:\n1.\229\140\133\228\189\147\230\181\129\230\176\180\231\186\191\230\152\175\229\144\166\232\183\145\229\174\140\233\133\141\231\189\174\231\131\173\230\155\180\230\173\165\233\170\164\n2.\230\137\147\229\140\133\229\143\130\230\149\176\230\152\175\229\144\166\228\184\186FormalPipeline=true,\230\152\175\229\136\153\233\156\128\232\166\129\229\144\175\229\138\168\229\153\168\231\154\132\231\131\173\230\155\180\231\142\175\229\162\131\233\128\137\230\139\169\233\162\132\229\143\145\229\184\131\231\142\175\229\162\131\229\144\175\229\138\168\n3.\231\189\145\231\187\156\230\152\175\229\144\166\230\173\163\229\184\184\n\228\187\165\228\184\138\230\143\144\231\164\186\230\150\135\230\156\172\228\187\133\229\156\168\229\134\133\233\131\168\229\140\133\229\135\186\231\142\176"
      return Desc
    end
  end
  local FoundText = ErrorCodeMapping[ErrorCode]
  if not string.IsNilOrEmpty(FoundText) then
    return string.format(FoundText, self:AddPufferPrefix(ErrorCode))
  elseif ErrorCode >= 271581185 and ErrorCode <= 271581191 then
    return string.format(Text.DownloadError, self:AddPufferPrefix(ErrorCode))
  elseif ErrorCode >= 137363457 and ErrorCode <= 137363459 then
    return string.format(Text.DownloadError, self:AddPufferPrefix(ErrorCode))
  elseif ErrorCode >= 204472321 and ErrorCode <= 204472324 then
    return string.format(Text.UnzipError, self:AddPufferPrefix(ErrorCode))
  elseif ErrorCode >= 70254638 and ErrorCode <= 70254643 then
    return string.format(Text.NetworkError, self:AddPufferPrefix(ErrorCode))
  elseif ErrorCode >= 70254605 and ErrorCode <= 70254637 then
    return string.format(Text.DownloadError, self:AddPufferPrefix(ErrorCode))
  else
    return string.format(Text.UnknownError, self:AddPufferPrefix(ErrorCode))
  end
end

return PufferErrorCodeDesc
