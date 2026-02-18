#!/bin/bash


######################## FLAG SETUP ########################

FLAG="b0n3{b0n3_cr3473d}"
KEY="creation_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > checker.sh
#!/bin/bash

TARGET_FILE="my_first_file"
KEY="creation_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$TARGET_FILE" ]]; then
    echo "File 'my_first_file' not found."
    exit 1
fi

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "$SCRIPT_DIR/hidden_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed."
    exit 1
fi

echo "$FLAG" >> "$TARGET_FILE"
echo "Flag inserted into $TARGET_FILE."

EOF

chmod +x checker.sh
