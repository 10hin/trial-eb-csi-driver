# trial-volumesnapshot

## trial steps

### prepare environment

1. run and up EKS cluster
2. install external-snapshotter
3. install aws-ebs-csi-driver
4. create storageclasses/volumesnapshotclasses
    ```bash
    kubectl apply -f storageclasses/gp2.yaml
    kubectl apply -f volumesnapshotclasses/ebs.yaml
    ```

### run volume-consumer apps

```bash
kubectl apply -f volume-consumer/consumer.yaml
```

### get az of `web-0` running

```bash
kubectl get no "$(kubect get po web-0 -o jsonpath='{.spec.nodeName}')" -L topology.kubernetes.io/zone
```

### scale down nodegroup

in previous step, you get availability-zone (az) where `web-0` pod runinng.

run **ONE** OF FOLLOWING COMMANDS according to the az:

- if `web-0` runs on **ap-northeast-1c**:

    ```bash
    eksctl scale nodegroup apne1-az1-default --nodes=0 --nodes-min=0
    ```

- if `web-0` runs on **ap-northeast-1d**:

    ```bash
    eksctl scale nodegroup apne1-az2-default --nodes=0 --nodes-min=0
    ```

- if `web-0` runs on **ap-northeast-1a**:

    ```bash
    eksctl scale nodegroup apne1-az4-default --nodes=0 --nodes-min=0
    ```

This will shutdown Node where `web-0` Pod running on.
`web-0` will go into `Pending` state.

### create volumesnapshot

```bash
kubectl apply -f trial-volumesnapshot/www-web-0-volumesnapshot.yaml
```

wait snapshots are ready:

```bash
kubectl get vsc "$(kubectl get vs www-web-0-0 -o jsonpath='{.status
.boundVolumeSnapshotContentName}')"
```

>
> READYTOUSE columns shows readiness of snapshot
>

Snapshot status can also check with AWS API (i.e. `aws` command), but much complicated:

```bash
aws ec2 describe-snapshots --snapshot-ids "$(kubectl get vsc "$(kub
ectl get vs www-web-0-0 -o jsonpath='{.status.boundVolumeSnapshotContentName}')" -o jsonpath='{.status.snapshotHandle}')"
```

>
> finding Amazon EBS Volume ID:
>
> ```bash
> kubectl get pv "$(kubectl get pvc www-web-0 -o jsonpath='{.spec.volumeName}')" -o jsonpath='{.spec.csi.volumeHandle}'
> ```
>
