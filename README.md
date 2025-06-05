# EMQ: Eluna Message Queue

**EMQ** (Eluna Message Queue) is a framework designed to enable communication between **map** and **world** states in Eluna.

---

## Features

- Asynchronous message delivery between **map** and **world** states.
- Named message queues with custom handlers.
- Minimal and intuitive API.

---

## How It Works

1. Send messages using `player:SendEMQMessage`.
2. Messages are stored in the player’s persistent data.
3. A message processor runs on a timer (`1000ms` by default) to process messages intended for the opposite state.
4. If a message matches a registered queue name, the associated handler is called.

---

## Installation

1. Place `EMQ.lua` in your Lua scripts directory.
2. Require it in any script that needs messaging:
   ```lua
   local EMQ = require("EMQ")
   ```
---

## Usage Example

See [example.lua](example.lua)

---

## API Reference

### `EMQ.RegisterQueue(queueName, handlerFunction)`

Registers a new queue and its associated handler.

- **`queueName`** (`string`): Unique queue name.
- **`handlerFunction(player, data)`** (`function`): Callback executed when a message is dequeued.

### `Player:SendEMQMessage(queueName, data)`

Sends a message to the queue for processing in the opposite state.

- **`queueName`** (`string`): Name of a registered queue.
- **`data`** (`any`): Data passed to the queue handler. Userdata is not supported.

---

## Configuration

You can adjust the message polling frequency:

```lua
EMQ.config.frequency = 1000  -- Poll every 1 seconds
```

---
