
set -eu

clear;

echo "-------------------"
echo "[+] Запуск проекта..."
echo "-------------------"
echo ""

cd ./blockchain && bash network.sh

echo "-------------------"
echo "[+] Установка виртуального окружения python..."
echo "-------------------"
echo ""

cd ../app

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

echo "-------------------"
echo "[+] Запуск веб-приложения..."
echo "-------------------"
echo ""

/bin/python3 main.py
