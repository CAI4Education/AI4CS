#!/bin/bash

mkdir vault1 vault2 vault3

############################ VAULT 1 ############################

touch vault1/hints.txt

for i in {1..40}; do
    echo "random_string_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 25)" >> vault1/hints.txt
done

echo "random_noise look_for_descriptor:vault_key_6 random_noise" >> vault1/hints.txt

for i in {1..40}; do
    echo "another_fake_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 25)" >> vault1/hints.txt
done

############################ VAULT 2 ############################

for i in {1..10}; do
    echo "This file is useless." > vault2/vault_key_$i.txt
done

echo "545 is the code for elevate the privileges" > vault2/vault_key_6.txt

############################ VAULT 3 ############################

FLAG="b0n3{m1n1b05535_4r3_n07h1ng}"
KEY="vault_master_key"

# Cifra flag
echo "$FLAG" | openssl enc -aes-256-cbc -salt -pbkdf2 -a \
-pass pass:$KEY \
-out vault3/encrypted_flag.txt


# ===== CREA final_gate.sh =====
cat << 'EOF' > vault3/final_gate.sh
#!/bin/bash

# Controllo che il file sia eseguibile
if [[ ! -x "$0" ]]; then
    echo "You must elevate execution privileges"
    exit 1
fi

# Controllo permessi numerici
PERM=$(stat -c "%a" "$0")

if [[ "$PERM" != "545" ]]; then
    echo "Wrong permissions. Check on vault 2 the exact code"
    exit 1
fi

KEY="vault_master_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FLAG=$(openssl enc -aes-256-cbc -d -a -pbkdf2 \
-pass pass:$KEY \
-in "$SCRIPT_DIR/encrypted_flag.txt" 2>/dev/null)

if [[ -z "$FLAG" ]]; then
    echo "Decryption failed"
    exit 1
fi

echo "Access granted."
echo "$FLAG"

EOF


# Nessun permesso iniziale
chmod 000 vault3/final_gate.sh


