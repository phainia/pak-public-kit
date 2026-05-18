local PathValidator = {}

function PathValidator:ValidatePath(path)
  return UE4.UEditorAssetLibrary.DoesAssetExist(path)
end

return PathValidator
