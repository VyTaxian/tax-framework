local server = require(script.core.server)
local client = require(script.core.client)

local Tax = {}

function Tax.createService(definition)
	return server.createService(definition)
end

function Tax.createController(definition)
	return server.createController(definition)
end

function Tax.startServer(config)
	return server.start(config)
end

function Tax.startClient(config)
	return client.start(config)
end

function Tax.getService(name)
	return server.getService(name)
end

function Tax.getController(name)
	return server.getController(name)
end

function Tax.getClientService(name)
	return client.getService(name)
end

function Tax.getClientController(name)
	return client.getController(name)
end

return Tax
