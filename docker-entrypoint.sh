#!/bin/bash
# https://github.com/s3fs-fuse/s3fs-fuse/wiki/Fuse-Over-Amazon
# Environment variables:
# AWSACCESSKEYID='fcIZ6sjuZaX5sxM8v6t5'
# AWSSECRETACCESSKEY='T0fwpoH4IDryyjHdMFX0oSz0Pxsrvwt1pxoRshuT'
# S3FS_EMPTYDIR='/vol'
# S3FS_PASSWD='/secret/passwd-s3fs'
# S3FS_URL='http://minio-1606344459.minio.svc.cluster.local:9000'
# S3FS_OPTIONS='use_path_request_style'
# S3FS_BUCKET01='project1:/some/path'
# S3FS_BUCKET02='project2'
# S3FS_BUCKET03='project3'

# Source files in docker-entrypoint.d/ dump directory
IFS=$'\n' eval 'for f in $(find /docker-entrypoint.d/ -type f -print |sort); do source ${f}; done'

# Sanity checks
[ -z $S3FS_EMPTYDIR ] && { 1>&2 echo "ERROR: S3FS_EMPTYDIR environment variable must be set to the mountPath of an EmptyDir volume"; exit 128; }
passwd_file=$(echo "${S3FS_OPTIONS}" |sed -n 's/^.*passwd_file=\([^,]\+\).*$/\1/p')
if ! [ -f "${passwd_file}" -o -f "${HOME}/.aws/credentials" -o -f "${HOME}/.passwd-s3fs" -o -f "/etc/passwd-s3fs" ]; then
	[ -z $AWSACCESSKEYID -o -z $AWSSECRETACCESSKEY ] && \
		{ 1>&2 echo "ERROR: Credentials have not been provided, please make reference to the README for options"; exit 128; }
fi

function cleanup {
	for varname in ${!S3FS_BUCKET*}; do
		declare -n bucket=$varname
		IFS=':' read -r bucket_name bucket_path <<< "${bucket}"
		echo "INFO: umount ${S3FS_EMPTYDIR}/${bucket_name}"
		umount "${S3FS_EMPTYDIR}/${bucket_name}" | true
	done
	# Verify umount of all volumes has completed
	i=0
	while mount |grep -q 'type fuse.s3fs '; do
		if [[ $i -ge 30 ]]; then
			2>&1 2>$1 echo "ERROR: Not all buckets have unmounted, mount(s) listed below"
			2>&1 mount |grep 'type fuse.s3fs '
			i=0
		else
			i=$((i+1))
		fi
		sleep 2
	done
}
trap cleanup EXIT
set -e

for varname in ${!S3FS_BUCKET*}; do
	declare -n bucket=$varname
	IFS=':' read -r bucket_name bucket_path <<< "${bucket}"
	[ -d "${S3FS_EMPTYDIR}/${bucket_name}" ] || mkdir -p "${S3FS_EMPTYDIR}/${bucket_name}"
	echo "INFO: s3fs $bucket ${S3FS_EMPTYDIR}/${bucket_name} -o ${S3FS_OPTIONS} -f &"
	s3fs $bucket ${S3FS_EMPTYDIR}/${bucket_name} -o ${S3FS_OPTIONS} -f &
done

# CMD run
$@
