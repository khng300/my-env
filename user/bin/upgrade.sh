#!/bin/sh

if [ x"$SRCTOP" = x ]; then
	printf "SRCTOP environment variable is not set!\n" 2>&1
	exit 1
fi

bectl destroy default-old
bectl destroy default-next
bectl create default-next
bectl mount default-next /mnt
make DESTDIR=/mnt -j40 installworld installkernel
etcupdate -D /mnt -s "$SRCTOP"
rm -rf /mnt/usr/src
tar -cf- --uid=0 --gid=0 --exclude-vcs --exclude='./compile_commands.json' --exclude='./.ccls-cache' --exclude='./.cache' -s "|^$SRCTOP|usr/src|" "$SRCTOP" | (tar -C/mnt -xf-)
bectl umount default-next
bectl rename default default-old
bectl rename default-next default
bectl activate default
bectl list
