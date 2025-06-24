from flask import Blueprint, redirect, request, session, flash

from src.blockchain.client import contract_client
from src.utils.utils import ALL_METHODS, check_result, render_all

nft_app = Blueprint("nft", __name__)
app = nft_app

@app.route("/set_nft", methods=ALL_METHODS)
def set_nft():
    if session.get('address') == None: 
        return redirect('/auth')
    
    if request.method == 'POST': 
        if not request.form.get('image'):
            flash("С картинкой что-то не так, повторите попытку")
        else:
            print("photo: " + request.form.get('image'))
            res = contract_client.to_transact(
                method_name="SetNft",
                args=[
                    request.form.get("name"),
                    request.form.get("description"),
                    request.form.get("image"),
                    request.form.get("amount", type=int)
                ],
                is_transact=True
            )
            check_result(res)
    return render_all("set_nft")


@app.route("/set_nft_in_collection/<int:id>", methods=ALL_METHODS) 
def set_nft_in_collection(id):
    if session.get('address') == None: 
        return redirect('/auth')
    
    if request.method == "POST": 
        if not request.form.get('image'):
            flash("С картинкой что-то не так, повторите попытку")
        else:
            res = contract_client.to_transact(
                method_name="SetNftForCollection",
                args=[
                    id,
                    request.form.get("name"),
                    request.form.get("description"),
                    request.form.get('image'),
                    request.form.get("amount", type=int)
                ],
                is_transact=True
            )
            check_result(res)
    return render_all("set_nft_in_collection")
    