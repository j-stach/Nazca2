
# Nonstandard language notes:
# Cryptee - Plaintext message or character to be encrypted
# Crypton - An encoded particle of meaning, fundamental unit of a cypher
# Cypher - Ordered process comprising transformations from cryptee to crypton
# Cryptogram - Collection of cryptons representing the encyphered information

# Abbrevs:
# msg   Message ("Cryptee" plaintext)
# mtx   Matrix
# dim   Dimension
# dist  Distance between marker character placements
# key1  Primary key, determines the placement distance per cryptee character
# key2  Secondary key, the order in which marker and salt characters are placed
# o-    Encryption origin value
# e-    Initial encryption value
# f-    Final encryption value

# TODO
# remove types to support image formats (add generics)
# break into modules?

#-- Configure logging
using Logging
log_config = ConsoleLogger(stderr, LogLevel(Info))
global_logger(log_config)

#-- Handle command line arguments
using Pkg
Pkg.add("ArgParse")
using ArgParse
parser = ArgParseSettings()
@add_arg_table! parser begin
    "--condense", "-c"
        help = "Minimize the dimensions of the encryption matrix"
        action = :store_true
end
# action or command (encypher, decypher)
# save /dirname
# primary_key /file or string
# secondary_key /file or string


#-- Define placement algorithm
using Random

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

# Generates a standard distance key for the plaintext message
function primarykey(msg::String, condense::Bool)
    if condense == false
        valid_chars = collect("ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789")
    else
        valid_chars = collect(Set(msg))
    end

    primary_key = shuffle(valid_chars)
    return primary_key
end

# Converts the message into a vector of placement distances (encrypted message)
function primary_encryption(msg::String, key1::Array{Char})
    emsg = []
    for char in msg
        echar = findfirst(c -> c == char, key1)
        push!(emsg, echar)
    end
    return emsg
end

# Shuffles the provided charset to create a random marker + salt order
function secondarykey(charset)
    charset = collect(charset)
    secondary_key = shuffle!(charset)
    return secondary_key
end

# Generates a charset from a unicode range, to be randomized as a secondary key
function charset((first, last))
    charset = []
    for codepoint in first:last
        push!(charset, Char(codepoint))
    end
    return charset
end

# Cleans up input text to ensure only supported characters are included
function sanitize(str::String)
    clean_str = []
    for char in str
        if isdigit(char) || ( isascii(char) && isuppercase(char) )
            push!(clean_str, char)
        elseif isascii(char)
            push!(clean_str, uppercase(char))
        else
            @warn("Omitting '$char': Not supported by encryption method")
        end
    end
    return join(clean_str)
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

#TODO describe me DEBUG ME
function placement(mtx, x, y, emsg, key2, depth)::Bool
    if depth > length(emsg)
        return true # if the message is placed, end recursion
    end
    good_spots = goodspots(mtx, x, y, emsg[depth - 1])
    for (i, j) in good_spots # for each available spot
        if inbounds(mtx, i, j) # unnecessary?
            mtx[i, j] = key2[depth] # place the marker char
            if placement(mtx, i, j, emsg, key2, depth + 1) # recursively place the next char
                return true # if the message is placed end recursion
            end
            mtx[i, j] = '_' # if the message is not placed, reset spot and try next
                # TODO handle placement errors by resizing matrix
        end
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


function encrypt_msg(msg::String, condense::Bool, charset)
    msg = sanitize(msg)

    # Primary Key
    key1 = primarykey(msg, condense)
    keystring1 = join(key1)
    @info("Primary key: $keystring1")

    emsg = primary_encryption(msg, key1)        # Encrypted msg

    # Secondary Key
    key2 = secondarykey(charset)
    keystring2 = join(key2[1:length(emsg) + 1])
    @info("Secondary key: $keystring2")

    dims = mtxdims(emsg)
    mtx = newmtx(dims)                          # Encryption matrix

    # Populate encryption matrix
    ox, oy = rand(1:dims[1]), rand(1:dims[2])   # Random origin
    mtx[ox, oy] = key2[1]
    placement(mtx, ox, oy, emsg, key2, 2)
    salt(mtx, key2, length(emsg) + 1)

    printmtx(mtx)
    return mtx
end




char_range = 0x2200, 0x22FF
# TODO generate this based on matrix size & a supplied start point?
# as part of secondary key, use mtx size and emsg length

encrypt_msg("Hello", true, charset(char_range))
@debug("Test ok")
