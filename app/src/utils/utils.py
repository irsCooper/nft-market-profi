from flask import flash, render_template
from web3.exceptions import ContractLogicError

from src.blockchain.client import contract_client

GET = ["GET"]
POST = ["POST"]
ALL_METHODS = ["GET", "POST"]

def render_all(name:str):
    return render_template(
        f'{name}.html',
        nfts=contract_client.to_transact("GetAllSellNft"),
        user=contract_client.to_transact("Auth"),
        userNfts=contract_client.to_transact("GetAllUser_Nfts"),
        collections=contract_client.to_transact("GetAllUser_Collection"),
        actions=contract_client.to_transact("GetAllAction"),
    )

def check_result(result):
    if isinstance(result, ContractLogicError):
        res = result.message.split('string')
        if len(res) > 0:
            flash(res[1])
        flash(result)
    else:
        flash("Успешно")