local function CreateResourceRegexPattern(pattern)
  return {pattern = pattern, isRegex = true}
end

return CreateResourceRegexPattern
