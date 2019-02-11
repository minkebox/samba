#! /bin/sh

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

trap "echo 'Terminating'; killall inotifywait sleep smbd nmbd; exit" TERM

SIZESLEEP=3600 # 1 hour
STATUSSPACE=/etc/status/space.info
CONF=/etc/samba/shareable.conf

dsize() {
  df /shareable/ > ${STATUSSPACE}.new
  (cd /shareable/; du -d0 *) >> ${STATUSSPACE}.new
  cat ${STATUSSPACE}.new > ${STATUSSPACE}
}

dloop() {
  while true; do
    dsize
    sleep ${SIZESLEEP}
  done
}

dloop &

mkconf() {
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
    (sleep 10; dsize) &
    read event
  done
}

inotifywait -m -e modify,create,delete /shareable/ | mkconf &
wait "$!"
