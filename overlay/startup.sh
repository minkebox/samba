#! /bin/sh

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

trap "echo 'Terminating'; killall inotifywait smbd nmbd; exit" TERM

CONF=/etc/samba/shareable.conf
while true; do
  echo > ${CONF}
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
  killall -HUP smbd
  inotifywait -e modify,create,delete /shareable/ &
  wait "$!"
done
