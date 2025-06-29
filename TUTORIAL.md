# <a id="название">Пошаговый туториал по созданию такого проекта</a>

## <a id="содержание">Содержание</a>
- [Необходимое ПО](#ПО)
- [Базовая структура проекта](#структура)
- [Hardhat](#hardhat)
- [Смарт-контракт](#смарт)
- [Тестирование смарт-контракта](#help)
- [Запуск сети и деплой контракта в hardhat](#start)
- [Итоги](#итог)



## <a id="ПО">Для работы нам подадобится следующее ПО:</a>
- [Hardhat](https://hardhat.org/hardhat-runner/docs/getting-started)
- [Python](https://www.python.org/downloads/)
- [Web3](https://pypi.org/project/web3/)
- [Flask](https://pypi.org/project/Flask/)
- [OpenZeppelin standart token ERC1155 and ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts)
#### Убедившись, что у нас всё установлено - можем приступить к созданию проекта


## <a id="структура">Базовая структура проекта</a> 
```
project
├── app 
├── blockchain 
├── images 
├── README.md
└── start.sh 
```


## <a id="hardhat">Hardhat</a>

Открываем папку *backend* в терминале и пишем следующие команды:

```sh
npm init
npx hardhat 
```

В появляющейся менюшке выбираем между js и ts.
Отлично, папка сгенерировалась!
Теперь, для успешной работы нашего проекта подребуется изменить следующие файлы:<br>
### /hardhat.config.js
```js
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
};

```

### /scripts/deploy.js
```js
const { ethers } = require("hardhat");

async function main() {
  const Contract = await ethers.getContractFactory("Contract");
  const contract = await Contract.deploy();

  // await myContract.waitForDeployment();


  // пуш адресса контракта в файл json 
  const fs = require("fs");
  const path = require("path");
  
  const filePath = path.join(__dirname, "../artifacts/contracts/contract.sol/Contract.json");
  const filePathUsers = path.join(__dirname, "../artifacts/contracts/user.sol/Users.json");
  
  let data = fs.existsSync(filePath) ? JSON.parse(fs.readFileSync(filePath)) : {};
  data.address = contract.target;  
  // data.address = contract.address; //for home
  fs.writeFileSync(filePath, JSON.stringify(data));
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
});
```

К сети вернёмся чуть позже. Теперь нам нужно написать смарт-контракт


## <a id="смарт">Смарт-контракт</a>
Переходим в папку __blockchain/contracts__. Удаляем сгенереный хардхедом контракт и пишем свой. 

Подробно описывать как это сделать я не буду, можете руководствоваться моим примером, или попробуйте написать самостоятельно.

## <a id="help">Тестирование смарт-контракта</a>
Теперь нам необходимо проверить работоспособность нашего контракта, для этого переходим в онлайн ide - [Remix](https://remix.ethereum.org/#optimize=true&runs=200&evmVersion=null&version=soljson-v0.8.23+commit.f704f362.js&lang=en), и тестируем все написанные функции.


## <a id="start">Запуск сети и деплой контракта в hardhat</a>
Чтобы поднять сеть, нам нужно открыть терминал в папке *backend* и написать:

```sh
npx hardhat clean (всегда перед запуском нужно очищать нашу сеть от прошлых версий)
npx hardhat node 
```

В терминале должны были появиться адреса и секретные ключи пользователей, если они есть, всё отлично, сеть запущена! __Останавливать выполнение файла нельзя!!!__, потому что иначе мы остановим сеть. <br><br>

Для выполнения следующих команд открываем новый терминал, и открываем в нём нашу папку с проектом
далее, пишем следующие команды: 

```sh
npx hardhat compile 
npx hardhat run --network localhost scripts/deploy.js
```

Если ошибок нет - отлично, мы задеплоили наш контракт! Если есть, то... __Удачных вам голодных игр!__


#### Отлично! Теперь приступаем к написанию веб приложения, описывать которое я подробно не стану, думаю вы и сами справитесь ;)

## <a id="итог">Итоги</a>
- Создали локальную сеть 
- Написали смарт-контракт
- Протестировали смарт-контракт
- Запустили локальную сеть
- Написали взаимодействие с блокчейном
- Создали веб приложение для пользователей платформы 