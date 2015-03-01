docker-afl
==========

**Built:** 2015.03.01 - 1.50b
 
[American Fuzzy Lop (AFL)](http://lcamtuf.coredump.cx/afl/) and libjpeg-turbo built to play with fuzzing on Debian wheezy.

### Background:

I ran across the post [Pulling JPEGs out of thin air](http://lcamtuf.blogspot.com/2014/11/pulling-jpegs-out-of-thin-air.html), found it fascinating and wanted to give it a try. This image is the result.

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


				american fuzzy lop 1.13b (djpeg)

	┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
	│        run time : 0 days, 0 hrs, 0 min, 32 sec       │  cycles done : 0      │
	│   last new path : 0 days, 0 hrs, 0 min, 1 sec        │  total paths : 21     │
	│ last uniq crash : none seen yet                      │ uniq crashes : 0      │
	│  last uniq hang : none seen yet                      │   uniq hangs : 0      │
	├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
	│  now processing : 3 (14.29%)        │    map density : 257 (0.39%)           │
	│ paths timed out : 0 (0.00%)         │ count coverage : 1.23 bits/tuple       │
	├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
	│  now trying : havoc                 │ favored paths : 3 (14.29%)             │
	│ stage execs : 85.2k/160k (53.28%)   │  new edges on : 19 (90.48%)            │
	│ total execs : 136k                  │ total crashes : 0 (0 unique)           │
	│  exec speed : 4111/sec              │   total hangs : 0 (0 unique)           │
	├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
	│   bit flips : 0/72, 0/68, 0/60                      │    levels : 3          │
	│  byte flips : 0/9, 0/5, 0/1                         │   pending : 18         │
	│ arithmetics : 0/630, 0/35, 0/0                      │  pend fav : 1          │
	│  known ints : 0/81, 0/185, 0/50                     │ own finds : 20         │
	│  dictionary : 0/0, 0/0, 0/0                         │  imported : 0          │
	│       havoc : 3/50.0k, 0/0                          │  variable : 0          │
	│        trim : 2 B/1 (33.33% gain)                   ├────────────────────────┘
	└─────────────────────────────────────────────────────┘             [cpu:154%]

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
