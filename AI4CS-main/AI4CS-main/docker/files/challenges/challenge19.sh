#!/bin/bash

mkdir -p system_core
cd system_core

################ STEP 1: GREP PUZZLE (Distraction) ################
# Creiamo un log enorme per confondere l'utente, ma serve solo come "tutorial" per grep
for i in {1..500}; do
    echo "[INFO] System normal check $i" >> server.log
done
echo "[CRITICAL_KEY] The key is NOT here, look at the config files!" >> server.log
for i in {501..1000}; do
    echo "[INFO] System normal check $i" >> server.log
done

################ STEP 2: DIFF & BASE64 PUZZLE (Real Solution) ################

# Creiamo la password segreta: "victory" codificato in base64 è "dmljdG9yeQ=="
SECRET_CODE="dmljdG9yeQ=="

# File config V1 (Normale)
echo "setting_a=true" > config_v1.txt
echo "setting_b=100" >> config_v1.txt
echo "setting_c=low" >> config_v1.txt

# File config V2 (Contiene la riga extra con il codice)
echo "setting_a=true" > config_v2.txt
echo "setting_b=100" >> config_v2.txt
echo "override_code=$SECRET_CODE" >> config_v2.txt
echo "setting_c=low" >> config_v2.txt

################ STEP 3: VERIFICATION SCRIPT ################

cat << 'EOF' > unlock_core.sh
#!/bin/bash

if [[ ! -f "password.txt" ]]; then
    echo "[ACCESS DENIED] password.txt file not found."
    exit 1
fi

# Legge la password inserita dall'utente
USER_PASS=$(cat password.txt)

# La password corretta è "victory" (che è la decodifica di dmljdG9yeQ==)
if [[ "$USER_PASS" == "victory" ]]; then
    echo "=========================================="
    echo " CORE UNLOCKED. SYSTEM CONTROL RESTORED."
    echo "=========================================="
    echo "CONGRATULATIONS! FINAL FLAG: b0n3{m4st3r_0f_th3_sh3ll}"
else
    echo "[ACCESS DENIED] Incorrect password. Did you decode it correctly?"
    exit 1
fi
EOF

chmod +x unlock_core.sh

cd ..
echo "FINAL CHALLENGE initiated. Check the 'system_core' folder."