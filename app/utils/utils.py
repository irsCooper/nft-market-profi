from flask import flash, render_template
from web3.exceptions import ContractLogicError

from blockchain.client import contract_client

GET = ["GET"]
POST = ["POST"]
ALL_METHODS = ["GET", "POST"]

def render_all(name:str):
    return render_template(
        f'{name}.html',
        nfts=contract_client.call("GetAllSellNft"),
        user=contract_client.call("Auth"),
        userNfts=contract_client.call("GetAllUser_Nfts"),
        collections=contract_client.call("GetAllUser_Collection"),
        actions=contract_client.call("GetAllAction"),
    )

def check_result(result):
    if isinstance(result, ContractLogicError):
        res = result.message.split('string')
        if len(res) > 0:
            flash(res[1])
        flash(result)
    else:
        flash("Успешно")