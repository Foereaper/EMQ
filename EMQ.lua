local EMQ = {
    config = {
        frequency = 1000, -- message processing delay timer in ms
    },
    queues = {}
}

local function getContext()
    local stateMapId = GetStateMapId()
    if stateMapId == -1 then
        return "world"
    else
        return "map"
    end
end

function EMQ.RegisterMessageProcessor(event, player)
    player:RegisterEvent(EMQ.ProcessMessages, EMQ.config.frequency, 0)
end

function EMQ.ProcessMessages(_, _, _, player)
    local oppositeContext = (getContext() == "world") and "map" or "world"
    
    if(IsCompatibilityMode()) then
        oppositeContext = "world"
    end
    
    local dataCache = player:Data():AsTable()
    local allMessages = dataCache["EMQ_Messages"] or { world = {}, map = {} }
    local messagesToProcess = allMessages[oppositeContext] or {}
    
    if(#messagesToProcess > 0) then
        allMessages[oppositeContext] = {}
        player:Data():Set("EMQ_Messages", allMessages)

        for _, msg in pairs(messagesToProcess) do
            local handler = EMQ.queues[msg.queue]
            if handler then
                handler(player, msg.data)
            else
                print("No registered handler for queue '" .. msg.queue .. "'. Discarding message.")
            end
        end
    end
end

function EMQ.RegisterQueue(queue, handlerFunction)
    if type(handlerFunction) ~= "function" then
        error("Handler for queue '" .. queue .. "' must be a function.")
    end
    
    if EMQ.queues[queue] then
        error("Queue '" .. queue .. "' is already registered.")
    end
    
    EMQ.queues[queue] = handlerFunction
end

function Player:SendEMQMessage(queue, data)
    local originContext = getContext()
    local dataCache = self:Data():AsTable()
    local allMessages = dataCache["EMQ_Messages"] or { world = {}, map = {} }

    allMessages[originContext] = allMessages[originContext] or {}
    table.insert(allMessages[originContext], { queue = queue, data = data })

    self:Data():Set("EMQ_Messages", allMessages)
end

local function OnLoad()
    local mapId = GetStateMapId()
    local eventId = (mapId == -1) and 3 or 28
    RegisterPlayerEvent(eventId, EMQ.RegisterMessageProcessor)
    
    local players = (mapId == -1) and GetPlayersInWorld() or GetPlayersOnMap()
    for _, player in pairs(players) do
        EMQ.RegisterMessageProcessor(_, player)
    end
end

RegisterServerEvent(33, OnLoad)

return EMQ
