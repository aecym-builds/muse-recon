#!/bin/sh
cd /data/user/0/ai.antigem/files/home/projects/muse_recon/apktool_out || exit 1
L="$TMPDIR/muse_list.txt"; [ -z "$TMPDIR" ] && L=/data/data/ai.antigem/files/usr/tmp/muse_list.txt
for d in smali smali_classes2 smali_classes3 smali_classes4 smali_classes5 smali_classes6 smali_classes7; do
  : > "$L"
  for p in com/facebook X com/meta com/instagram; do
    [ -d "$d/$p" ] && find "$d/$p" -type f >> "$L"
  done
  echo "== $d $(wc -l < "$L") files"
  zip -9 -q -@ "../smali_parts/$d.zip" < "$L" || echo "ZIP FAIL $d"
  ls -lh "../smali_parts/$d.zip" | awk '{print $5, $9}'
done
