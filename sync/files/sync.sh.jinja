PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

# Check mod if ZFS is loaded
if [[ ! $(lsmod | awk '{print $1}' | grep zfs) ]];
then
    echo "The ZFS module is not loaded";
    salt-call event.fire_master "ZFS module not loaded" salt/alert/harry/rclone
    exit 1
fi

# Check zpool status output for errors
if [[ $( sudo zpool status | grep errors: ) != "errors: No known data errors" ]];
    echo "Errors detected in Zpool!";
    salt-call event.fire_master "Errors Detected in ZPool!" salt/alert/harry/rclone
    exit 1
fi

# If zpool output has no errors, run rClone and rSync tasks
mkdir -p /var/log/rclone
for x in {% for target in rclone.targets %}{{ target }} {% endfor %};
do
    /usr/local/sbin/rclone sync /mnt/storage/${x} backblaze:smartalek-storage/${x} --transfers 32 --log-file /var/log/rclone/rclone_${x}.log --log-level INFO
done

mkdir -p /var/log/rsync
for x in {% for target in rsync.targets %}{{ target }} {% endfor %};
do
    rsync -av --stats --progress --delete /mnt/storage/${x}/ {{rsync.destination }}::${x}/ --log-file=/var/log/rsync/rsync_${x}.log
done
