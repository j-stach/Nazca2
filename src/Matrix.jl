
module Matrix

export inbounds, newmtx, mtxdims, printmtx

# Checks if a coordinate pair are within matrix dimension bounds
function inbounds(mtx, x, y)
    xdim, ydim = size(mtx)
    return 1 <= x <= xdim && 1 <= y <= ydim
end

# Initializes an "empty" matrix with the specified dimensions
function newmtx((xdim, ydim))
    mtx = fill('_', xdim, ydim)
    return mtx
end

# TODO Determines the dimensions required to store the encrypted message
function mtxdims(emsg)
    return (10, 10) # TODO Placeholders, will autosize later
    # encrypting without "condense == true" often runs out of room
end

# Print a matrix to the standard output
function printmtx(mtx)
    xdim, ydim = size(mtx)
    for x in 1:xdim
        for y in 1:ydim
            print(mtx[x, y], " ")
        end
        println()
    end
end



end # module Matrix
