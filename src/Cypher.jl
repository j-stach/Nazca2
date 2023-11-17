
module Cypher
using Random
export primary_encryption, goodspots, placement, salt

# Converts the message into a vector of placement distances (encrypted message)
function primary_encryption(msg::String, key1::String)
    emsg = []
    key1 = collect(key1)
    for char in msg
        echar = findfirst(c -> c == char, key1)
        push!(emsg, echar)
    end
    return emsg
end

# Finds empty spots that are at the correct distance for the next placement
function goodspots(mtx, x, y, dist)
    good_spots = []
    xdim, ydim = size(mtx)
    for i in 1:xdim
        for j in 1:ydim
            if abs(x - i) + abs(y - j) == dist && mtx[i, j] == '_'
                push!(good_spots, (i, j))
            end
        end
    end
    shuffle!(good_spots)
    return good_spots
end

#TODO describe me DEBUG ME & add logging
# TODO last placement is not showing up on final matrix
function placement(mtx, x, y, emsg, key2, depth)::Bool
    if depth > length(emsg) + 1
        return true # if the message is placed, end recursion
        # TODO Needs to place a message end character?
        # Or else establish a convention of double space to end message decryption
        # TODO Needs overflow errors handled
    end
    good_spots = goodspots(mtx, x, y, emsg[depth - 1])
    for (i, j) in good_spots # for each available spot
        mtx[i, j] = key2[depth] # place the marker char
        if placement(mtx, i, j, emsg, key2, depth + 1) # recursively place the next char
            return true # if the message is placed end recursion
        end
        mtx[i, j] = '_' # if the message is not placed, reset spot and try next
            # TODO handle placement errors by resizing matrix
    end
end

#TODO describe me DEBUG ME
function salt(mtx, key2, depth)
    salt_key = key2[depth:end]
    xdim, ydim = size(mtx)
    for x in 1:xdim
        for y in 1:ydim
            if mtx[x, y] == '_'
                depth += 1
                mtx[x, y] = salt_key[depth]
                # TODO Ensure that key2 is the size of the matrix
            end
        end
    end
end



end # module Cypher
