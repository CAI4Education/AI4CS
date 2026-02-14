#!/bin/bash

######################## FAKE FILE ########################

echo "b0n3{not_this_time}" > my_first_file


######################## FLAG SETUP ########################

FLAG="b0n3{3l1m1n471ng_7h3_3n3m135}"
KEY="rm_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > checker.sh
#!/bin/bash

TARGET_FILE="my_first_file"
KEY="rm_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -f "$TARGET_FILE" ]]; then
    echo "File still exists. Remove it first."
    exit 1
fi

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "$SCRIPT_DIR/hidden_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed."
    exit 1
fi

echo "$FLAG"

EOF

chmod +x checker.sh

