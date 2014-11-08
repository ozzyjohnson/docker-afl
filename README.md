docker-afl
==========

American Fuzzy Loop (AFL) and libjpeg-turbo built to play with fuzzing on Debian wheezy.

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

                           american fuzzy lop 0.43b (djpeg)
    
    ┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
    │        run time : 0 days, 0 hrs, 4 min, 4 sec        │  cycles done : 0      │
    │   last new path : 0 days, 0 hrs, 0 min, 1 sec        │  total paths : 91     │
    │ last uniq crash : none seen yet                      │ uniq crashes : 0      │
    │  last uniq hang : none seen yet                      │   uniq hangs : 0      │
    ├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
    │  now processing : 27 (29.67%)       │    map density : 576 (3.52%)           │
    │ paths timed out : 0 (0.00%)         │ count coverage : 1.35 bits/tuple       │
    ├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
    │  now trying : havoc                 │ favored paths : 61 (67.03%)            │
    │ stage execs : 26.8k/60.0k (44.75%)  │  new edges on : 57 (62.64%)            │
    │ total execs : 819k                  │ total crashes : 0 (0 unique)           │
    │  exec speed : 3359/sec              │   total hangs : 0 (0 unique)           │
    ├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
    │   bit flips : 0/488, 0/472, 0/440                   │   levels : 5           │
    │  byte flips : 0/61, 0/45, 0/17                      │  pending : 76          │
    │ arithmetics : 1/4270, 0/1459, 0/78                  │ pend fav : 49          │
    │  known ints : 0/547, 0/1663, 0/850                  │   latent : 0           │
    │       havoc : 87/782k, 0/0                          │ variable : 0           │
    └─────────────────────────────────────────────────────┴────────────────────────┘

Or detached.

   sudo docker run -v ~/afl/afl-data:/data -d \
     ozzyjohnson/afl \
     afl-fuzz -i in_dir -o out_dir /opt/libjpeg-turbo/bin/djpeg

With the results acessible via the mounted volume.

   ~/afl/afl-data/out_dir/queue
