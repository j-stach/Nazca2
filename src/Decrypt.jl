
module Decrypt
import ..Nazca
export decrypt

function decrypt(mtx)
    emsg = []
    lastspot = (nothing, nothing)
    # for every symbol in key2
    x, y = size(mtx)
    for char in Nazca.key2
        for i in 1:x
            for j in 1:y
                if mtx[i, j] == char
                    if lastspot === (nothing, nothing)
                        # Do nothing
                    else
                        dist = distance(lastspot, (i, j))
                        if dist <= length(Nazca.key1)
                            push!(emsg, dist)
                        end
                    end
                    lastspot = (i, j)
                end
            end
        end
    end

    msg = []
    for d in emsg push!(msg, Nazca.key1[d]) end
    msg = join(msg)
    println(msg)
    return msg
end

function distance((x, y), (i, j))
    return abs(x - i) + abs(y - j)
end

end
