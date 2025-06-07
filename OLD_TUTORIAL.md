# <a id="название">Туториал по созданию такого проекта</a>
## <a id="содержание">Содержание</a>
- [Необходимое ПО](#ПО)
- [Базовая структура проекта](#структура)
- [Hardhat](#hardhat)
- [Смарт-контракт](#смарт)
- [Тестирование смарт-контракта](#help)
- [Запуск сети и деплой контракта в hardhat](#start)
- [Взаимодействие с блокчейном](#user)
- [Веб приложение](#flask)
- [Итоги](#итог)



# <a id="ПО">Для работы нам подадобится следующее ПО:</a> 
- [Hardhat](https://hardhat.org/hardhat-runner/docs/getting-started)
- [Python](https://www.python.org/downloads/)
- [Web3](https://pypi.org/project/web3/)
- [Flask](https://pypi.org/project/Flask/)
- [OpenZeppelin standart token ERC1155 and ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts)
#### Убедившись, что у нас всё установлено - можем приступить к созданию проекта

## <a id="структура">Базовая структура проекта</a> 
```
project
├── backend
│  
├── frontend
│  
└── README.md
```
# <a id="hardhat">Hardhat</a>

Открываем папку *backend* в терминале и пишем следующие команды:
```
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
# <a id="смарт">Смарт-контракт</a>
### Переходим в папку backend/contracts
Копируем сюда стандарты токенов из репозитория openzeppelin в папку standart-token (чтобы не сохранять весь репозиторий, вы можете копировать папку contracts из openzeppelin, как это сделала я). Теперь удаляем сгенереный хардхедом контракт и пишем свой. Подробно описывать как это сделать я не буду, можете руководствоваться моим примером, или попробуйте написать самостоятельно.

# <a id="help">Тестирование смарт-контракта</a>
Теперь нам необходимо проверить работоспособность нашего контракта, для этого переходим в онлайн ide - [Remix](https://remix.ethereum.org/#optimize=true&runs=200&evmVersion=null&version=soljson-v0.8.23+commit.f704f362.js&lang=en), и тестируем все написанные функции.



# <a id="start">Запуск сети и деплой контракта в hardhat</a>
Чтобы поднять сеть, нам нужно открыть терминал в папке *backend* и написать:
```
npx hardhat clean (всегда перед запуском нужно очищать нашу сеть от прошлых версий)
npx hardhat node 
```
В терминале должны были появиться адреса и секретные ключи пользователей, если они есть, всё отлично, сеть запущена! Останавливать выполнение файла нельзя!!!, потому что иначе мы остановим сеть. <br><br>
Для выполнения следующих команд открываем новый терминал, и открываем в нём нашу папку с проектом
далее, пишем следующие команды: 
```
npx hardhat compile 
npx hardhat run --network localhost scripts/deploy.js
```
Если ошибок нет, отлично, мы задеплоили наш контракт! Если есть, то... Удачных вам голодных игр!


# <a id="user">Взаимодействие с блокчейном</a>
После того, как мы убедились что наша логика смарт-контракта полностью рабочаяя, можем приступить к написанию веб приложения для работы с пользователями. Для начала нам потребуется создать архитектуру следующим образом:
```
frontend
   ├── main.py
   ├── __pycache__
   │   ├── web.cpython-310.pyc
   │   └── web.cpython-311.pyc
   ├── static
   │   ├── images
   │   └── style.css
   ├── templates
   │   ├── action.html
   │   ├── auth.html
   │   ├── base.html
   │   ├── bet_to_action.html
   │   ├── index.html
   │   ├── lk.html
   │   ├── set_action.html
   │   ├── set_nft.html
   │   └── set_nft_in_collection.html
   └── web.py
```
### А теперь по порядку :)
Нам нужно написать взаимодействие с блокчейном, ведь как ещё мы можем получить из него информацию? Для этого в файле *web.py* пишем следующий код:
```py
from web3 import Web3
import json

config = json.load(open("./artifacts/contracts/contract.sol/Contract.json"))
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
contract = w3.eth.contract(address=config["address"], abi=config["abi"])

if w3.is_connected:
    print("--------------")
    print("Is connected")
    print("--------------")
    print(contract.all_functions())
else:
    print("Disconnected")


def require_user(signature, message):
    segn_mess = w3.eth.account.messages.encode_defunct(text=message)
    recover_address = w3.eth.Account.recover_message(segn_mess, signature=signature)
    return recover_address
    


def func(name, args=None, operation=None):
    try:
        if operation != "transact":
            if args:
                res = contract.functions[name](*args).call()
            else:
                res = contract.functions[name]().call()
        else:
            if args:
                res = contract.functions[name](*args).transact()
            else:
                res = contract.functions[name]().transact()
        return res
    except Exception as e:
        return str(e)
    

def key_check(public_key):
    try:
        print("to_checksum_address" + w3.to_checksum_address(public_key))
        w3.eth.default_account = w3.to_checksum_address(public_key)
        return func("Auth")
    except Exception as e:
        return str(e)
```
В былые времена, мы писали отдельные функции в web.py для каждой функции в смарт-сонтракте. Это занимало много времени. По этому, радуемся жизни с таким кодом :D

# <a id="flask">Веб приложение</a>
Отлично! Теперь приступаем к написанию веб приложения, описывать которое я подробно не стану, думаю вы и сами справитесь ;)

# <a id="итог">Итоги</a>
- Создали локальную сеть 
- Написали смарт-контракт
- Протестировали смарт-контракт
- Запустили локальную сеть
- Написали взаимодействие с блокчейном
- Создали веб приложение для пользователей платформы 