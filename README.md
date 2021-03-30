# fio benchmark container

## Overview

Container following Red Hat best practices for running the fio benchmark. The image is derived from the CentOS 8 distribution. The container defaults to run a mixed read/write workload using a single process to a 4GB file for doing measurements on smaller volumes. This will give a general view of perfomance but it will neither measure peak IOPS or peak storage bandwidth which need to be measured independently. See [other run types](#other-run-types)

## Usage - local Docker or podman

The fiotester container can mount a volume from the local host. If using Fedora/CentOS/RHEL and podman, the label for the directory for the mount should be set to `container_file_t`

Setting up a directory for a volume on Fedora/CentOS/RHEL:

```console
mkdir -p $HOME/fio/data
sudo semanage fcontext -a -t container_file_t "$HOME/fio/data(/.*)?"
sudo restorecon -Rv $HOME/fio/data
sudo podman run -it -v $(pwd)/data:/data fiotest 
```

## Usage - Kubernetes or OpenShift

For running on Kubernetes/OpenShift, see the resource files under [deploy/kubernetes](./deploy/kubernetes). Adjust the storage class as desired in `fiotester-pvc.yaml` and then use either the `k8s` or `oc` deployment files. The difference between the `k8s` and `oc` deployments is in how the security context is set, or not set. For upstream Kubernetes, it's required to set a `pod.spec.securityContext.fsGroup` value to `0` (unless the deployment is going to be modified with additional `supplementalGroups`).

For OpenShift, the admission controller will inspect project where the deployment is being created to automatically populate the pod and container Security Context. The [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html#security-context-constraints-pre-allocated-values_configuring-internal-oauth) describes how the values are determined for the deployment.

In both cases, once the `fsGroup` is set, when mounting the volume, Kubernetes will [recursively change the ownership and permissions](https://v1-19.docs.kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods) to allow group-writing to the persistent volume.

## Other run types

Google Cloud provides a set of [example fio runs](https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance#existing-disk) that can be used to use fio to measure read and write storage throughput and read and write IOPS. The read and write storage throughput runs will create 8 10GB files and the IOPS runs use a single 10GB file so plan your storage capacity accordingly or change the file sizes.

Set the environment variable `COBOL_STILL_EXISTS` to true (the default for Kubernetes) to have the container run script sleep after completing the default run. Then exec into the container to run these more specialized runs.

From a shell in the container, set the `TEST_DIR` environment variable to the data volume:

```console
export TEST_DIR=/data
```

Then run one of the following tests:

- Write throughput test - perform sequential writes with multiple parallel streams (8+), using an I/O block size of 1 MB and an I/O depth of at least 64:

    ```console
    fio --name=write_throughput --directory=$TEST_DIR --numjobs=8 \
    --size=10G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
    --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=write \
    --group_reporting=1
    ```

- Write IOPS test - perform random writes, using an I/O block size of 4 KB and an I/O depth of at least 64:

    ```console
    fio --name=write_iops --directory=$TEST_DIR --size=10G \
    --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
    --verify=0 --bs=4K --iodepth=64 --rw=randwrite --group_reporting=1
    ```

- Read throughput test - perform sequential reads with multiple parallel streams (8+), using an I/O block size of 1 MB and an I/O depth of at least 64:

    ```console
    fio --name=read_throughput --directory=$TEST_DIR --numjobs=8 \
    --size=10G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
    --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=read \
    --group_reporting=1
    ```

- Read IOPS test - perform random reads, using an I/O block size of 4 KB and an I/O depth of at least 64:

    ```console
    fio --name=read_iops --directory=$TEST_DIR --size=10G \
    --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
    --verify=0 --bs=4K --iodepth=64 --rw=randread --group_reporting=1
    ```

- Clean up:

    ```console
    rm $TEST_DIR/write* $TEST_DIR/read*
    ```
