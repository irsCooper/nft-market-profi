from flask import Flask, render_template, redirect, request, session, flash
from datetime import datetime
import os

from src.utils.utils import ALL_METHODS, render_all
from src.blockchain.client import contract_client
from src.user.router import user_app
from src.nfts.router import nft_app
from src.actions.router import action_app

app = Flask(__name__)
app.secret_key = os.urandom(69).hex()


app.register_blueprint(user_app)
app.register_blueprint(nft_app)
app.register_blueprint(action_app)

  
@app.route("/", methods=["GET"])
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(port=5020, debug=True)