from flask import flash, render_template
from blockchain.client import contract_client

GET = ["GET"]
POST = ["POST"]
ALL_METHODS = ["GET", "POST"]

def render_all(name:str, new_keys: dict = None):
    return render_template(
        f'{name}.html',
        nfts=contract_client.call("GetAllSellNft"),
        user=contract_client.call("Auth"),
        userNfts=contract_client.call("GetAllUser_Nfts"),
        collections=contract_client.call("GetAllUser_Collection"),
        actions=contract_client.call("GetAllAction"),
        # **new_keys
    )

def check_result(result):
    print(str(result))
    if isinstance(result, str):
        flash(result)
    else:
        flash("Успешно")