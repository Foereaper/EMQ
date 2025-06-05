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

    allMessages[oppositeContext] = {}
    player:Data():Set("EMQ_Messages", allMessages)

    for _, msg in pairs(messagesToProcess) do
        local handler = EMQ.queues[msg.queue]
        if handler then
            handler(player, msg.data)
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
    if not EMQ.queues[queue] then
        error("Queue '" .. queue .. "' is not registered.")
    end
    
    local originContext = getContext()
    local dataCache = self:Data():AsTable()
    local allMessages = dataCache["EMQ_Messages"] or { world = {}, map = {} }

    allMessages[originContext] = allMessages[originContext] or {}
    table.insert(allMessages[originContext], { queue = queue, data = data })

    self:Data():Set("EMQ_Messages", allMessages)
end

if(GetStateMapId() > -1) then
    for _, player in pairs(GetPlayersOnMap()) do
        EMQ.RegisterMessageProcessor(_, player)
    end
else
    for _, player in pairs(GetPlayersInWorld()) do
        EMQ.RegisterMessageProcessor(_, player)
    end
end

RegisterPlayerEvent(3, EMQ.RegisterMessageProcessor)
if not IsCompatibilityMode() then
    RegisterPlayerEvent(28, EMQ.RegisterMessageProcessor)
end

return EMQ
