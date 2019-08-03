#! /usr/bin/env bash
set -e
echo "command to format (do manually): bcachefs format --compression=lz4 --background_compression=zstd --foreground_target=/dev/sda1 --background_target=/dev/sdb2 --promote_target=/dev/sda1 --encrypted --label=nixos --force /dev/sdb2 /dev/sda1"
echo "when done, enter password: "
read
echo "$REPLY" | bcachefs unlock /dev/sda1
mount -t bcachefs /dev/sda1:/dev/sdb2 /mnt
nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
nix-channel --update
nix-env -iA unstable.gitAndTools.transcrypt
nix-env -i -f ./restic-restore.nix
yes | transcrypt -c aes-256-cbc -p "$REPLY"
set -a
source ../secrets/wasabi-bismuth-restic.env
RESTIC_REPOSITORY="s3:https://s3.eu-central-1.wasabisys.com/hyperfekt-personal-backup"
RESTIC_PASSWORD_FILE=$(realpath ../secrets/restic-normal-backup.pass)
set +a
restic restore latest --target /mnt -v
mount /dev/sdb1 /mnt/boot
echo "restore done. have fun installing <.<"
