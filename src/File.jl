
module File
using Dates, Base.Filesystem
import ..Nazca
export newfile, okpath, savekeys, savecyphertext, loadkeys, loadcyphertext, saveplaintext
include("./Matrix.jl")
using .Matrix

# Automatically names a new file based on current time
function newfile()
    now = string(Dates.now())
    return now * "encrypted.yaml"
end

# Checks if the filepath provided is .yaml
function okpath(path)
    return contains(path, r".*\.ya?ml$")
    # Kate IDE highlighting breaks here.
end

# Save the current encryption keys to the specified path
function savekeys(path)
    keystr1, keystr2 = join(Nazca.key1), join(Nazca.key2)
    # TODO if condense, make keystr2 the length of the message?
    file = open(path, "w")
    write(file, """
---
key1: $keystr1
key2: $keystr2
---
""")
    close(file)
end

# Retrieve encryption keys from YAML file
function loadkeys(path)
    if okpath(path)
        file = open(path, "r")
        for line in eachline(file)
            match1 = match(r"key1: ([^\n]+)", line)
            if match1 !== nothing
                Nazca.key1 = collect(match1.captures[1])
            end
            match2 = match(r"key2: ([^\n]+)", line)
            if match2 !== nothing
                Nazca.key2 = collect(match2.captures[1])
            end
        end
        close(file)
    end
end

# Save the ecrypted matrix to the specified path
function savecyphertext(path, mtx)
    keystr1, keystr2 = join(Nazca.key1), join(Nazca.key2)
    # TODO if condense, make keystr2 the length of the message?
    file = open(path, "w")
    write(file, "---\n")
    rows, cols = size(mtx)
    for r in 1:rows
        rowstr = join(mtx[r, :])
        write(file, "$r: $rowstr\n")
    end
    write(file, "---\n")
    close(file)
end

# TODO Retrieve saved cyphertext from YAML file
function loadcyphertext(path)
    file = open(path, "r")
    blocks = []
    for line in eachline(file)
        rowmatch = match(r"\d+: ([^\n]+)$", line)
        if rowmatch !== nothing
            row = string(rowmatch.captures[1])
            push!(blocks, row)
        end
    end
    close(file)

    x, y = size(blocks)[1], length(blocks[1])
    mtx = fill('_', x, y)
    for i in 1:x
        vecblock = collect(blocks[i])
        for j in 1:y
            mtx[i, j] = vecblock[j]
        end
    end

    #printmtx(mtx)
    return mtx
end

function saveplaintext(path, msg)
    file = open(path, "w")
    write(file, """
---
message: "$msg"
---
""")
    close(file)
end


end # module File
