
# TODO Needs to autosize encryption matrix, or retry with a new origin
# when the message doesn't fit -- needs to be able to handle actual messages

module Encrypt
using Random, Logging
import ..Nazca
#import("./Nazca.jl")
include("./Matrix.jl")
include("./Keys.jl")
include("./Cypher.jl")
using .Matrix, .Keys, .Cypher
export encrypt

#-- Full encryption algorithm
function encrypt(msg::String, condense::Bool)
    msg = sanitize(msg)

    # Primary Key
    if isempty(Nazca.key1)
        Nazca.key1 = primarykey(msg, condense)
    end
    key1 = Nazca.key1
    keystring1 = join(key1)
    @info("Primary key: $keystring1")

    emsg = primary_encryption(msg, join(key1))          # Encrypted msg

    # Encryption matrix
    dims = mtxdims(emsg)
    mtx = newmtx(dims)

    # Secondary Key
    if length(Nazca.key2) == 0
        range = Int(prod(size(mtx)))
        chars = charset((0x2200, 0x22FF))   # TODO debug: Why can't I create a range?
        Nazca.key2 = secondarykey(chars)
    end
    key2 = Nazca.key2
    keystring2 = join(key2[1:length(emsg) + 1])
    @info("Secondary key: $keystring2")

    # Populate encryption matrix
    ox, oy = rand(1:dims[1]), rand(1:dims[2])   # Random origin
    mtx[ox, oy] = key2[1]
    placement(mtx, ox, oy, emsg, key2, 2)
    salt(mtx, key2, length(emsg) + 1)

    printmtx(mtx)
    @debug("Encryption completed")
    return mtx
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
            @warn("Omitting '$char': Not supported by primary key")
        end
    end
    return join(clean_str)
end

end # module Encrypt
