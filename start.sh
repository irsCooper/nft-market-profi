set -eu
clear;

echo "[-] Clear Logs..."
# rm logs/network.log
# rm logs/deploy.log
# rm logs/interface.log

sleep 2;

echo "[-] Cleaning Network..."
cd ./backend
npx hardhat clean

sleep 5;

echo "[+] Starting Network..."

npx hardhat node > ../logs/network.log 2>&1 &

sleep 5;

echo "[+] Network is started!"

echo "[+] Compile and deploy contract..."
npx hardhat compile > ../logs/deploy.log 2>&1 &

sleep 30;

npx hardhat run --network localhost scripts/deploy.js > ../logs/deploy.log 2>&1 &

sleep 8;

echo "[+] Deploy the end"

echo "[+] Start interface..."
/bin/python3 /home/crowley/Музыка/profi-project/frontend/main.py
sleep 2;

echo "[+] Interface is started"