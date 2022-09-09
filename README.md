# Distributed File Library

Distributed Files Library (DFL for short) is a *logical file* (binary and plaintext) database,
where a file's identity and description is recorded.
You can search, filter (by tags or description), compare with "real" files on disk.

## Prerequisites

* Linux: `md5sum`

## Usage

```
dfl add <file-path>
dfl del <ID>
```

## API List

* add: `add <file-path>`, add a file into the library. Return ID if it has been recorded.
  Wildcards is allowed in <file-path>.
* delete: `delete <ID>`, remove a file from the library
* search: `search [name|tags|desc|size|hash|id|topic] <search-string>`
* edit: `edit [name|tags|desc|size|hash|id|topic] <ID>`,
  edit features of a file with editor specified in env variable `EDITOR`
* show: `show <ID>`, print detailed information of a file in human-readable format
* compare: `compare <ID> <file-path>`. Show if src & dst are the same file, print differences if not.
* match: `match <file-path>`. Show if the file has been recorded in the library.
  Print ID of the matched file if that's the case.

## Data Structure

Features of a *file* in the library include:

* ID: an auto-incremental integer. A file can be *linked* to another file
  (in *relation* field defined below) by its ID
* Name: file name, string, optional
* Path: disk & path of the physical file, format: [<org-name>-]<disk-name>/<path>,
  e.g.: HS-Host10.162.2.83/cyberange/data/MTU1223.pcap
* Tags: string list, optional
* Description: string, optional
* Size: integer (unit: byte)
* Hash: MD5 string
* Relations: dictionary (name, target), optional
* Topic: string, a file should belongs to one and only one topic

Data is stored in a JSON file.

Here *disk-name* in *path* entry above can be the name of either an U-disk or a host's IP address.
