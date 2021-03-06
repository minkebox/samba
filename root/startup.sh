#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

IFACE=eth0
SMB_CONF=/etc/samba/smb.conf
WORKGROUP_CONF=/etc/samba/workgroup.conf
SHARES_CONF=/etc/samba/shareable.conf
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

if [ "${SAMBA_WORKGROUP}" != "" ]; then
  echo "workgroup = ${SAMBA_WORKGROUP}" > ${WORKGROUP_CONF}
fi

mkdir -p /shareable

for name in /shareable/* ; do
  if [ -d "$name" ]; then
    echo "[$(basename "${name}")]
  path=${name}
  writable = yes
  printable = no
  browseable = yes
  guest ok = ${GUEST}" >> ${SHARES_CONF}
  fi
done

/usr/sbin/nmbd -D
/usr/sbin/smbd -D
/wsdd.py -i ${IFACE} -4 -w $(grep -i '^\s*workgroup\s*=' ${WORKGROUP_CONF} | cut -f2 -d= | tr -d '[:blank:]') &

sleep 2147483647d &
wait "$!"
