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

  Following function are called when a control activate a label with
  labeller api -> APi=label VERB=dispatch
  arguments are
    - source (0) when requesting the label (-1) when releasing
    - label comme from config given with 'control' in onload-middlename-xxxxx.json
    - control is the argument part of the query as providing by control requesting the label.

--]]

_CurrentHalVolume={}


local function Apply_Hal_Control(source, ctl, val )

    -- check we really got some data
    if (ctl == nil or val == nil) then
        AFB:error ("--* (Hoops) syntax Apply_Hal_Control(control,value) ")
        return 1
    end

    -- loop on each HAL save current volume and push adjustment
    for key,hal in pairs(_GlobalHalList) do
       AFB:notice (source, "[--> Apply_Hal_Control -->] %s val=%d", Dump_Table(hal), val)
       local halapi = hal["api"]

        -- action set loop on active HAL and get current volume
        -- if label respond then do volume adjustment

        if (val >= 0) then

            -- get current volume for each HAL
            local err,result= AFB:servsync(source, halapi,"ctlget", {["label"]=ctl})

            -- if no error save current volume and set adjustment
            if (err ~= nil) then
                local response= result["response"]
                AFB:notice (source, "--- Response %s=%s", hal["api"], Dump_Table(response))

                if (response == nil) then
                   AFB:error (source, "--- Fail to Activate '%s'='%s' result=%s", halapi, label, Dump_Table(result))
                   return 1 -- unhappy
                end

                -- save response in global space
                _CurrentHalVolume [halapi] = response

                -- finally set the new value
                local query= {
                    ["tag"]= response["tag"],
                    ["val"]= adjustment
                }

                -- best effort to set adjustment value
                AFB:servsync(source, halapi,"ctlset",{["label"]=ctl,["val"]=val})
            end

        else  -- when label is release reverse action at preempt time

            if (_CurrentHalVolume [halapi] ~= nil) then

                AFB:notice(source, "--- Restoring initial volume HAL=%s Control=%s", halapi, _CurrentHalVolume [halapi])
                AFB:servsync(source, halapi,"ctlset", _CurrentHalVolume [halapi])
            end
        end

    end
    return 0 -- happy end
end

-- handle client session to automatically free resources when WS is closed
function _Session_Control_CB(source, context)
    local error

    if (AFB:status(source) ~= 0) then

        -- client quit let's restore control and free role
        error = Apply_Hal_Control(source, context["ctl"],-1)

    else

        -- client request control let's apply coresponding audio controls
        error = Apply_Hal_Control(source, context["ctl"],context["val"])

   end

   return error -- happy_end==0
end

-- Force Client Context Release when Testing
function _Free_Current_Role(source, args, query)

    AFB:context (source); -- without context data call free current client context
    AFB:notice (source, "[<-- _Temporarily_Control Restore--]")
    AFB:success (source, "done");

end


-- Temporally adjust volume
function _Temporarily_Control(source, args, query)
    local uid
    local error

    -- provide a default uid is nothing come from query
    if (query == nil or query["uid"] == nil) then
        uid = AFB:getuid(source)
    else
        uid = query["uid"]
    end

    AFB:notice (source, "[--> _Temporarily_Control -->] label=%s args=%s query=%s", AFB:getuid(source), Dump_Table(args), Dump_Table(query))

    -- make sure label as valid
    if (args == nil or args["ctl"] == nil or args["val"] == nil) then
        AFB:error ("--* Action Ignore no/invalid control=%s", Dump_Table(control))
        return 1 -- unhappy
    end

    -- register client session for resources auto free when client disconnect
    local client_context = {
        ["uid"]= uid,
        ["ctl"]= args["ctl"],
        ["val"]= args["val"],
    }

    -- activation of client context applies audio control within CB
    error = AFB:context (source, "_Session_Control_CB", client_context);
    if (error ~= nil) then
       AFB:warning (source, error);
       AFB:fail (source, error);
       return
    end

    AFB:notice (source, "[<-- _Temporarily_Control Granted<--]")
    AFB:success (source, "done");

end

