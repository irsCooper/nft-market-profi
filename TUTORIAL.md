# <a id="название">Пошаговый туториал по созданию такого проекта</a>

## <a id="содержание">Содержание</a>
- [Необходимое ПО](#ПО)
- [Базовая структура проекта](#структура)
- [Hardhat](#hardhat)
- [Смарт-контракт](#смарт)
- [Тестирование смарт-контракта](#help)
- [Запуск сети и деплой контракта в hardhat](#start)
- [Разработка веб приложения на Python / Flask / Jinja2](#user)
- [Клиент для работы с экземпляром смарт-контракта](#client)
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


## <a id="user">Разработка веб приложения на Python / Flask / Jinja2</a>
После того, как мы убедились что наша логика смарт-контракта полностью рабочаяя, можем приступить к написанию веб приложения для работы с пользователями. 

Для начала нам потребуется создать архитектуру следующим образом:
```sh
app
   ├── .venv # зависимости
   ├── src # тут описывать вашу логику
   │   ├── blockchain # клиент для взаимодействия с блокчейном
   │   ├── user # пример папки с логикой
   │   |    └── router.py
   │   └── ...your_logic # остальные ваши логические модули
   ├── static # css стили и изображения
   ├── templates # html страницы
   ├── main.py # файл запуска программы
   └── requirements.txt # зависимости проекта
```


### Настройка виртуального окружения
Прежде чем начать работу, создадим виртуальное окружение, в котором будем работать. Для этого открываем терминал в новой папке __app__ и пишем следующую команду 

```sh
python -m venv .venv
```

Активируем виртуальное окружение следующими командами

Windows
```bat
.\.venv\Scripts\activate
```

Linux
```sh
source .venv/bin/activate
```

Отлично, теперь скачиваем нужные библиотеки
```sh
pip install flask web3
```

Если вы пользуетесь Visual Studio Code, для того, чтобы переключить окружение python на наше новое виртуальное окружение (чтобы мы видели подсказки и библиотеки подсвечивались в ide) нажмите комбинацию клавиш __Ctrl + Shift + P__ и выберете __Python: Select Interpreter__.


Далее выберете __Python (.venv) .\venv\Scripts\python.exe__.


Для сохранения наших зависимостей выполним команду 
```sh
pip freeze > requirements.txt 
```

Полученый файл сократим до примерно такого вида (оставляем ключевые библиотеки)
```
Flask==3.1.1
Jinja2==3.1.6
pydantic==2.11.5
requests==2.32.3
web3==7.12.0
```

Для того, чтобы в дальнейшем установить нужные зависимости (например на новом компьютере) необходимо выболнить следующие команды
```sh
python -m venv .venv
source .venv/bin/activate # или версию для windows
pip install requirements.txt
```

## <a id="client">Клиент для работы с экземпляром смарт-контракта</a>
В __app/src/blockchain/client.py__ создаём класс, для работы с экземпляром смарт-контракта. Например вот так
```py
from web3 import Web3
from web3.exceptions import ContractLogicError
from pathlib import Path

import json

BASE_DIR = "../blockchain/artifacts/contracts"

class ContractClient:
    def __init__(self, provider_url: str, contract_json_path: str):
        self.w3 = Web3(Web3.HTTPProvider(provider_url))

        with open(Path(contract_json_path)) as f:
            config = json.load(f)

        self.contract = self.w3.eth.contract(
            address=config["address"],
            abi=config["abi"]
        )

        self.public_key = None  

    def _set_account(self, public_key: str):
        self.public_key = self.w3.to_checksum_address(public_key)
        self.w3.eth.default_account = self.public_key

    def unset_account(self):
        self.public_key = None
        self.w3.eth.default_account = None

    def authorization_user(self, public_key: str):
        try:
            self._set_account(public_key)
            res = self.call("Auth")
            if res[0][0] == "":
                self.unset_account()
                return "Not authorized"
            return res
        except Exception as e:
            return e
        
    def to_transact(self, method_name: str, args: list = None, is_transact: bool = False, value_wei: int = 0):
        try:
            method = getattr(self.contract.functions, method_name)
            fn = method(*args) if args else method() 
            tx_params = {'from': self.public_key}
            
            if value_wei:
                tx_params['value'] = value_wei

            return fn.transact(tx_params) if is_transact else fn.call(tx_params)
        except ContractLogicError as e:
            return e
        except Exception as e:
            return e


contract_client = ContractClient(
    provider_url="http://127.0.0.1:8545",
    contract_json_path=f"{BASE_DIR}/contract.sol/Contract.json"
)
```

#### Отлично! Теперь приступаем к написанию веб приложения, описывать которое я подробно не стану, думаю вы и сами справитесь ;)

## <a id="итог">Итоги</a>
- Создали локальную сеть 
- Написали смарт-контракт
- Протестировали смарт-контракт
- Запустили локальную сеть
- Написали взаимодействие с блокчейном
- Создали веб приложение для пользователей платформы 