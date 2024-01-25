from flask import Flask, render_template, redirect, request, session, flash
import os
import web

app = Flask(__name__)
app.secret_key = os.urandom(69).hex()

def check_result(result):
    if isinstance(result, str):
        flash(result)
    else:
        flash("Успешно")

def check_session():
    if session.get('user'): return redirect('/')



@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST': 
        id = request.form.get("id", type=int)
        res = web.func("contract", "BuyNft", args=[id])
        check_result(res)
    return render_template('base.html', nfts=web.func("contract", "GetAllSellNft"))
    
    

@app.route('/login', methods=['GET', 'POST'])
def login():
    check_session()
    if not request.method == 'POST': return render_template('auth.html')
    wallet_address = request.json['walletAddress']
    res = web.key_check(wallet_address)
    print(res)
    if type(res) == str:
        flash(res)
    else:
        session['user'] = res
        print(session['user'])
        return redirect('/')
    

@app.route('/lk', methods=['GET', 'POST'])
def lk():
    check_session()
    if not request.method == 'POST': return render_template('lk.html', 
                                                            nfts=web.func("contract", "GetAllUser_Nfts"),
                                                            collections=web.func("contract", "GetAllUser_Collection"))
    result = web.func("contract", "SellNft", args=[
        request.form.get("id", type=int),
        request.form.get("price", type=int)],
        operation="transact")
    check_result(result)




if __name__ == "__main__":
    app.run(port=5020)