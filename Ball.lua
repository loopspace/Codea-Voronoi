Ball = class()

function Ball:init(sc,p,s,c)
    self.position = p or vec2(0,0)
    self.size = s or 15
    self.colour = c or color():new("white")
    self.free = true
    self.friction = 1
    self.speed = vec2(0,0)
    self.entity = sc:entity()
    self.entity.model = craft.model.icosphere(1,3)
    self.entity.scale = vec3(1,1,1)*.005
    self.entity.material = craft.material("Materials:Standard")
end

function Ball:kick(target)
    local d = vec2(Normal(0,50),Normal(0,50))
    self.speed = (target +d - self.position)*self.friction
    self.free = true
    if self.player then
        self.player.mustKick = false
        self.player.hasBall = false
        self.player.hadBall = true
    end
end

function Ball:update()
    if self.free then
        self.position = self.position + DeltaTime*self.speed
        self.speed = (1 - DeltaTime*self.friction)*self.speed
        if self.speed:len() < 1 then
            if self.player then
                self.player.hadBall = false
            end
        end
    end
end

function Ball:draw()
    local p = vec3(self.position.x/RectAnchorOf(Landscape,"width"),0.005,-self.position.y/RectAnchorOf(Landscape,"width"))
    self.entity.position = p
    pushStyle()
    fill(0, 0, 0, 94)
    ellipseMode(CENTER)
    ellipse(self.position,20)
    popStyle()
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
        if self.player then
            self.player.hasBall = false
            self.player.hadBall = false
            self.player.team.possession = false
            self.player.mustKick = false
            self.player = false
        end
        self.free = true
        self.offset = self.position - tpt
        self.speed = vec2(0,0)
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
    if g.type.ended and g.type.short then
        self.speed = g.touchesArr[1]:velocity()
    end
    g:noted()
    if g.type.ended then
        g:reset()
    end
end