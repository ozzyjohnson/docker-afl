docker-afl
==========

**Built:** 2014.11.20 - 0.61b
 
[American Fuzzy Lop (AFL)](http://lcamtuf.coredump.cx/afl/) and libjpeg-turbo built to play with fuzzing on Debian wheezy.

### Background:

I ran across the post [Pulling JPEGs out of thin air](http://lcamtuf.blogspot.com/2014/11/pulling-jpegs-out-of-thin-air.html) linked on Hacker News today, found it fascinating and wanted to give it a try. This image is the result.

### Usage:

To recreate the experiment described.

Prepare the host if necessary. Trusty defaults this to apport which must be changed while Amazon Linux is ready to run.

    echo core | sudo tee /proc/sys/kernel/core_pattern

Set up data directory for input and results:

    mkdir -p  ~/afl/afl-data/in_dir
    echo 'hello' >~/afl/afl-data/in_dir/hello

Pull or build from the provided Dockerfile.

    sudo docker pull ozzyjohnson/afl

Run interactively.

    sudo docker run -v ~/afl/afl-data:/data -it --rm \
      ozzyjohnson/afl \
      afl-fuzz -i in_dir -o out_dir /opt/libjpeg-turbo/bin/djpeg

    			american fuzzy lop 0.54b (djpeg)

    ┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
    │        run time : 0 days, 0 hrs, 0 min, 23 sec       │  cycles done : 0      │
    │   last new path : 0 days, 0 hrs, 0 min, 0 sec        │  total paths : 30     │
    │ last uniq crash : none seen yet                      │ uniq crashes : 0      │
    │  last uniq hang : none seen yet                      │   uniq hangs : 0      │
    ├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
    │  now processing : 3 (10.00%)        │    map density : 334 (2.04%)           │
    │ paths timed out : 0 (0.00%)         │ count coverage : 1.26 bits/tuple       │
    ├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
    │  now trying : havoc                 │ favored paths : 5 (16.67%)             │
    │ stage execs : 34.9k/160k (21.83%)   │  new edges on : 22 (73.33%)            │
    │ total execs : 82.0k                 │ total crashes : 0 (0 unique)           │
    │  exec speed : 3488/sec              │   total hangs : 0 (0 unique)           │
    ├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
    │   bit flips : 1/104, 0/100, 0/92                    │   levels : 4           │
    │  byte flips : 0/13, 0/9, 0/3                        │  pending : 27          │
    │ arithmetics : 1/910, 0/209, 0/0                     │ pend fav : 3           │
    │  known ints : 1/117, 3/333, 0/150                   │ imported : 0           │
    │       havoc : 4/45.0k, 0/0                          │ variable : 0           │
    │        trim : 1 B/2 (20.00% gain)                   │   latent : 0           │  
    └─────────────────────────────────────────────────────┴────────────────────────┘

Or detached.

    sudo docker run -v ~/afl/afl-data:/data -d \
      ozzyjohnson/afl \
      afl-fuzz -i in_dir -o out_dir /opt/libjpeg-turbo/bin/djpeg

With the results acessible via the mounted volume.

    ~/afl/afl-data/out_dir/queue

### Parallel Runs:

The script [fuzzit.sh](https://github.com/ozzyjohnson/docker-afl/blob/master/fuzzit.sh) simplifies running a set of parallel containers. With no options specified it will launch one container per CPU and look for input and out dirs in the current user's home directoty.

    Usage: fuzzit.sh [OPTION]
    Launch a team of fuzzers. Uses the number of available cores
    by default.
     
     -i            input directory
     -o            output directory
     -n            number of fuzzers to launch
     -f            fuzz target
     -t            fuzz ID convention
     -d            data directory to be mapped to containers

Set up input and output as usual.

    mkdir ~/afl-test
    mkdir ~/afl-test/in_dir
    echo 'hello' >~/afl-test/in_dir/hello
    sudo ./fuzzit.sh -n 8 -p alf -d ~/afl-test

Next, we can confirm they're all running.

    sudo docker ps

Check the progress of a particular container or figure out why it failed to continue running.

    sudo docker logs afl2

Or remove the set quickly.

    for i in `seq 1 8`; do sudo docker kill alf${i} && sudo docker rm alf${i};done
