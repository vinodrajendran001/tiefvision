-- Copyright (C) 2016 Pau Carré Cardona - All Rights Reserved
-- You may use, distribute and modify this code under the
-- terms of the Apache License v2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt).

local libsFolder = require('paths').thisfile('..')
package.path = package.path .. ';' ..
  libsFolder .. '/0-tiefvision-commons/?.lua;' ..
  libsFolder .. '/6-bboxlib/?.lua;' ..
  libsFolder .. '/8-similarity-db-cnn/?.lua;' ..
  libsFolder .. '/9-similarity-db/?.lua;' ..
  libsFolder .. '/10-similarity-searcher-cnn-db/?.lua'

require 'inn'
require 'optim'
require 'torch'
require 'xlua'
require 'lfs'

local tiefvision_commons = require 'tiefvision_commons'
local tiefvision_config_loader = require 'tiefvision_config_loader'
local bboxlib = require 'bboxlib'
local similarity_lib = require 'similarity_lib'
local similarity_db_lib = require 'similarity_db_lib'
local search_commons = require 'search_commons'

function getTestError(referenceEncoding)
  local dataFolder = tiefvision_commons.dataPath('encoded-images')
  local testLines = tiefvision_commons.getFiles(dataFolder)
  local comparisonTable = {}
  for testIndex = 1, #testLines do
    local file = testLines[testIndex]
    local imageEncoding = torch.load(dataFolder .. '/' .. file):double()
    local dist = similarity_lib.similarity(referenceEncoding, imageEncoding)
    table.insert(comparisonTable, { file, dist })
  end
  table.sort(comparisonTable, search_commons.sortCmpTable)
  search_commons.printCmpTable(comparisonTable)
end

function getImage(fileName, imagesFolder)
  local input = bboxlib.loadImageFromFile(imagesFolder .. '/' .. fileName)
  local bboxes = bboxlib.getImageBoundingBoxesTable(input, 1)
  local xmin = bboxes[1][1]
  local ymin = bboxes[1][2]
  local xmax = bboxes[1][3]
  local ymax = bboxes[1][4]
  input = image.crop(input, xmin, ymin, xmax, ymax)
  image.save(tiefvision_commons.resourcePath('dresses-db/uploaded/bbox', fileName), input)
  local encoder = similarity_db_lib.getEncoder()
  local encodedOutput = similarity_db_lib.encodeImage(tiefvision_commons.resourcePath('dresses-db/uploaded/bbox', fileName), encoder)
  return encodedOutput:double()
end


function getOptions()
  local cmd = torch.CmdLine()
  cmd:text()
  cmd:text('Unsupervised image search from an image file.')
  cmd:text('Returns a descending sorted list of filenames concatenated with a similarity metric.')
  cmd:text('The result filenames come from the folder $TIEFVISION_HOME/resources/dresses-db/master.')
  cmd:text()
  cmd:text('Options:')
  cmd:argument('image', 'Filename of the query image to search.', 'string')
  cmd:argument('imagesFolder', 'Folder where the images are contained.', 'string')
  cmd:text()
  cmd:option('-config-file', tiefvision_config_loader.default, 'Configuration file to use.')
  cmd:text()
  return cmd:parse(arg)
end

local options = getOptions()
local referenceDress = getImage(options.image, options.imagesFolder)
getTestError(referenceDress)
