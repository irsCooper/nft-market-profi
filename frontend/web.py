from web3 import Web3
import json

config = json.load(open("./artifacts/contracts/contract.sol/Contract.json"))
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
contract = w3.eth.contract(address=config["address"], abi=config["abi"])

if w3.is_connected:
    print("--------------")
    print("Is connected")
    print("--------------")
else:
    print("Disconnected")

def require_user(signature, message):
    segn_mess = w3.eth.account.messages.encode_defunct(text=message)
    recover_address = w3.eth.Account.recover_message(segn_mess, signature=signature)
    return recover_address
    


def func(name: str, args=None, operation=None):
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
    

def buy(amount):
    try:
        func_name = "BuyProfi"
        func_params = [amount]
        eth = amount

        transaction = contract.functions[func_name](*func_params).transact({
            'to':config["address"],
            # 'gasPrice': w3.to_wei('50', 'gwei'),
            'value': 0,
            'gas': 200000
        })
        return transaction
    except Exception as e:
        return str(e)