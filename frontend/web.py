from web3 import Web3
import json

configContract = json.load(open("./backend/artifacts/contract.sol/Contract.json"))
configUsers = json.load(open("./backend/artifacts/contract.sol/Contract.json"))

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

contract = w3.eth.contract(address=configContract["address"], abi=configContract["abi"])
users = w3.eth.contract(address=configUsers["address"], abi=configUsers["abi"])

if w3.is_connected:
    print("--------------")
    print("Is connected")
    print("--------------")
else:
    print("Disconnected")


def func(contract: str, name: str, args=None, operation=None):
    try:
        if operation != "transact":
            if contract == "contract":
                if args:
                    res = contract.functions[name](*args).call()
                else:
                    res = contract.functions[name]().call()
            else:
                if args:
                    res = users.functions[name](*args).call()
                else:
                    res = users.functions[name]().call()
        else:
            if contract == "contract":
                if args:
                    res = contract.functions[name](*args).transact()
                else:
                    res = contract.functions[name]().transact()
            else:
                if args:
                    res = users.functions[name](*args).transact()
                else:
                    res = users.functions[name]().transact()
        return res
    except Exception as e:
        return str(e)
    

def key_check(public_key):
    try:
        for Item in w3.eth.accounts:
            item = Item.lower()
            mess = item.split()
            if public_key in mess:
                w3.eth.default_account = w3.to_checksum_address(public_key)
                return func("users", "Auth")
            return "invalid key"
    except Exception as e:
        return str(e)
    

def buy(amount):
    try:
        func_name = "BuyProfi"
        func_params = [amount]
        eth = amount

        transaction = contract.functions[func_name](*func_params).transact({
            'to':configContract["address"],
            'gasPrice': w3.to_wei('50', 'gwei'),
            'value': eth,
            'gas': 200000
        })
        return transaction
    except Exception as e:
        return str(e)