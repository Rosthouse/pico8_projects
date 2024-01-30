
function insert(tbl, v, i)
    v_o = tbl[i]
    tbl[i] = v
    if v_o != nil then
        insert(tbl, v_o, i+1)
    end
end