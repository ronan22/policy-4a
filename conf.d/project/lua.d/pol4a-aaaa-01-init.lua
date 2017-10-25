--[[
  Copyright (C) 2016 "IoT.bzh"
  Author Fulup Ar Foll <fulup@iot.bzh>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.


  NOTE: strict mode: every global variables should be prefixed by '_'
--]]

-- Static variables should be prefixed with _
_EventHandle={}
_GlobalHalList={}

-- Call when AlsaCore return HAL active list
function _Hallist_CB (source, result, context)

    if (AFB:status(source) < 0) then
      AFB:error (source, "--InLua-- _Hallist_CB FX result=%s", Dump_Table(result))
      return
    end

    -- store active HAL devices
    _GlobalHalList= result["response"]

    -- display found HAL
    for k, v in pairs(result["response"]) do
        AFB:notice (source, "--InLua-- HAL:  api='%s' shortname='%s' devid='%s'", v["api"], v["shortname"], v["devid"])
    end

end

-- Display receive arguments and echo them to caller
function _init_hal (source, args)

    -- create event to push change audio roles to potential listeners
    _EventHandle=AFB:evtmake(source, "role")

    -- get list of supported HAL devices
     AFB:service(source, "alsacore","hallist", {}, "_Hallist_CB", {})

    return 0 -- happy end
end
