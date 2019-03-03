#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

CONF=/etc/samba/shareable.conf

mkdir -p /shareable

for name in /shareable/* ; do
  if [ -d "$name" ]; then
    echo "[$(basename "${name}")]" >> ${CONF}
    echo "  path=${name}" >> ${CONF}
    echo "  public = yes" >> ${CONF}
    echo "  writable = yes" >> ${CONF}
    echo "  printable = no" >> ${CONF}
    echo "  browseable = yes" >> ${CONF}
    echo "  guest ok = yes" >> ${CONF}
  fi
done

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
