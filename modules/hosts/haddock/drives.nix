{
    lib,
    ...
}:
{
    den.aspects.haddock.nixos =
        { pkgs, ... }:
        {
            disko.devices.disk.primary = {
                device = "/dev/disk/by-id/nvme-WD_Blue_SN580_1TB_244432808685";
                type = "disk";
                content = {
                    type = "gpt";
                    partitions = {
                        esp = {
                            # This code corresponds to a EFI system partition
                            type = "EF00";
                            size = "500M";
                            content = {
                                type = "filesystem";
                                format = "vfat";
                                mountpoint = "/boot";
                                mountOptions = [ "umask=007" ];
                            };
                        };
                        root = {
                            # Take up the rest of the space on the disk
                            size = "100%";
                            content = {
                                type = "btrfs";
                                postCreateHook = ''
                                    quota_mount=$(mktemp -d)
                                    mount "$device" "$quota_mount" -o subvol=/
                                    trap 'umount "$quota_mount"; rmdir "$quota_mount"' EXIT

                                    if ! btrfs qgroup show "$quota_mount" >/dev/null 2>&1; then
                                        btrfs quota enable "$quota_mount"
                                    fi

                                    btrfs qgroup limit 5G "$quota_mount/@malware_quarantine"
                                '';
                                subvolumes = {
                                    "@" = {
                                        mountpoint = "/";
                                        mountOptions = [ "noatime" ];
                                    };
                                    "@home" = {
                                        mountpoint = "/home";
                                        mountOptions = [
                                            "compress=zstd"
                                            "noatime"
                                        ];
                                    };
                                    "@nix" = {
                                        mountpoint = "/nix";
                                        mountOptions = [
                                            "compress=zstd"
                                            "noatime"
                                        ];
                                    };
                                    "@snapshots" = {
                                        mountpoint = "/.snapshots";
                                        mountOptions = [
                                            "compress=zstd"
                                            "noatime"
                                        ];
                                    };
                                    "@var_lib" = {
                                        mountpoint = "/var/lib";
                                        mountOptions = [
                                            "compress=zstd"
                                            "noatime"
                                        ];
                                    };
                                    "@malware_quarantine" = {
                                        mountpoint = "/var/lib/clamav/quarantine";
                                        mountOptions = [
                                            "compress=zstd"
                                            "noatime"
                                            "noexec"
                                            "nodev"
                                            "nosuid"
                                        ];
                                    };
                                };
                            };
                        };
                    };
                };
            };

            # This is defined here instead of in disko.devices because I don't want Disko formatting these
            # This is actually multiple drives combined into one filesystem
            fileSystems."/mnt/media" = {
                device = "/dev/disk/by-id/ata-ST4000DM004-2CV104_ZFN35CMF";
                fsType = "btrfs";
            };

            services.btrfs.autoScrub = {
                enable = true;
                fileSystems = [
                    "/"
                    "/mnt/media"
                ];
            };

            # Stagger the two filesystems so their scrubs do not compete for I/O.
            systemd.timers = {
                "btrfs-scrub--".timerConfig.OnCalendar = lib.mkForce "*-*-01 03:00:00";
                "btrfs-scrub-mnt-media".timerConfig.OnCalendar = lib.mkForce "*-*-15 03:00:00";
            };

            systemd.services = {
                "btrfs-scrub--".unitConfig.OnFailure = "notify-btrfs-scrub-failure@%n.service";
                "btrfs-scrub-mnt-media".unitConfig.OnFailure = "notify-btrfs-scrub-failure@%n.service";

                "notify-btrfs-scrub-failure@" = {
                    description = "Email notification for failed Btrfs scrub unit %I";
                    serviceConfig = {
                        Type = "oneshot";
                        ExecStart =
                            lib.getExe (
                                pkgs.writeShellApplication {
                                    name = "notify-btrfs-scrub-failure";
                                    text = ''
                                        unit="$1"

                                        {
                                          printf 'To: root\n'
                                          printf 'From: Btrfs <haddock@mailbox.org>\n'
                                          printf 'Subject: Btrfs scrub failed on haddock: %s\n' "$unit"
                                          printf 'Content-Type: text/plain; charset=UTF-8\n'
                                          printf '\n'
                                          ${lib.getExe' pkgs.systemd "journalctl"} --boot --unit "$unit" --lines 100 --no-pager
                                        } | /run/wrappers/bin/sendmail -t
                                    '';
                                }
                            )
                            + " %I";
                    };
                };
            };
        };
}
