null_repo_msg = "Empty repo. Initialize it with `init -h` first"

function load_files(inpath::String)::FileSet
    if isfile(inpath)
        files = FileSet()
        rawdata = JSON.parsefile(inpath)
        for item in rawdata
            push!(files, FileRec(
                item["id"],
                item["name"],
                item["path"],
                item["size"],
                item["hash"],
                item["tags"],
                item["description"],
                item["uri"],
                item["relations"],
                item["topic"]
            ))
        end
        files
    else
        FileSet()
    end
end

function load_disks(inpath::String)::DiskSet
    if isfile(inpath)
        disks = DiskSet()
        rawdata = JSON.parsefile(inpath)
        for item in rawdata
            push!(disks, DiskRec(
                item["callsign"],
                item["organization"],
                item["uri"],
                item["description"]
            ))
        end
        disks
    else
        DiskSet()
    end
end

function load_confs(inpath::String)::LocalConfs
    if isfile(inpath)
        confs = Dict()
        rawdata = JSON.parsefile(inpath)
        LocalConfs(rawdata["current_disk"])
    else
        LocalConfs("")
    end
end

function hash_match(file_hash::String, fileset::FileSet)::Bool
    for i in fileset
        if i.hash == file_hash
            return true
        end
    end
    false
end

function save_files(fileset::FileSet, inpath::String)::Nothing
    mkpath(dirname(inpath))
    open(inpath, "w") do f
        JSON.print(f, fileset, json_indent)
    end
end

function save_disks(diskset::DiskSet, inpath::String)::Nothing
    mkpath(dirname(inpath))
    open(inpath, "w") do f
        JSON.print(f, diskset, json_indent)
    end
end

function save_confs(confs::LocalConfs, inpath::String)::Nothing
    mkpath(dirname(inpath))
    open(inpath, "w") do f
        JSON.print(f, confs, json_indent)
    end
end

function create_id(dataset::FileSet)::Int
    if isempty(dataset)
        1
    else
        maximum(keys(dataset)) + 1
    end
end

"""
Get output from *non-interactive* command.

For interactive command,use: run(pipeline(`cmd args`, stdin=stdin)).
You can't get output, while for most interactive commands output is irrelevant.
"""
function exec(cmd::Cmd)::Tuple{String, String, Int}
    out = Pipe(); err = Pipe()

    process = run(pipeline(cmd, stdout=out, stderr=err))
    close(out.in); close(err.in)

    ( String(read(out)), String(read(err)), process.exitcode )
end
