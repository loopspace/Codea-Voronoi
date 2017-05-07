-- Voronoi

function setup()
    displayMode(OVERLAY)
    displayMode(FULLSCREEN)
    cmodule "Voronoi Football"
    cmodule.path("Graphics", "Maths", "Utilities", "Base")
    cimport "VecExt"
    cimport "ColourExt"
    cimport "Coordinates"

    vor = mesh()
    local c = image(1,255)
    for k=1,255 do
        c:set(1,k,hsl(k,255,127))
    end
    vor.shader = shader(vShader())
    npt = 0
    init = true
    spriteMode(CORNER)
    radius = 1
    piw,pih = math.max(WIDTH,HEIGHT),math.min(WIDTH,HEIGHT)
    local b = 10
    pw,ph = 130,100
    sf = math.floor(math.min((piw-2*b)/pw,(pih-2*b)/ph))
    piw,pih = pw*sf+2*b, ph*sf + 2*b
    pitch = image(piw,pih)
    vor:addRect(0,0,piw,pih)
    vor.shader.texture = c
    vor.shader.aspect = pih/piw
    pushStyle()
    setContext(pitch)
    background(22, 172, 46, 255)
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(5)
    ellipseMode(RADIUS)
    lineCapMode(SQUARE)
    -- line(b,b,pw*sf,b)
    rect(b,b,pw*sf,ph*sf)
    rect(b,b+ph*sf/2-22*sf,18*sf,44*sf)
    rect(b+pw*sf-18*sf,b+ph*sf/2-22*sf,18*sf,44*sf)
    rect(b,b+ph*sf/2-10*sf,6*sf,20*sf)
    rect(b+pw*sf-6*sf,b+ph*sf/2-10*sf,6*sf,20*sf)
    ellipse(b+pw*sf/2,b+ph*sf/2,10*sf)
    line(b+pw*sf/2,b,b+pw*sf/2,b+ph*sf)
    line(b,b+ph*sf/2-4*sf,b,b+ph*sf/2+4*sf)
    line(b+pw*sf,b+ph*sf/2-4*sf,b+pw*sf,b+ph*sf/2+4*sf)
    clip(b+18*sf-strokeWidth()/2,b+ph*sf/2-22*sf,pw*sf-36*sf+strokeWidth(),44*sf)
    ellipse(b+12*sf,b+ph*sf/2,10*sf)
    ellipse(b+pw*sf-12*sf,b+ph*sf/2,10*sf)
    clip()
    -- ellipse(b,b,sf)
    -- noStroke()
    fill(255, 255, 255, 255)
    ellipse(b+12*sf,b+ph*sf/2,strokeWidth())
    ellipse(b+pw*sf-12*sf,b+ph*sf/2,strokeWidth())
    setContext()
    popStyle()
    
    teamSize = 11
    playerSize = 15
    teamA,teamB = {colour = color():new("blue")},{colour = color():new("red")}
    
    for k=1,teamSize do
        table.insert(teamA,vec2(k*pw/(teamSize+1)/2*sf,(ph-10)*sf/2-b))
        table.insert(teamB,vec2(-k*pw/(teamSize+1)/2*sf,-(ph-10)*sf/2+b))
    end
    
    local pts = {}
    local c = vec2(piw/2,pih/2)
    for k=1,16 do
        table.insert(pts,vec2(-2,-2))
    end
    for k,v in ipairs(teamA) do
        pts[k] = (v + c)/piw
    end
    vor.shader.pts = pts
    
    local cplx = voronoi(teamA)
    local nc = #cplx
    
    print(nc)
    local u,v
    for k,cell in ipairs(cplx) do
        nc = #cell
        print(nc)
        for k=1,nc do
            u = cell[k]
            v = cell[k%nc+1]
            print(u[1],v[1])
        end
    end
    print("---")
end

function draw()
    background(40,40,50)
    pushMatrix()
    pushStyle()
    spriteMode(CENTER)
    TransformOrientation(LANDSCAPE_LEFT)
    translate(RectAnchorOf(Landscape,"centre"))
    sprite(pitch)
    vor:draw()
    popStyle()
    strokeWidth(2)
    stroke(teamA.colour:shade(50))
    local cplx = voronoi(teamA)
    local nc = #cplx
    local u,v
    for k,cell in ipairs(cplx) do
        nc = #cell
        for l=1,nc do
            u = cell[l]
            v = cell[l%nc+1]
            line(u[1] + teamA[k],v[1] + teamA[k])
            if u[2] then
                -- line(teamA[k],u[2])
            end
        end
    end
    fill(255, 255, 255, 255)
    noStroke()
    fill(teamA.colour)
    for k,v in ipairs(teamA) do
        ellipse(v,playerSize)
    end
    fill(teamB.colour)
    for k,v in ipairs(teamB) do
        ellipse(v,playerSize)
    end
    popMatrix()

