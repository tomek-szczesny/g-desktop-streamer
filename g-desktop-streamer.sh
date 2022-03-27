#!/bin/bash

# Config values
readonly pa_vsink_name="g_desktop_streamer"
readonly stream_port=1233
readonly video_h=1024
readonly video_v=600

#Save the current PulseAudio default source (full name)
pa_dsink_name=$(pactl get-default-sink)

#Set up a virtual PulseAudio sink
pacmd load-module module-null-sink sink_name=$pa_vsink_name sink_properties=device.description=$pa_vsink_name

#Save virtual PA sink's index for later
pa_vsink_no=$(pactl list short sinks | grep $pa_vsink_name | cut -f1)

#Set it as the default sink
pacmd set-default-sink $pa_vsink_no

#Move existing streams to virtual sink (nicked from stackexchange)
pactl list short sink-inputs|while read stream; do
    streamId=$(echo $stream|cut '-d ' -f1)
        echo "moving stream $streamId"
	    pactl move-sink-input "$streamId" "$pa_vsink_no"
    done

# Find virtual sink's monitor
pa_vsink_mon_no=$(pactl list short sources | grep $pa_vsink_name | cut -f1)


# This is where streaming happens
gst-launch-1.0 ximagesrc use-damage=0 ! \
  video/x-raw,framerate=30/1 ! queue ! \
  videoscale add-borders=true ! \
  videoconvert n-threads=1 ! queue ! \
  avenc_mpeg2video ! \
  video/mpeg,width=${video_h},height=${video_v} ! multiqueue name=q ! \
  mpegtsmux alignment=7 name=mux ! queue2 ! \
  fdsink fd=1 sync=0 \
  pulsesrc device=${pa_vsink_mon_no} ! \
  audioconvert ! queue ! \
  avenc_ac3 ! q. q. ! mux. \
  | nc -l -p ${stream_port}

# Here streaming has just ended

# Revert the default PulseAudio sink
pacmd set-default-sink ${pa_dsink_name}

# Kill virtual sink
pacmd unload-module $(pactl list short modules | grep ${pa_vsink_name} | cut -f1)
