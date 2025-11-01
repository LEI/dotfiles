function table.indexOf(input, value)
  local index = nil
  for i, v in pairs(input) do
    if v == value then
      index = i
      break
    end
  end
  return index
end

function table.removeValues(input, exclude)
  if type(exclude) == 'string' then
    exclude = { exclude }
  end
  for _, value in pairs(exclude) do
    -- local index = table.indexOf(input, value)
    -- if index ~= nil then
    --   table.remove(input, index)
    -- end
    for i, v in pairs(input) do
      if value == v then
        table.remove(input, i)
        break
      end
    end
  end
  return input
end

return {
  removeValues = table.removeValues,
  indexOf = table.indexOf,
}
