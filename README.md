# g-desktop-streamer
A desktop streaming utility based on GStreamer.

This Bash script sets up a GStreamer pipeline that captures desktop video, resizes it to match predefined dimensions, encodes using mpeg2, multiplexes with aac-encoded audio, and awaits for TCP connection from a receiver.

This has been created to watch Netflix on Kodi by streaming the desktop of another computer in the network.

The script takes care of creating a fake PulseAudio sink, so the default audio sink is disabled during streaming, and content is streamed at default (maximum) volume.

In order to set up streaming:
- Install dependencies (gstreamer1.0 plus plugins, nc, pulseaudio utils)
- Fiddle with settings in .sh script if you like
- Edit one of provided receiver templates (kodi, mpv) to target host's hostname or IP,
- Run .sh script on "host" machine
- Open strm / m3u file on receiving machine. 

A few notes to be taken:
This script deliberately uses old and relatively simple mpeg2 encoder, so the host machine may cope with compressing video without a problem. Compressing video by hardware has been abandoned as it had negative impact on decoding Netflix video that I wanted to watch in the first place.
Thus it is expected to exhibit lag of 2-4 seconds. It may or may not be suitable for streaming outside LAN, I've never tested that.
Once receiver disconnects from the stream, the streaming script ends automatically. It is a side effect of using GNU nc, but let's call it a safety feature.

All ideas are welcome, just file an Issue.

This work has been heavily influenced by Petter Reinholdsen's blog post:
http://people.skolelinux.org/pere/blog/Streaming_the_Linux_desktop_to_Kodi_using_VLC_and_RTSP.html

Special thanks go to helpful people on Odroid forum!
