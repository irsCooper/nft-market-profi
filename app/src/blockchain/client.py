from web3 import Web3
from web3.exceptions import ContractLogicError
from pathlib import Path
import json


PROVIDER_URL = "http://127.0.0.1:8545"
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
        
    def call(self, method_name: str, args: list = None):
        try:
            method = getattr(self.contract.functions, method_name)
            tx_params = {'from': self.public_key}
            if args:
                return method(*args).call(tx_params)  
            
            return method().call(tx_params)
        except ContractLogicError as e:
            return e
        except Exception as e:
            return e

    def transact(self, method_name: str, args: list = None):
        try:
            method = getattr(self.contract.functions, method_name)
            tx_params = {'from': self.public_key}

            if args:
                return method(*args).transact(tx_params)  
                
            return method().transact(tx_params)
        except ContractLogicError as e:
            return e
        except Exception as e:
            return e
        
    def payable_transact(self, method_name: str, args: list = None, value_wei: int = 0):
        try:
            method = getattr(self.contract.functions, method_name)
            tx_params = {
                'from': self.public_key,
                'value': value_wei
            }
            
            if args:
                return method(*args).transact(tx_params) 
            
            return method().transact(tx_params)
        except ContractLogicError as e:
            return e
        except Exception as e:
            return e


contract_client = ContractClient(
    provider_url=PROVIDER_URL,
    contract_json_path=f"{BASE_DIR}/contract.sol/Contract.json"
)

