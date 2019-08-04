#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

CONF=/etc/samba/shareable.conf
GUEST=yes

if [ "${SAMBA_USERNAME}" != "" ]; then
  GUEST=no
  adduser -D -s /sbin/nologin ${SAMBA_USERNAME}
  if [ "${SAMBA_PASSWORD}" = "" ]; then
    passwd -u ${SAMBA_USERNAME}
    (echo ; echo) | smbpasswd -s -a ${SAMBA_USERNAME}
    smbpasswd -n ${SAMBA_USERNAME}
  else
    echo ${SAMBA_USERNAME}:${SAMBA_PASSWORD} | chpasswd > /dev/null
    (echo ${SAMBA_PASSWORD} ; echo ${SAMBA_PASSWORD}) | smbpasswd -s -a ${SAMBA_USERNAME}
  fi
  smbpasswd -e ${SAMBA_USERNAME}
fi

mkdir -p /shareable

for name in /shareable/* ; do
  if [ -d "$name" ]; then
    echo "[$(basename "${name}")]
  path=${name}
  writable = yes
  printable = no
  browseable = yes
  guest ok = ${GUEST}" >> ${CONF}
  fi
done

SMB_GROUP=$(grep -i '^\s*workgroup\s*=' /etc/samba/smb.conf | cut -f2 -d= | tr -d '[:blank:]')

/usr/sbin/nmbd -D
/usr/sbin/smbd -D
/wsdd.py -i ${__HOME_INTERFACE} -4 -w ${SMB_GROUP} &

sleep 2147483647d &
wait "$!"
