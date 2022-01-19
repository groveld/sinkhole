# sinkhole

## EdgeRouter Update Script

```sh
#!/bin/vbash

function getJsonVal() {
  python -c "import json,sys;sys.stdout.write(json.dumps(json.load(sys.stdin)$1))";
}

JSON=$(curl -s -X GET https://raw.githubusercontent.com/groveld/sinkhole/lists/lists.json)
NEWFILE=$(echo $JSON | getJsonVal "['default']['dnsmasq']['file']" | tr -d \")
NEWHASH=$(echo $JSON | getJsonVal "['default']['dnsmasq']['hash']" | tr -d \")
OLDFILE=$(readlink -f /etc/dnsmasq.d/dnsmasq-sinkhole.conf)
OLDHASH=$(basename $OLDFILE .conf | cut -d'-' -f2)

if [ "$NEWHASH" == "$OLDHASH" ]; then
  echo "You already have the latest sinkhole list"
  exit 0
else
  curl -s -o /config/user-data/sinkhole-$NEWHASH.conf $NEWFILE
  ln -sfn /config/user-data/sinkhole-$NEWHASH.conf /etc/dnsmasq.d/dnsmasq-sinkhole.conf
  /etc/init.d/dnsmasq force-reload
  rm -rf $OLDFILE
  echo "Finished updating sinkhole list"
  exit 0
fi
```
