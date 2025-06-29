from datetime import datetime
from flask import Blueprint, render_template, redirect, request, session

from src.blockchain.client import contract_client
from src.utils.utils import ALL_METHODS, check_result, render_all

action_app = Blueprint("action", __name__)
app = action_app


@app.route("/set_action/<int:id>", methods=ALL_METHODS) 
def set_action(id):
    if session.get('address') == None: 
        return redirect('/auth')
    
    if request.method == "POST":         
        res = contract_client.transact(
            method_name="SetAction", 
            args=[
                int(id),
                int(datetime.strptime(request.form.get('start'), '%Y-%m-%dT%H:%M').timestamp()),
                int(datetime.strptime(request.form.get('end'), '%Y-%m-%dT%H:%M').timestamp()),
                request.form.get("min", type=int),
                request.form.get("max", type=int)
            ]
        )
        check_result(res)
        return redirect("/actions")
    return render_all("set_action")
    


@app.route('/actions', methods=ALL_METHODS)
def action():
    if session.get('address') == None: return redirect('/auth')
    if request.method == "POST": 
        if request.form.get('bet') != None:
            bet = contract_client.transact(
                method_name="SetBet", 
                args=[
                    request.form.get("id", type=int),
                    request.form.get("bet", type=int)
                ]
            )
            check_result(bet)
        else:
            end = contract_client.transact(
                method_name="EndAction", 
                args=[
                    request.form.get('id', type=int)
                ]
            )
            check_result(end)
    return render_all("action")
    


@app.route("/all_bet_to_action/<int:id>", methods=ALL_METHODS) 
def all_bet_to_action(id):
    return render_template("bet_to_action.html", bets=contract_client.call("GetBetToAction", args=[int(id)]))
