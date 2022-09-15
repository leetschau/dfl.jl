# Distributed File Library

Distributed Files Library (DFL for short) is a *logical file* (binary and plaintext) database,
where a file's identity and description is recorded.
You can search, filter (by tags or description), compare with "real" files on disk.

Note that files managed by DFL are mostly *immutable* ones,
whose contents won't change after added into DFL.
By far files in DFL repo are mainly data files (pcap, csv, tgz) scattered
across different servers, U-disks.

## Prerequisites

### Linux

* `git`
* `md5sum`

## Usage

```
git clone ... dfl
julia --project='./dfl' -e 'using Pkg; Pkg.instantiate()'
cat << EOF > ~/.local/bin/dfl
#!/bin/bash

PRJ_HOME=/cyberange/playground/DistFileLib
julia --project=$PRJ_HOME $PRJ_HOME/src/DistFileLib.jl $@
EOF
dfl --help
```

You can build files repo from scratch:

    dfl init
    dfl scdk mydisk
    dfl add <file-path>
    dfl upd <ID>
    dfl del <ID>

Or build the repo from an existing repo:

    dfl init git@github.com:leo/myfiles.git
    dfl lsdk  # list all existing disks
    dfl scdk mydisk  # choose a disk callsign from above list
    dfl add <file-path>
    dfl del <ID>

## API List

### File API

* init: `init [upsteam]`, pull an existing repo from remote,
  or create a new repo from scratch
* add: `add <file-path>`, add a file into the library.
  Return ID if it has been recorded.  Wildcards is allowed in <file-path>.
* delete: `delete <ID>`, remove a file from the library
* list: `ls [num]`, list files in repo according to last updated time descendingly
* search: `search [name|tags|desc|size|hash|id|topic] <search-string>`
* edit: `edit <ID>`, edit features of a file with editor specified
  in env variable `EDITOR`
* show: `show <ID>`, print detailed information of a file in human-readable format
* compare: `compare <ID> <file-path>`. Show if src & dst are the same file,
  print differences if not.
* match: `match <file-path>`. Show if the file has been recorded in the library.
  Print ID of the matched file if that's the case.

### Disk API

* add-disk: 
* del-disk:
* edit-disk:
* ls-disk:
* set-current-disk:

## Data Structure

Features of a *file* in the library include:

* ID: an auto-incremental integer. A file can be *linked* to another file
  (in *relation* field defined below) by its ID
* Name: file name, string, optional
* Path: disk & path of the physical file, format: <disk-id>:<path>,
  e.g.: host83:/cyberange/data/MTU1223.pcap. A file can be stored on multiple disks.
* Size: integer (unit: byte)
* Hash: MD5 string
* Tags: string list, optional
* Description: string, optional
* URI: the upstream URI/URL of this file, optional
* Relations: dictionary (name, target), optional
* Topic: string, a file should belongs to one and only one topic, optional

Data is stored in a JSON file.

A *disk* in *path* entry above is defined by the following features:

* Callsign: a unique string represented this disk
* Organization: which organization (company) this disk belongs to, or *personal*
* URI: IP address of the host where disk mounted, optional
* Description: short description about this disk

# Development

## Test in REPL

    $ julia
    julia> using Revise
    julia> using DistFileLib
    julia> DistFileLib.<funtion-name> <args...>
    julia> DistFileLib.list_files()  # an example

## Test in Console

Add `julia_main()` into src/DistFileLib.jl, and run:

    julia --project='.' src/DistFileLib.jl <command> <args...>

for example:

    julia --project='.' src/DistFileLib.jl add -h

# Deployment

```
$ julia
julia> using PackageCompiler
julia> create_app(".", "build", incremental=true, executables=["dfl"=>"julia_main"])
```

The compiled binary is `$PROJ_HOME/build/bin/dfl`.

