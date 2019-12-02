#!/usr/bin/env python
# coding: utf-8

"""
https://yandex.ru/dev/connect/directory/api/concepts/examples/examples-docpage/
"""

import os
import csv
import sys
import string
import random
import requests


TOKEN = os.environ.get('TOKEN')
USER_AGENT = 'Directory Sync Example'


def load_users(filename):
    """Читает CSV файл с данными про сотрудников
    и возвращает iterable объект с помощью
    которого можно итерироваться по словарям
    с данными про сотрудников.
    """
    with open(filename, 'r', encoding='utf-8') as csvfile:
        rows = csv.DictReader(csvfile)
        yield from rows


def create_user(data, departments):
    """Создаёт в Директории пользователя.

    Принимает на вход словарь:

    {
        'nickname': 'Логин сотрудника',
        'first': 'Имя',
        'last': 'Фамилия',
        'department': 'Отдела или пустая строка',
    }

    Вторым аргументом идёт словарь {'Название отдела': department_id}.
    Он нужен, чтобы определить id отдела, в котором должен быть заведён
    сотрудник.
    """
    data = {
        key: value.strip()
        for key, value in data.items()
    }

    department_name = data['department']
    if department_name:
        if department_name not in departments:
            raise RuntimeError('Отдел "{0}" не найден'.format(department_name))

        department_id = departments[department_name]
    else:
        # Если отдел не указан, то сотрудник
        # заводится на самом верхнем уровне.
        department_id = 1


    payload = {
        'nickname': data['nickname'],
        'name': {'first': data['first'], 'last': data['last']},
        'department_id': department_id,
        'password': data['password'],
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    response = requests.post(
        'https://api.directory.yandex.net/v6/users/',
        json=payload,
        headers=headers,
        timeout=10,
    )
    # В случае ошибки, бросим исключение.
    response.raise_for_status()
    # А если всё хорошо, то вернём id.
    response_data = response.json()
    return response_data['id']


def get_departments():
    """Забирает из Директории данные об уже существующих отделах
    и возвращает словарь {'Название отдела': department_id}
    """
    params = {
        'fields': 'name',
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    # В целях простоты примера мы игнорируем тот факт, что
    # отделов может быть больше 20 и они не поместятся в
    # один запрос. В реальном коде тут надо будет анализировать
    # ключ links и делать дополнительные запросы.
    response = requests.get(
        'https://api.directory.yandex.net/v6/departments/',
        params=params,
        headers=headers,
        timeout=10,
    )
    response.raise_for_status()
    response_data = response.json()
    results = response_data['result']
    results = {
        department['name']: department['id']
        for department in results
    }
    return results


def create_random_password(length=10):
    symbols = string.ascii_letters + string.digits
    return ''.join(
        random.choice(symbols)
        for i in range(length)
    )


def load_already_created():
    """Забирает из Директории данные об уже существующих сотрудниках.
    и возвращает set из из логинов.
    """
    params = {
        'fields': 'nickname',
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    # В целях простоты примера мы игнорируем тот факт, что
    # сотрудников может быть больше 20 и они не поместятся в
    # один запрос. В реальном коде тут надо будет анализировать
    # ключ links и делать дополнительные запросы.
    response = requests.get(
        'https://api.directory.yandex.net/v6/users/',
        params=params,
        headers=headers,
        timeout=10,
    )
    response.raise_for_status()
    response_data = response.json()
    results = response_data['result']
    return {user['nickname'] for user in results}



def create_users(filename, output):
    """Читает данные из файла и создаёт пользователей.
    """

    # Убедимся, что выходной файл не существует,
    # потому что если он есть, то мы можем случайно
    # затереть пароли тех сотрудников, что были заведены
    # при предыдущем запуске скрипта.
    if os.path.exists(output):
        raise RuntimeError('Файл {0} существует. Выберите другое имя файла.')

    users_data = load_users(filename)
    departments = get_departments()
    already_created = load_already_created()

    # Сюда мы сохраним логины и пароли заведённых сотрудников
    # чтобы позже записать в выходной файл
    new_users = []

    for item in users_data:
        try:
            nickname = item['nickname'].strip()
            # Сотрудника будем создавать только если ещё нет
            # сотрудника с таким логином
            if nickname not in already_created:
                item['password'] = create_random_password()
                create_user(item, departments)
                new_users.append((nickname, item['password']))
        except Exception:
            # Пропустим эту ошибку, чтобы по возможности
            # завести все учётные записи какие получится.
            print('Не получилось завести сотрудника: {0}'.format(item))

    # Теперь сдампим пароли пользователей в новую CSV
    if new_users:
        with open(output, 'w') as output_file:
            output_file.write('nickname,password\n')
            output_file.writelines(
                '{0},{1}\n'.format(nickname, password)
                for nickname, password
                in new_users
            )






if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: {0} users.csv passwords.csv'.format(sys.argv[0]))
        sys.exit(1)
    else:
        create_users(sys.argv[1], sys.argv[2])
