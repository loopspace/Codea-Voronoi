Ball = class()

function Ball:init(p,s,c)
    self.position = p or vec2(0,0)
    self.size = s or 15
    self.colour = c or color():new("white")
    self.free = true
    self.friction = 1
    self.speed = vec2(0,0)
end

function Ball:kick(target)
    self.speed = (self.target - self.position)*self.friction
    self.free = true
end

function Ball:update()
    self.position = self.position + DeltaTime*self.speed
    self.speed = (1 - DeltaTime*self.friction)*self.speed
end

function Ball:draw()
    self:update()
    pushStyle()
    ellipseMode(CENTER)
    textMode(CORNER)
    fill(self.colour)
    stroke(0,0,0)
    strokeWidth(1)
    -- noStroke()
    ellipse(self.position,self.size)
    popStyle()
end

function Ball:isTouchedBy(t)
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    local d = 50^2
    if self.position:distSqr(tpt) < d then
        self.offset = self.position - tpt
        return true
    end
    return false    
end

function Ball:processTouches(g)
    local t = g.touchesArr[1].touch
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    self.position  = self.offset + tpt
    g:noted()
    if g.type.ended then
        g:reset()
    end
end