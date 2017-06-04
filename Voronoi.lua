--[[
function Voronoi(p,r)
    local complex = {}
    local cell,outer,inner,hlen,no,nc,c,d,e,f,uv,pr
    local np = #p
    local pw,ph = RectAnchorOf(r,"size")
    for k,v in ipairs(p) do
        cell = {{vec2(-pw,-ph)/2 - v.position}, {vec2(pw,-ph)/2 - v.position}, {vec2(pw,ph)/2 - v.position}, {vec2(-pw,ph)/2 - v.position}}
        nc = 4
        for l,u in ipairs(p) do
            if l ~= k then
                uv = u.position - v.position
                outer, inner, hlen, no = false, false, uv:lenSqr()/2, 0
                pr = cell[nc][1]:dot(uv)
                for m = 1,nc do
                    if cell[m][1]:dot(uv) >= hlen and pr < hlen then
                        outer = m
                    elseif cell[m][1]:dot(uv) < hlen and pr >= hlen then
                        inner = (m-2)%nc+1
                    end
                    pr = cell[m][1]:dot(uv)
                end
                if inner and outer then
                    d = cell[outer][1]
                    c = cell[(outer-2)%nc+1][1]
                    e = {((uv/2 - d):dot(uv))/((c-d):dot(uv))*c + ((uv/2 - c):dot(uv))/((d-c):dot(uv))*d,u}
                    c = cell[inner][1]
                    d = cell[inner%nc+1][1]
                    f = {((uv/2 - d):dot(uv))/((c-d):dot(uv))*c + ((uv/2 - c):dot(uv))/((d-c):dot(uv))*d,cell[inner][2]}
                    if inner < outer then
                        for m = outer,nc do
                            table.remove(cell,outer)
                        end
                        for m = 1,inner do
                            table.remove(cell,1)
                        end
                        table.insert(cell,1,f)
                        table.insert(cell,e)
                        nc = outer - inner + 1
                    else
                        for m = outer,inner do
                            table.remove(cell,outer)
                        end
                        table.insert(cell,outer,f)
                        table.insert(cell,outer,e)
                        nc = nc - inner + outer + 1
                    end
                end
            end
        end
        table.insert(complex,cell)
    end
    return complex
end

function drawCells(cplx,p,c)
    pushStyle()
    strokeWidth(2)
    local nc = #cplx
    local u,v
    for k,cell in ipairs(cplx) do
        nc = #cell
        for l=1,nc do
            u = cell[l]
            v = cell[l%nc+1]
            stroke(c:shade(50))
            line(u[1] + p[k].position,v[1] + p[k].position)
            if u[2] then
                stroke(c:tint(50))
                line(p[k].position,u[2].position)
            end
        end
    end
    popStyle()
end
--]]