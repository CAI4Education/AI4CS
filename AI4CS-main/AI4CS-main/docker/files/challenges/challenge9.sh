#!/bin/bash

mkdir -p mv_it/enemy_house
mkdir -p mv_it/my_house

######################## FILE TO MOVE ########################

echo "I need to bring the bone to my house" > mv_it/enemy_house/treasure.txt


######################## FLAG SETUP ########################

FLAG="b0n3{lup1n_7h3_7h1rd}"
KEY="mv_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out mv_it/hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > mv_it/checker.sh
#!/bin/bash

SOURCE="enemy_house/treasure.txt"
DEST="my_house/treasure.txt"
KEY="mv_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

if [[ -f "$SOURCE" ]]; then
    echo "The file is still inside enemy_house."
    exit 1
fi

if [[ ! -f "$DEST" ]]; then
    echo "File not found inside my_house."
    exit 1
fi

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "hidden_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed."
    exit 1
fi

echo "$FLAG" >> "$DEST"
echo "Flag inserted into my_house/treasure.txt."

EOF

chmod +x mv_it/checker.sh

