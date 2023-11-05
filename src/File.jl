
module File
using Dates, Base.Filesystem
import ..Nazca
export newfile, okpath, savekeys, savecyphertext, loadkeys, loadcyphertext

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
        write(file, "block$r: $rowstr\n")
    end
    write(file, "---\n")
    close(file)
end

# TODO Retrieve saved cyphertext from YAML file
function loadcyphertext(path)
    if okpath(path)
    end
end


end # module File
