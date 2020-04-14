from functools import wraps

from flask import session, flash, render_template

def check_logged_in(func: object):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if 'user' in session:
            return func(*args, **kwargs)
        else:
            flash('You are not logged in - please log in.')
            return render_template("login.html")
    return wrapper