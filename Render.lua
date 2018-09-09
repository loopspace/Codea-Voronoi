Render = class()

function Render:init(e,i,p,pl)
    self.entity = e
    self.image = i
    self.pitch = p
    self.players = pl
    for k,v in ipairs(pl.players) do
        v.entity.parent = e
    end
    pl.ball.entity.parent = e
end

function Render:update(dt)
    setContext(self.image)
    background(40,40,50,0)
    pushMatrix()
    pushStyle()
    spriteMode(CENTER)
    -- TransformOrientation(LANDSCAPE_LEFT)
    translate(RectAnchorOf(Landscape,"centre"))
    scale(-1,1)
    sprite(self.pitch)
    popStyle()
    self.players:update()
    self.players:draw()
    popMatrix()
    setContext()
end

