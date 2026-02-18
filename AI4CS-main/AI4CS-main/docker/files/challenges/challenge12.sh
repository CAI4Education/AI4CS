#!/bin/bash

mkdir -p find_it/maze/level1
mkdir -p find_it/maze/level2
mkdir -p find_it/maze/level3/hidden_spot

cd find_it

######################## CREATE MANY FILES ########################

for i in {1..30}; do
    touch maze/level1/random_file_$i.txt
    touch maze/level2/random_doc_$i.log
done

touch maze/level3/hidden_spot/target_file.txt


######################## FLAG SETUP ########################

FLAG="b0n3{f1nd_7h3_tr3sur3}"
KEY="find_key"

echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out hidden_flag.enc


######################## CHECKER ########################

cat << 'EOF' > checker.sh
#!/bin/bash

TARGET_FILE="maze/level3/hidden_spot/target_file.txt"
KEY="find_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

if [[ ! -f "$TARGET_FILE" ]]; then
    echo "Target file not found."
    exit 1
fi

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "hidden_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed."
    exit 1
fi

echo "$FLAG" >> "$TARGET_FILE"
echo "Flag inserted into target_file.txt."

EOF

chmod +x checker.sh

