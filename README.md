# fio benchmark container

The fiotester container can mount a volume from the local host. If using Fedora/CentOS/RHEL and podman, the label for the directory for the mount should be set to `container_file_t`

Setting up a directory for a volume on Fedora/CentOS/RHEL:

```
sudo semanage fcontext -a -t container_file_t '/home/user/fio/data(/.*)?'
sudo restorecon -Rv /home/user/fio/data
sudo podman run -it -v $(pwd)/data:/data fiotest 
```
