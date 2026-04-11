# Media

This is my "media grabbing" suite.

1. The *arr apps crawl trackers for media and send requests for the media to qBittorrent
2. qBittorrent retrieves them
3. The *arr apps then hard link them into Jellyfin's media library directory
4. Then you can watch the media in Jellyfin! 🪼🍿

I followed [TRaSH Guides](https://trash-guides.info/Hardlinks/How-to-setup-for/Native/) to get this all working with hard links.

Make sure `data/` is owned by the `media` group, and all new files are created with `rw-` permissions for groups. You can do that like this:

```bash
cd /mnt/media
sudo chown -R media:media data/media
sudo chown -R qbittorrent:media data/torrents
sudo chmod g+s data/
sudo setfacl -Rdm g::rwX data/
```
