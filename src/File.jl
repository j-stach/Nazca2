
module File
using Pkg, Dates, Base.Filesystem
Pkg.add("YAML")
using YAML
export save, load, newfile, okpath

# Saves data to the specified filepath
function save(path, data)
    open(path, "w") do io
        YAML.dump(io, data)
    end
end

# Loads data from the specified filepath
function load(path)
    open(path, "r") do io
        return YAML.load(io)
    end
end

# Automatically names a new file based on current time
function newfile()
    now = string(Dates.now())
    return now * "encrypted.yaml"
end

function okpath(path)
    return contains(path, r".*\.yaml$")
    # Kate IDE highlighting breaks here.
end
end # module File
