
local function pprint(var, tostr)
    local duplicateTable = {}
    local rstr = ''
    local function realfunc(var, stack)
        local function myprint(...)
            rstr = rstr .. string.rep("\t",stack)
            for _, s in pairs({...}) do
                rstr = rstr .. s
            end
        end

        if type(var) ~= "table" then
            if type(var) == 'string' then
                myprint('"'..tostring(var)..'"')
            else
                   myprint(tostring(var))
            end
        else
            --duplicate detect
            if duplicateTable[var] then
                myprint(tostring(var))
                return
            else
                duplicateTable[var] = 1
            end
            --print data
            myprint(tostring(var), "\n")
            --if not isclass(var) then
                if var.__pprint and type(var.__pprint)=='function' then --把日志按照table返回(每行一个元素)
                    local tstrs = var:__pprint()
                    if type(tstrs) == 'table' then
                        for _, s in pairs(tstrs) do myprint(s,'\n') end
                    else
                        myprint(tstrs)
                    end
                else
                    myprint("{")
                    local nilflag = true
                    for k,v in pairs(var) do
                        if nilflag then
                            rstr = rstr .. '\n'
                            nilflag = false
                        end
                        realfunc(k, stack+1)
                        if type(v) == "table" and next(v) ~= nil then
                            rstr = rstr .. '=>\n'
                            realfunc(v, stack+2)
                        elseif type(v) ~= "table" then
                            if type(v) == 'string' then
                                 rstr = rstr .. '=>' .. '"'..tostring(v)..'"'
                            else
                                rstr = rstr .. '=>' .. tostring(v)
                            end
                        else
                            rstr = rstr .. '=>' .. tostring(v) .. '{}'
                        end
                        rstr = rstr .. '\n'
                    end
                    myprint("}")
                end
            --end
        end
    end
    realfunc(var, 0)
    --rstr = rstr .. '\n'
    if tostr then return rstr else io.write(rstr) end
end


local getupvalue = debug.getupvalue

local function getTab(n)
    local tab = ''
    tab = tab .. string.rep('\t', n)
    return tab
end

local depth = 0
local rep = {}
local function enumUpvalue(v)
    if type(v)=='table' then
        if rep[v]  then
            return
        end
        rep[v] = true
    end
    if type(v)=='table' then
        for m, n in pairs(v) do
            print(getTab(depth), m, n)
            if type(n)=='table' or type(n)=='function' then
                depth = depth+1
                enumUpvalue(n)
                depth = depth-1
            end
        end
    elseif type(v)=='function' then
        local i = 1
        while true do
            local name, val = debug.getupvalue(v, i)
            --print(getTab(depth), name, val)
            if not name then
                break
            end
            if name~='_ENV' then 
                print(getTab(depth), name, val)
            end
            if name~='_ENV' and (type(val)=='table' or type(val)=='function') then
                depth = depth+1
                enumUpvalue(val)
                depth = depth-1
            end
            i = i+1
        end
    end
end


return {
    ptable = pprint,   
    pall = enumUpvalue,
}