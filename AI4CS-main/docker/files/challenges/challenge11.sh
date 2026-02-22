#!/bin/bash

mkdir mkdir_it
cd mkdir_it

######################## FLAG SETUP ########################

FLAG="b0n3{m4k3_17_h4pp3n3d}"
KEY="mkdir_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > checker.sh
#!/bin/bash

TARGET_DIR="my_first_dir"
KEY="mkdir_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Directory 'my_first_dir' not found."
    exit 1
fi

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "hidden_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed."
    exit 1
fi

echo "$FLAG" > "$TARGET_DIR/flag.txt"
echo "Flag inserted into $TARGET_DIR/flag.txt."

EOF

chmod +x checker.sh
