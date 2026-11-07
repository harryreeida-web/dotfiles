dir=$1
[[ $dir == 0 ]] && exit

monitor=$(mmsg get last_open_surface | jq -r '.monitor')
curr=$(mmsg get monitor $monitor | jq -r '.tags | map(select(.is_active == true)) | .[0] | .index')
dest=$((curr+dir))

tag_num=$(mmsg get monitor $monitor | jq -r ".tag_num")
[[ $dest -lt 1 || $dest -gt $tag_num ]] && exit

clients=$(mmsg get all-clients | jq -r ".clients")
curr_clients=$(echo $clients | jq -r "map(select(.tags == [$curr]) | select(.monitor == \"$monitor\") | .id) | .[]")
dest_clients=$(echo $clients | jq -r "map(select(.tags == [$dest]) | select(.monitor == \"$monitor\") | .id) | .[]")
focusing_client=$(mmsg get focusing-client | jq -r ".id")

# Janky hack to get value of tag_gather
old_tag_gather=$(grep -E '^tag_gather=' ~/.config/mango/config.conf | cut -d= -f2)
mmsg dispatch setoption,tag_gather,0
for client in ${dest_clients}; do
    mmsg dispatch tagsilent,0 client,$client
done
mmsg dispatch view,$dest

for client in ${curr_clients}; do
    mmsg dispatch tagsilent,$dest client,$client
done
for client in ${dest_clients}; do
    mmsg dispatch tagsilent,$curr client,$client
done
mmsg dispatch focusid client,$focusing_client
mmsg dispatch setoption,tag_gather,$old_tag_gather
