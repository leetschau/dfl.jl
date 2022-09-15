module DistFileLib

using ArgParse
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

function parse_commandline()
    settings = ArgParseSettings(description = "DFL, distributed files library",
                            commands_are_required = true,
                            version = "0.1.0",
                            add_version = true)

    @add_arg_table settings begin
        "init"
            help = "initialize a new library, or clone an existing library via `git`"
            action = :command
        "scdk"
            help = "set callsign of current disk"
            action = :command
        "lsdk"
            help = "list existing disks in the library"
            action = :command
        "addk"
            help = "add a new disk to the library"
            action = :command
        "rmdk"
            help = "delete a disk from the library"
            action = :command
        "eddk"
            help = "edit an existing disk from the library"
            action = :command
        "add"
            help = "add a file to the library"
            action = :command
        "del"
            help = "delete a file from the library"
            action = :command
        "upd"
            help = "update an existing file in the library"
            action = :command
    end

    @add_arg_table settings["init"] begin
        "repo-path"
            help = "the remote repo path of the library"
            required = false
            default = ""
    end

    @add_arg_table settings["lsdk"] begin end

    @add_arg_table settings["addk"] begin
        "callsign"
            help = "callsign of the disk to be added"
            required = true
        "organization"
            help = "organization of the disk to be added"
            required = false
            default = ""
        "uri"
            help = "URI of the disk to be added"
            required = false
            default = ""
        "description"
            help = "description of the disk to be added"
            required = false
            default = ""
    end

    @add_arg_table settings["rmdk"] begin
        "id"
            help = "ID(callsign) of the disk to be removed"
            required = true
    end

    @add_arg_table settings["scdk"] begin
        "repo-path"
            help = "the remote repo path of the library"
            required = false
            default = ""
    end

    @add_arg_table settings["add"] begin
        "file-path"
            help = "the path of the file to be added to the library"
            required = true
    end

    @add_arg_table settings["del"] begin
        "file-id"
            help = "the ID of the file to be removed from the library"
            required = true
    end

    return parse_args(ARGS, settings)
end

function main()
    parsed_args = parse_commandline()
    if parsed_args["%COMMAND%"] == "init"
        println("init")
    elseif parsed_args["%COMMAND%"] == "lsdk"
        list_disks()
    elseif parsed_args["%COMMAND%"] == "addk"
        add_disk(parsed_args["addk"]["callsign"],
                 organization=parsed_args["addk"]["organization"],
                 uri=parsed_args["addk"]["uri"],
                 description=parsed_args["addk"]["description"])
    elseif parsed_args["%COMMAND%"] == "rmdk"
        remove_disk(parsed_args["rmdk"]["id"])
    else
        println("init")
    end
end

main()

end # module

