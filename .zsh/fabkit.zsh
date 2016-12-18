#compdef fab

_fabkit() {
  if [ -e nodes ]; then
    for node in `find nodes/ -type d | sed -e 's/nodes\///'`
    do
      compadd "node:${node}"
    done
  fi

  if [ -e fablib ]; then
    for fablib in `find fablib/ -type d -maxdepth 1 | sed -e 's/fablib\///'`
    do
      compadd "test:${fablib}"
    done
  fi
}

compdef _fabkit fab
