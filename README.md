# Dffmpeg

It is a small app for experimenting with drb. It is not working, don't use it.

## Usage

```
# Help
./bin/dffmpeg

# Start the server, it stores the tuplespace structure
./bin/dffmpeg server

# Encode a video, it split the video in segments, enqueue them for transcoding,
# wait for replies and join the segments again.

./bin/dffmpeg transcode ../dffmpegtest/source/demo1.mkv

# Bootup a worker, it waits for jobs, you can bootup as many as you want.

./bin/dffmpeg worker
```
