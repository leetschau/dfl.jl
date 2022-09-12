module DistFileLib

using JSON
using Setfield

rootpath = joinpath(homedir(), ".config/dfl")
filespath = joinpath(rootpath, "files.json")
diskspath = joinpath(rootpath, "disks.json")
confspath = joinpath(rootpath, "local.json")

json_indent = 2

struct FileRec
    id :: Int
    name ::String
    path :: Vector{String}
    size :: Int
    hash :: String
    tags :: Vector{String}
    description :: String
    uri :: String
    relations :: Dict
    topic :: String
end

struct DiskRec
    callsign :: String
    organization :: String
    uri :: String
    description :: String
end

struct LocalConfs
    current_disk :: String
end

const FileSet = Vector{FileRec}
const DiskSet = Vector{DiskRec}

function Base.show(io::IO, disks::DiskSet)
    for i in disks
        print("Callsign: $(i.callsign), ")
        print("Organization: $(i.organization), ")
        print("URI: $(i.uri), ")
        println("Description: $(i.description)")
    end
end

include("Utils.jl")
include("DiskCommands.jl")
include("FileCommands.jl")

function julia_main()::Cint
    if ARGS[1] == "add"
        add(ARGS[2])
    elseif ARGS[1] == "del"
        remove(ARGS[2])
    else
        println("Unknown command: $(ARGS[1])")
    end
    return 0
end

end # module

