#!/bin/bash

######################## FLAG SETUP ########################

FLAG="b0n3{3nv_v4r14bl3_m4573r}"

# Variabile d'ambiente temporanea
export SECRET_FLAG="$FLAG"

######################## CHECKER ########################

cat << 'EOF' > checker.sh
#!/bin/bash

EXPECTED_FLAG="b0n3{3nv_v4r14bl3_m4573r}"

if [[ -z "$SECRET_FLAG" ]]; then
    echo "Environment variable not found."
    exit 1
fi

if [[ "$SECRET_FLAG" != "$EXPECTED_FLAG" ]]; then
    echo "Incorrect value."
    exit 1
fi

echo "Correct! You found the flag:"
echo "$SECRET_FLAG"

EOF

chmod +x checker.sh
