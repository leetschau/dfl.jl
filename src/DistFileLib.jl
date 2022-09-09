module DistFileLib

using JSON

datapath = joinpath(homedir(), ".config/dfl/database.json")

struct FileRec
    name ::String
    path :: String
    tags :: Vector{String}
    description :: String
    size :: Int
    hash :: String
    relations :: Dict
    topic :: String
end

const DataSet = Dict{Int, FileRec}

include("Utils.jl")

function add(filepath::String;
             tagline::String="",
             desc::String="",
             relations::String="",
             topic::String="default")::Nothing
    dataset = load_db(datapath)
    id = create_id(dataset)
    out, _ = exec(`md5sum $(filepath)`)
    fhash = String(split(out, ' ')[1])

    if hash_match(fhash, dataset)
        println("File $filepath is already in the dataset")
        return nothing
    end

    dataset[id] = FileRec(
        basename(filepath),
        split(tagline, ','),
        desc,
        filesize(filepath),
        fhash,
        Dict(),
        topic
    )

    save_db(dataset, datapath)
    println("File $(filepath) added to DFL.")
end

function remove(id::Int)::Nothing
    dataset = load_db(datapath)
    delete!(dataset, id)
    save_db(dataset, datapath)
    println("File #$(id) removed")
end

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

