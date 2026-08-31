[middleware.luau]

local middleware = {}
middleware.__index = middleware

function middleware.new(handler)
    local self = setmetatable({}, middleware)
    self.handler = handler
    self.next = nil
    return self
end

function middleware:use(nextmiddleware)
    self.next = nextmiddleware
    return self
end

function middleware:process(request, response)
    if self.handler then
        self:handler(request, response, function()
            if self.next then
                self.next:process(request, response)
            end
        end)
    elseif self.next then
        self.next:process(request, response)
    end
end

function middleware:chain(middlewarelist)
    local root = self
    for _, mw in middlewarelist do
        root:use(mw)
        root = mw
    end
    return self
end

return middleware
