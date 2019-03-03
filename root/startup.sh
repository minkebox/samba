#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

CONF=/etc/samba/shareable.conf

mkdir -p /shareable /myshares /tmp/links

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

IFS='
'
for name in $(ls /myshares) ; do
  ln -s ${name} /tmp/links/${name}
done
for name in $(cat /etc/extra-shares) ; do
  mkdir -p /myshares/${name}
  rm -rf /tmp/links/${name}
  echo "[${name}]" >> ${CONF}
  echo "  path=/myshares/${name}" >> ${CONF}
  echo "  public = yes" >> ${CONF}
  echo "  writable = yes" >> ${CONF}
  echo "  printable = no" >> ${CONF}
  echo "  browseable = yes" >> ${CONF}
  echo "  guest ok = yes" >> ${CONF}
done
for name in $(ls /tmp/links) ; do
  rm -rf /tmp/links/${name} /myshares/${name}
done

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
