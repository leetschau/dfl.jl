function load_db(fpath)::DataSet
    if isfile(fpath)
        rawdata = JSON.parsefile(fpath)
        res = Dict()
        for (k, v) in rawdata
            res[parse(Int, k)] = FileRec(
                v["name"],
                v["tags"],
                v["description"],
                v["size"],
                v["hash"],
                v["relations"],
                v["topic"]
            )
        end
        res
    else
        Dict()
    end
end

function hash_match(file_hash::String, dataset::DataSet)::Bool
    for (k, v) in dataset
        if v.hash == file_hash
            return true
        end
    end
    false
end

function save_db(dataset::DataSet, fpath::String)::Nothing
    if isempty(dataset)
        return nothing
    end
    mkpath(dirname(fpath))
    open(fpath, "w") do f
        JSON.print(f, dataset)
    end
end

function create_id(dataset::DataSet)::Int
    if isempty(dataset)
        1
    else
        maximum(keys(dataset)) + 1
    end
end

function exec(cmd::Cmd)::Tuple{String, String, Int}
    out = Pipe(); err = Pipe()

    process = run(pipeline(ignorestatus(cmd), stdout=out, stderr=err))
    close(out.in); close(err.in)

    ( String(read(out)), String(read(err)), process.exitcode )
end
