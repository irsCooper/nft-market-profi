#! /usr/bin/sh

set -eu

clear;

echo "-------------------"
echo "Install Dependencies..."
echo "-------------------"
sudo npm install

echo "-------------------"
echo "[-] Очистка сети..."
echo "-------------------"
echo ""
npx hardhat clean


echo "-------------------"
echo "[+] Запуск сети..."
echo "-------------------"
echo ""
sleep 2;
gnome-terminal -- npx hardhat node

echo "-------------------"
echo "[+] Компилируем контракт..."
echo "-------------------"
echo ""
sleep 25;
npx hardhat compile

echo "-------------------"
echo "[+] Деплоим контракт..."
echo "-------------------"
echo ""
sleep 5;
npx hardhat run --network localhost scripts/deploy.js

echo "-------------------"
echo "Сеть запущенна и готова к работе"
echo "-------------------"
echo ""
