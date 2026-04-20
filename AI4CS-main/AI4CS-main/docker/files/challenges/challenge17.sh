#!/bin/bash

# Setup environment
mkdir -p workspace/vault

# 1. Generate trash files
for i in {1..20}; do
    echo "useless data $i" > "workspace/junk_$i.tmp"
done

# 2. Generate the important file
echo "TOP_SECRET_DESIGN" > "workspace/blueprint.doc"

# 3. Create the verification script (The Enemy)
cat << 'EOF' > workspace/verify_cleanup.sh
#!/bin/bash

# Check if .tmp files still exist
if ls *.tmp 1> /dev/null 2>&1; then
    echo "[FAIL] The area is still dirty. Remove all .tmp files!"
    exit 1
fi

# Check for the report file
if [[ ! -f "report.txt" ]]; then
    echo "[FAIL] 'report.txt' is missing."
    exit 1
fi

# Check content of report
CONTENT=$(cat report.txt)
if [[ "$CONTENT" != "CLEAN" ]]; then
    echo "[FAIL] The report does not say 'CLEAN'."
    exit 1
fi

# Check if blueprint was moved
if [[ -f "blueprint.doc" ]]; then
    echo "[FAIL] The blueprint is still outside the vault!"
    exit 1
fi

if [[ ! -f "vault/blueprint.doc" ]]; then
    echo "[FAIL] The blueprint is missing from the vault."
    exit 1
fi

echo "Scrapyard Secured."
echo "FLAG: b0n3{rubb1sh_c0ll3ct0r_m4st3r}"
EOF

chmod +x workspace/verify_cleanup.sh

echo "Challenge 18 initiated. Check the 'workspace' folder."