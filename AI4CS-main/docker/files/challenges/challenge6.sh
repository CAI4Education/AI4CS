#!/bin/bash

mkdir executable
cd executable

######################## FLAG SETUP ########################

FLAG="b0n3{Jus7_d0_17_3x3_17}"
KEY="starter_key"

# Crea flag criptata
echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out secret_flag.enc


######################## EXECUTABLE ########################

cat << 'EOF' > run_me.sh
#!/bin/bash

KEY="starter_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "$SCRIPT_DIR/secret_flag.enc" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Something went wrong..."
    exit 1
fi

echo "Access granted!"
echo "$FLAG"

EOF

chmod +x run_me.sh
