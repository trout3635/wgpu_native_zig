#!/bin/bash

# this script updates the wgpu dependencies and hashes in build.zig.zon

wgpu_url="github.com/gfx-rs/wgpu-native/releases/latest/download/"
# the url is a redirect, zig fetch can't work with it so we resolve the redirect with curl
wgpu_redirect_url=$(curl -sL -o /dev/null -w "%{url_effective}\n" "$wgpu_url")

grep '.url = "' "build.zig.zon" | while IFS= read -r line; do
  # extract the URL string
  url=$(echo "$line" | sed -n 's/.*\.url = "\([^"]*\)".*/\1/p')
  # skip if empty or non wgpu-native
  [[ -z "$url" || ! "$url" =~ ^https://github.com/gfx-rs/wgpu-native ]] && continue
  
  filename=$(basename "$url")
  filename="${filename%%\?*}" # remove query parameters
  dep_name="${filename%.*}" # discard .zip
  dep_name="${dep_name//-/_}" # replace - with _
  dep_name="${dep_name//i686/x86}" # replace i686 with x86
  

  zig fetch --save="$dep_name" "$wgpu_redirect_url/$filename" 

done
