# Evil Twin: Анализ защищённости беспроводных сетей

**DISCLAIMER:** This project is for educational purposes only. All experiments were conducted in an isolated laboratory environment on my own equipment. The author is not responsible for any illegal use. 
*Данный проект создан исключительно в образовательных целях. Все эксперименты проводились в изолированной среде на собственном оборудовании.*

## Описание проекта
Демонстрация атаки Evil Twin (имитация доверенной точки доступа) с использованием микрокомпьютера Orange Pi и Wi-Fi адаптера AR9271. Проект показывает, как устройства автоматически подключаются к фейковым сетям и как Captive Portal может использоваться для сбора данных.

## Оборудование
*   Orange Pi PC
*   Wi-Fi адаптер AR9271
*   Тестовый смартфон

## Компоненты
*   **hostapd** — создание точки доступа
*   **dnsmasq** — DHCP и перенаправление DNS
*   **iptables** — перенаправление HTTP-трафика
*   **Flask (Python)** — веб-сервер для Captive Portal

## Как запустить
1. Установите зависимости:
   ```bash
   sudo apt update
   sudo apt install hostapd dnsmasq python3 python3-flask

2. Перейдите в папку с проектом и запустите скрипт:

```bash
sudo ./run.sh

## Структура проекта

* **portal.py** — код веб-сервера на Flask
* **run.sh** — скрипт автоматического запуска
* **templates/** — HTML-шаблоны (дисклеймер и форма входа)
* **evil.conf** — конфигурационный файл hostapd
* **dnsmasq.conf** — конфигурационный файл dnsmasq
