from flask import Flask, render_template, redirect, request, session, flash
from datetime import datetime
import os
import web

app = Flask(__name__)
app.secret_key = os.urandom(69).hex()

def check_result(result):
    print(str(result))
    if isinstance(result, str):
        # flash(result.split("'")[1])
        flash(result)
    else:
        flash("Успешно")

    


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST': 
        id = request.form.get("id", type=int)
        res = web.func("BuyNft", args=[id], operation="transact")
        check_result(res)
    return render_template('base.html', nfts=web.func("GetAllSellNft"))
    
    

@app.route('/auth', methods=['GET', 'POST'])
def login():
    if session.get('user') != None: return redirect('/lk')
    
    if request.method == 'POST': 
        account = request.json.get('account')
        res = web.key_check(account)
        if type(res) != str:
            session['user'] = res
            session['address'] = account
        else:
            flash(res)        
    return render_template('auth.html')
    
@app.route("/logout")
def logout():
    if session.get('user') != None:
        session.pop('user', None)
        return redirect('/')
    return redirect('/auth')
    

@app.route('/lk', methods=['GET', 'POST'])
def lk():
    if session.get('user') == None: return redirect('/')
    
    if request.method == 'POST': 
            if request.form.get('id') == "EnterReferralCode":
                code = web.func("EnterReferralCode", args=[
                    request.form.get('ref')], 
                    operation="transact")
                check_result(code)
                
            elif request.form.get('id') == "collection":   
                set_collection = web.func("SetCollection", args=[
                    request.form.get('name'),
                    request.form.get('description')],
                    operation="transact")
                check_result(set_collection)
            else:
                sell = web.func("SellNft", args=[
                    request.form.get("id", type=int),
                    request.form.get("price", type=int)],
                    operation="transact")
                check_result(sell)

    print(str(web.func("Auth")))
    print("balanse tokenbank: " + str(web.func("balanceOf", args=["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"])))
    print("balanse user: " + str(web.func("balanceOf", args=["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"])))
    return render_template('lk.html', 
                            user=web.func("Auth"),
                            nfts=web.func("GetAllUser_Nfts"),
                            collections=web.func("GetAllUser_Collection"))
    
@app.route("/set_nft", methods=["GET", "POST"])
def set_nft():
    if session.get('user') != None:
        if request.method == 'POST':
            if 'image' not in request.files:
                print("photo: " + request.files['image'].filename)
                flash("С картинкой что-то не так, повторите попытку")
            else:
                print("photo: " + request.files['image'].filename)
                res = web.func("SetNft",args=[
                    request.form.get("name"),
                    request.form.get("description"),
                    request.files['image'].filename,
                    request.form.get("amount")],
                    operation="transact")
                check_result(res)
        return render_template("set_nft.html")
    return redirect("/auth")
    
  
@app.route("/set_nft_in_collection/<int:id>", methods=["GET", "POST"]) 
def set_nft_in_collection(id):
    if request.method == "POST":
        if session.get('user') != None:    
            if 'image' not in request.files:
                flash("С картинкой что-то не так, повторите попытку")
            else:
                print("photo: " + request.files['image'].filename)
                res = web.func("SetNftForCollection",args=[
                    id,
                    request.form.get("name"),
                    request.form.get("description"),
                    request.files['image'].filename,
                    request.form.get("amount")],
                    operation="transact")
                check_result(res)
        
        return redirect("/auth")
    return render_template("set_nft_in_collection.html", actions=web.func("GetAllAction"), user=session.get('user'))


@app.route("/set_action/<int:id>", methods=["GET", "POST"]) 
def set_action(id):
    if request.method == "POST":
        if session.get('user') != None:    
            res = web.func("SetAction", args=[
                id,
                int(datetime.strptime(request.form.get('start'), '%Y-%m-%dT%H:%M').timestamp()),
                int(datetime.strptime(request.form.get('end'), '%Y-%m-%dT%H:%M').timestamp()),
                request.form.get("min"),
                request.form.get("max")],
                operation="transact")
            check_result(res)
            return redirect("/")
        return redirect("/auth")
    return render_template("set_action.html", actions=web.func("GetAllAction"), user=session.get('user'))



@app.route('/actions', methods=["GET", "POST"])
def action():
    if request.method == "POST":
        if session.get('user') != None:    
            if request.form.get('bet') != None:
                bet = web.func("SetBet", args=[
                    request.form.get("id"),
                    request.form.get("bet")],
                    operation="transact")
                check_result(bet)
            else:
                end = web.func("EndAction", args=[
                    request.form.get('id')],
                    operation="transact")
                check_result(end)
        return redirect("/auth")
    return render_template("action.html", actions=web.func("GetAllAction"), user=session.get('user'))



@app.route("/all_bet_to_action/<int:id>", methods=["GET", "POST"]) 
def all_bet_to_action(id):
    return render_template("bet_to_action.html", bets=web.func("GetBetToAction", args=[id]))

if __name__ == "__main__":
    app.run(port=5020)