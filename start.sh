
set -eu

clear;

echo "-------------------"
echo "[+] Запуск проекта..."
echo "-------------------"
echo ""

cd ./backend && bash network.sh

echo "-------------------"
echo "[+] Запуск интерфейса..."
echo "-------------------"
echo ""

/bin/python3 ../frontend/main.py
