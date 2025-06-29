from flask import Blueprint, jsonify, redirect, request, session

from src.blockchain.client import contract_client
from src.utils.utils import ALL_METHODS, check_result, render_all

user_app = Blueprint("user", __name__)
app = user_app

def check_auth():
    if session.get('address') == None: return redirect('/auth')


@app.route("/login", methods=ALL_METHODS)
def login():
    if session.get('address') != None: return redirect('/lk')
    
    if request.method == 'POST': 
        public_key = request.json.get('public_key')
        
        res = contract_client.authorization_user(public_key)
        print(res)
        if type(res) != str and res != "Invalid key":
            session['address'] = public_key
            return jsonify({"redirect": "/lk"})
        else:
            return jsonify({"error": res}), 401      
    return render_all('auth')


@app.route("/logout")
def logout():
    if session.get('address') != None:
        session.pop('address', None)
        contract_client.unset_account()
        return redirect('/')
    return redirect('/auth')


@app.route('/lk', methods=['GET', 'POST'])
def lk():
    check_auth()
    
    if request.method == 'POST': 
        if request.form.get('id') == "EnterReferralCode":
            code = contract_client.transact(
                method_name="EnterReferralCode", 
                args=[
                    request.form.get('ref')
                ]
            )
            check_result(code)
            
        elif request.form.get('id') == "collection":   
            set_collection = contract_client.transact(
                method_name="SetCollection", 
                args=[
                    request.form.get('name'),
                    request.form.get('description')
                ]
            )
            check_result(set_collection)

        else:
            sell = contract_client.transact(
                method_name="SellNft", 
                args=[
                    request.form.get("id", type=int),
                    request.form.get("price", type=int)
                ]
            )
            check_result(sell)
    return render_all('lk')