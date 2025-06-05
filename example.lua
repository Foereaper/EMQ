local EMQ = require("EMQ")

local function MyHandler(player, data)
    print("Printed in state: "..GetStateMapId()..". Data: "..data)
    if(GetStateMapId() > -1) then
        player:SendEMQMessage("TestQueue", "Hello from Map state!")
    end
end

EMQ.RegisterQueue("TestQueue", MyHandler)

local function OnCommand(event, player, command)
    if(command == "testqueue") then
        player:SendEMQMessage("TestQueue", "Hello from World state!")
    end
end

RegisterPlayerEvent(42, OnCommand)