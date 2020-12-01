# apt-get -y install libnss-wrapper
USER_ID=$(id -u)
GROUP_ID=$(id -g)
[ -z $USER ] && export USER='user'
[ -z $LOGNAME ] && export LOGNAME="${USER}"

# Is user in passwd file
if ! grep -q ":${USER_ID}:" /etc/passwd; then
	NSS_WRAPPER_PASSWD=/tmp/passwd.nss_wrapper
	NSS_WRAPPER_GROUP=/etc/group

	echo "${USER}:x:${USER_ID}:${GROUP_ID}:Docker user,,,:/tmp:/bin/bash" | \
		cat /etc/passwd - > $NSS_WRAPPER_PASSWD

	if ! grep -q ":${GROUP_ID}:" /etc/group; then
		NSS_WRAPPER_GROUP=/tmp/group.nss_wrapper
		echo "${USER}:x:${GROUP_ID}:" | \
			cat /etc/group - > $NSS_WRAPPER_GROUP
	fi

	LD_PRELOAD=/usr/lib/libnss_wrapper.so
	export NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP LD_PRELOAD
fi

# Copyright [2017] [Dean Taylor]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
