#!/bin/bash

mkdir -p cp_it/enemy_house
mkdir -p cp_it/my_house

######################## FILE TO COPY ########################

echo "I need a copy of this bone in my house" > cp_it/enemy_house/treasure.txt


######################## FLAG SETUP ########################

FLAG="b0n3{c0py_th3_tr34sur3}"
KEY="cp_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out cp_it/hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > cp_it/checker.sh
#!/bin/bash

SOURCE="enemy_house/treasure.txt"
DEST="my_house/treasure.txt"
KEY="cp_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

# Il file deve esistere ancora nella casa nemica (perché deve essere copiato, non spostato)
if [[ ! -f "$SOURCE" ]]; then
    echo "Original file missing from enemy_house."
    exit 1
fi

# Il file deve esistere nella casa del player
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

chmod +x cp_it/checker.sh

echo "Challenge ready."
