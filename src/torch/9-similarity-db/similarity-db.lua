-- Copyright (C) 2016 Pau Carré Cardona - All Rights Reserved
-- You may use, distribute and modify this code under the
-- terms of the Apache License v2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt).

local torchFolder = require('paths').thisfile('..')
package.path = string.format("%s;%s/?.lua", os.getenv("LUA_PATH"), torchFolder)

require 'inn'
require 'optim'
require 'torch'
require 'xlua'
require 'lfs'

local tiefvision_commons = require '0-tiefvision-commons/tiefvision_commons'
local similarity_lib = require '9-similarity-db/similarity_lib'

function getInitialRefIndex(similarities)
  for refIndex = 1, similarities:size()[1] do
    local allMinusOne = true
    for testIndex = refIndex, similarities:size()[2] do
      allMinusOne = allMinusOne and similarities[refIndex][testIndex] == -1.0
    end
    if (allMinusOne) then
      return refIndex
    end
  end
  return similarities:size()[1] + 1
end

function similarityDb()
  local dataFolder = tiefvision_commons.dataPath('encoded-images')
  local testLines = tiefvision_commons.getFiles(dataFolder)
  local similaritiesDbPath = tiefvision_commons.dataPath('img-unsup-similarity-db')
  local similarities = torch.ones(#testLines, #testLines) * -1
  if(tiefvision_commons.fileExists(similaritiesDbPath)) then
    similarities = torch.load(similaritiesDbPath)
  end
  local initialReferenceIndex = getInitialRefIndex(similarities)
  print('Initial Reference Index: ' .. initialReferenceIndex)
  for referenceIndex = initialReferenceIndex, #testLines do
    local reference = testLines[referenceIndex]
    print(reference)
    local referenceEncoding = torch.load(dataFolder .. '/' .. reference):double()
    for testIndex = referenceIndex + 1, #testLines do
      local file = testLines[testIndex]
      local imageEncoding = torch.load(dataFolder .. '/' .. file):double()
      local similarity = similarity_lib.similarity(referenceEncoding, imageEncoding)
      if (similarity) then
        similarities[testIndex][referenceIndex] = similarity
        similarities[referenceIndex][testIndex] = similarity
        -- print('DIST( ' .. reference .. ', ' .. file .. ' ) = ' .. similarity)
      end
    end
    -- compare itself with its mirror
    local flippedEncoding = torch.load(tiefvision_commons.dataPath('encoded-images-flipped', reference)):double()
    local similarity = similarity_lib.similarity(referenceEncoding, flippedEncoding)
    if (similarity) then
      similarities[referenceIndex][referenceIndex] = similarity
      -- print('DIST( ' .. reference .. ', ' .. reference .. ' ) = ' .. similarity)
    end
    torch.save(similaritiesDbPath, similarities)
    if referenceIndex % 5 == 0 then
      collectgarbage()
    end
  end
end

similarityDb()
