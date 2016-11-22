-- Copyright (C) 2016 Pau Carré Cardona - All Rights Reserved
-- You may use, distribute and modify this code under the
-- terms of the Apache License v2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt).

--
-- Default configuration file
--

local libsFolder = require('paths').thisfile('..')
package.path = package.path .. ';' .. libsFolder .. '/0-tiefvision-commons/?.lua'

return {
  database = require("tiefvision_torch_io")
}
