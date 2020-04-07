import os
import psycopg2
from flask import Flask, session, render_template, request, flash, redirect, url_for, jsonify
from flask_session import Session
from flask_login import LoginManager, UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy import create_engine, text
from sqlalchemy.orm import scoped_session, sessionmaker
from dotenv import load_dotenv
import requests


app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY")

# Check for environment variable
if not os.getenv("DATABASE_URL"):
    raise RuntimeError("DATABASE_URL is not set")

# Configure session to use filesystem

app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# sqlalchemy engine object that manages connections to the database
engine = create_engine(os.getenv("DATABASE_URL"))

# ensures users actions are kept separate
db = scoped_session(sessionmaker(bind=engine))

login_manager = LoginManager()
login_manager.init_app(app)


@login_manager.user_loader
def load_user(user_id):
    return User.get(user_id)
    

@app.route("/")
def index():
    return(render_template("login.html"))

@app.route("/login", methods=['POST','GET'])
def login():
    # Login will need to check that the user exists, and present an error if they don't.
    # If they do exist, then it will need to verify that they put in the right password.
    # Then it will need to create the session assign to that user.
    session.pop("user", None)

    if request.method == "POST":
        userName = request.form.get("username")
        password = request.form.get("pass")
        checkUsername = db.execute("SELECT user_name FROM registered_users WHERE user_name=(:userName)",
                        {"userName":userName}).fetchone()

        if checkUsername == None:           
            flash("Incorrect username or password.")
            return render_template("login.html")
        else:
            queriedPasswordResult = db.execute("SELECT password FROM registered_users WHERE user_name=(:userName)",
                        {"userName":userName}).fetchone()
            # Removes tuple garbage.
            cleanedPassword = str(queriedPasswordResult)[2:-3]

            if cleanedPassword != password:
                flash("Incorrect username or password.")
                return render_template("login.html")
            else:
                session["user"] = userName
                
                return redirect(url_for("search"))
                
    elif request.method == "GET":
        return(render_template("login.html"))
            
@app.route("/search", methods=["GET","POST"])
def search():
    if request.method == "GET" :
        if 'user' in session:
            return(render_template("search.html"))
        return 'You are not logged in.'

    elif request.method == "POST":

        searchKeyword = request.form.get("searchKeyword")
        searchKeyword = searchKeyword.lower() + '%'

        queryResults = db.execute(f"SELECT num, description, totalavailableforsale, qtyonorderpo FROM products WHERE num LIKE :searchKeyword OR LOWER(description) LIKE :searchKeyword"
        , {"searchKeyword":searchKeyword}).fetchall()

        timeRefreshed = db.execute(f"SELECT to_char(products_update at time zone 'utc' at time zone 'America/Detroit', 'Month DD, YYYY at HH12:MI a.m.') FROM time").fetchone()

        # Clears connection
        db.remove()


        return render_template("results.html", results=queryResults, timeRefreshed=timeRefreshed)
    else:
        return(render_template("login.html"))
        
        



