### Minimal data transfer mechanism
Pushing data between local and remote file trees. Data is usually a file tree.

### Inspiration
Plan9 dump file system. For references please google plan9 dump file system.

### Usage
on __local filesystem__:

``tar cf - myfiletree|gzip|push.sh``

on __Linux__ using ssh between remote file trees:

``tar cf - myfiletree|gzip|ssh user@host "`cat ~/bin/push.sh`"``

on __Windows__ using plink (e.g. with saved session information) between remote file trees:

``tar cf - myfiletree|gzip|plink -batch -load mysavedputtysession -m push.sh``

on __Plan9__: please reconsider.

### Description
push.sh transfers and stores data received on standard input in:
> ~/pushed/YYYY/MMDD/0/0.tar.gz

where YYYY/MMDD/ represents the current date similar to the plan9 dump filesystem.

If ~/pushed/YYYY/MMDD/0/ already exists 1/1.tar.gz is created, if 1/ exists 2/2.tar.gz is created etc.

Data on standard input shall practically be tarred and gzipped. To represent different data, change $pushed_file_suffix in push.sh.

### Requirements
Locally: ssh client (see examples).

On target OS: bash, sha256sum

### Concurrency
Safe for concurrent use.

### Planned features
None.

### Bugs
None.

Yet.