end

function touched(t)
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    if t.state == BEGAN then
        local d = 50^2
        for k,v in ipairs(teamA) do
            if v:distSqr(tpt) < d then
                tplayer = k
                tteam = teamA
                d = v:distSqr(tpt)
            end
        end
        for k,v in ipairs(teamB) do
            if v:distSqr(tpt) < d then
                tplayer = k
                tteam = teamB
                d = v:distSqr(tpt)
            end
        end
        if tplayer then
            toffset = tteam[tplayer] - tpt
        end
    else
        if tplayer then
            tteam[tplayer] = tpt + toffset
        end
    end
    local pts = {}
    local c = vec2(piw/2,pih/2)
    for k=1,16 do
        table.insert(pts,vec2(-2,-2))
    end
    for k,v in ipairs(teamA) do
        pts[k] = (v + c)/piw
    end
    vor.shader.pts = pts
end

function voronoi(p)
    local complex = {}
    local cell,outer,inner,hlen,no,nc,c,d,e,f,uv
    local np = #p
    for k,v in ipairs(p) do
        cell = {{vec2(-pw*sf,-ph*sf)/2 - v}, {vec2(pw*sf,-ph*sf)/2 - v}, {vec2(pw*sf,ph*sf)/2 - v}, {vec2(-pw*sf,ph*sf)/2 - v}}
        nc = 4
        for l,u in ipairs(p) do
            if l ~= k then
                uv = u - v
                outer, inner, hlen, no = {}, {}, uv:lenSqr()/2, 0
                for m,w in ipairs(cell) do
                    if w[1]:dot(uv) >= hlen then
                        table.insert(outer,m)
                        no = no + 1
                    end
                end
                if no >= 1 then
                    d = cell[outer[1]][1]
                    c = cell[(outer[1]-2)%nc+1][1]
                    e = {((uv/2 - d):dot(uv))/((c-d):dot(uv))*c + ((uv/2 - c):dot(uv))/((d-c):dot(uv))*d,u}
                    c = cell[outer[no]][1]
                    d = cell[outer[no]%nc+1][1]
                    f = {((uv/2 - d):dot(uv))/((c-d):dot(uv))*c + ((uv/2 - c):dot(uv))/((d-c):dot(uv))*d,u}
                    for m = 1,no do
                        table.remove(cell,outer[1])
                    end
                    table.insert(cell,outer[1],f)
                    table.insert(cell,outer[1],e)
                    nc = nc + 2 - no
                end
            end
        end
        table.insert(complex,cell)
    end
    return complex
end

function hsl(t,m,a)
    a = a or 255
    t = math.max(0,math.min(6,t/m*6))
    if t < 1 then
        return color(255,t*255,0,a)
    elseif t < 2 then
        return color((2-t)*255,255,0,a)
    elseif t < 3 then
        return color(0,255,(t-2)*255,a)
    elseif t < 4 then
        return color(0,(4-t)*255,255,a)
    elseif t < 5 then
        return color((t-4)*255,0,255,a)
    else
        return color(255,0,(6-t)*255,a)
    end
end

function vShader()
    return [[
//
// A basic vertex shader
//

//This is the current model * view * projection matrix
// Codea sets it automatically
uniform mat4 modelViewProjection;

//This is the current mesh vertex position, color and tex coord
// Set automatically
attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;
uniform float aspect;

//This is an output variable that will be passed to the fragment shader
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    //Pass the mesh color to the fragment shader
    vColor = color;
    vTexCoord = vec2(texCoord.x,texCoord.y*aspect);
    
    //Multiply the vertex position by our combined transform
    gl_Position = modelViewProjection * position;
}
]],[[
//
// A basic fragment shader
//

//Default precision qualifier
precision highp float;

//This represents the current texture on the mesh
uniform lowp sampler2D texture;
uniform highp vec2 pts[16];

//The interpolated vertex color for this fragment
varying lowp vec4 vColor;

//The interpolated texture coordinate for this fragment
varying highp vec2 vTexCoord;

void main()
{
     float d = 2.;
     float dd;
     float p = 0.;
     int i;
     float s;
    for (i = 0; i < 16; i++) {
        dd = distance(vTexCoord,pts[i]);
        s = step(d,dd);
        p = (1.-s)*(float (i)) + s*p;
        d = s*d + (1.-s)*dd;
    }
    //Sample the texture at the interpolated coordinate
    lowp vec4 col = texture2D( texture, vec2(.5,p/16.) );

    //Set the output color to the texture color
    gl_FragColor = col;
}
]]
end
