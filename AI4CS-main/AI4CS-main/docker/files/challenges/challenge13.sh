#!/bin/bash

mkdir -p symlink_it/original_storage
mkdir -p symlink_it/link_room

######################## FLAG SETUP ########################

FLAG="b0n3{sym80l1k_l1nk}"
KEY="symlink_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out symlink_it/hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > symlink_it/checker.sh
#!/bin/bash

LINK_PATH="link_room/treasure_link.txt"
KEY="symlink_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Controllo solo che sia un link
if [[ ! -L "$LINK_PATH" ]]; then
    echo "Symbolic link not found."
    exit 1
fi

# Controllo che il target esista
TARGET=$(readlink -f "$LINK_PATH")
if [[ ! -e "$TARGET" ]]; then
    echo "Symbolic link points to a non-existing file."
    exit 1
fi

# Decrypt e inserimento flag
FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "hidden_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed."
    exit 1
fi

echo "$FLAG" >> "$TARGET"
echo "Flag inserted into the target file."

EOF

chmod +x symlink_it/checker.sh