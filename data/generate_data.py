from itertools import product
from random import choice, randint, sample, seed
from typing import List, Callable

import lorem

seed(1)

NAMES = []

with open('input/names.txt', 'r', encoding="utf8") as names:
    NAMES = [
        lastname.rstrip()
        for lastname in names.readlines()
    ]

LAST_NAMES = []

with open('input/last_names.txt', 'r', encoding="utf8") as lastnames:
    LAST_NAMES = [
        lastname.rstrip().capitalize()
        for lastname in lastnames.readlines()
    ]

MAIL = ['gmail.com', 'wp.pl', 'pw.edu.pl',
        'o2.pl', 'example.com', 'youtube.com']

COUNTRIES = []

with open('input/countries.txt', 'r', encoding="utf8") as countries:
    COUNTRIES = [
        lastname.rstrip()
        for lastname in countries.readlines()
    ]

CITIES = []

with open('input/cities.txt', 'r', encoding="utf8") as cities:
    CITIES = [
        lastname.rstrip()
        for lastname in cities.readlines()
    ]

VOIVODESHIPS = []

with open('input/voivodeships.txt', 'r', encoding="utf8") as voivodeships:
    VOIVODESHIPS = [
        lastname.rstrip()
        for lastname in voivodeships.readlines()
    ]

STREETS = []

with open('input/streets.txt', 'r', encoding="utf8") as streets:
    STREETS = [
        lastname.rstrip()
        for lastname in streets.readlines()
    ]

COURSES = []

with open('input/courses.txt', 'r', encoding="utf8") as courses:
    COURSES = [
        lastname.rstrip()
        for lastname in courses.readlines()
    ]


class Candidate:
    i: int = 100

    def __init__(self) -> None:
        self.candidate_id = Candidate.i
        Candidate.i += 1

        first_name = choice(NAMES)
        last_name = choice(LAST_NAMES)

        self.email = f"'{first_name}.{last_name}.{randint(1, 2022)}@{choice(MAIL)}'"

        self.birth_date = f"'{randint(1920, 2010):04d}-{randint(1, 12):02d}-{randint(1, 28):02d}'"

        self.first_name = f"'{first_name}'"
        self.last_name = f"'{last_name}'"

        self.country = f"'{choice(COUNTRIES)}'"

        self.city = f"'{choice(CITIES)}'"

        self.postal_code = f"'{randint(1, 999)}-{randint(1, 999)}'"

        self.home_number = f"'{randint(1, 999)}{chr(ord('A') + randint(0, 23))}'"

        self.pesel = 'NULL' if choice((True, False)) \
            else f"'{randint(10000000000, 99999999999)}'"

        self.phone_number = 'NULL' if choice((True, False)) \
            else f"'+{randint(1, 100)}{randint(100000000, 999999999)}'"

        self.second_name = 'NULL' if choice((True, False)) \
            else f"'{choice(NAMES)}'"

        self.voivodeship = 'NULL' if choice((True, False)) \
            else f"'{choice(VOIVODESHIPS)}'"

        self.street = 'NULL' if choice((True, False)) \
            else f"'{choice(STREETS)}'"

        self.apartment_number = 'NULL' if choice((True, False)) \
            else f"'{randint(1, 999)}{chr(ord('A') + randint(0, 23))}'"

    def __str__(self) -> str:
        return f'INSERT INTO candidates VALUES ({self.candidate_id}, {self.email}, {self.birth_date},'\
            + f' {self.first_name}, {self.last_name}, {self.country}, {self.city}, {self.postal_code},'\
            + f' {self.home_number}, {self.pesel}, {self.phone_number}, {self.second_name}, {self.voivodeship},'\
            + f' {self.street}, {self.apartment_number});\n' + \
            ('COMMIT;\n' if self.candidate_id % 100 == 0 else '')

    @staticmethod
    def generate(count: int) -> List['Candidate']:
        return [Candidate() for i in range(count)]


class Registration:
    i: int = 10
    s: bool = False

    def __init__(self) -> None:
        year = Registration.i
        if Registration.s:
            Registration.i += 1
        season = Registration.s
        Registration.s = not Registration.s

        self.registration_code = f"'{year}{'S' if season else 'W'}'"

        self.start_date = f"'{2000 + year:04d}-{2 if season else 7:02d}-{1:02d}'"
        self.end_date = f"'{2000 + year:04d}-{2 if season else 7:02d}-{28:02d}'"

    def __str__(self) -> str:
        return f'INSERT INTO registrations VALUES ({self.registration_code}, {self.start_date}, {self.end_date});\n'

    @staticmethod
    def generate(count: int) -> List['Registration']:
        return [Registration() for i in range(count)]


class Course:
    i: int = 0

    def __init__(self) -> None:
        self.name = COURSES[Course.i]
        letter = choice(self.name[1:])
        while letter == ' ':
            letter = choice(self.name[1:])
        self.course_code = f"'{self.name[0]}{letter}{Course.i}'".upper(
        )
        Course.i += 1

        self.name = f"'{self.name}'"

        degrees = ['E', 'B', 'M', 'D']
        self.degree = f"'{choice(degrees)}'"

        self.description = 'NULL' if choice((True, False)) \
            else f"'{lorem.paragraph()}'"

    def __str__(self) -> str:
        return f'INSERT INTO courses VALUES ({self.course_code}, {self.name}, {self.degree}, {self.description});\n'

    @staticmethod
    def generate(count: int) -> List['Course']:
        return [Course() for i in range(count)]


class Offer:
    def __init__(self, registration_code: str, course_code: str) -> None:
        self.registration_code = registration_code
        self.course_code = course_code
        self.available_slots = randint(100, 999)

    def __str__(self) -> str:
        return f'INSERT INTO offers VALUES ({self.registration_code}, {self.course_code}, {self.available_slots});\n'


class Preference:
    def __init__(self, o: Offer, candidate_id: int, sequential_number: int) -> None:
        self.registration_code = o.registration_code
        self.course_code = o.course_code
        self.candidate_id = candidate_id
        self.sequential_number = sequential_number
        self.result = choice(['NULL', "'Y'", "'N'", "'R'"])
        self.points = randint(1, 100)

    def __str__(self) -> str:
        return f'INSERT INTO preferences VALUES ({self.registration_code}, {self.course_code}, {self.candidate_id}, {self.sequential_number}, {self.result}, {self.points});\n'


def write_lines(lines: List[str]) -> None:
    with open('./output/insert.sql', 'w') as handle:
        handle.writelines(lines)


CANDIDATES = Candidate.generate(randint(1_000, 2_000))
REGISTRATIONS = Registration.generate(26)
COURSES = Course.generate(len(COURSES))

OFR = {r.registration_code: [] for r in REGISTRATIONS}

OFFERS = []

for r, c in product(REGISTRATIONS, COURSES):
    if choice((True, False)):
        ofr = Offer(r.registration_code, c.course_code)
        OFFERS.append(ofr)
        OFR[r.registration_code].append(ofr)

PREFERENCES = []

for c in CANDIDATES:
    registration_codes = [
        r.registration_code
        for r in sample(REGISTRATIONS, k=randint(1, 3))
    ]
    for registration_code in registration_codes:
        for i, o in enumerate(sample(OFR[registration_code], k=randint(1, 3)), start=1):
            PREFERENCES.append(Preference(o, c.candidate_id, i))

FUNCTIONS: List[Callable[[], List[str]]] = [
    lambda: [str(val) for val in CANDIDATES],
    lambda: [str(r) for r in REGISTRATIONS],
    lambda: [str(c) for c in COURSES],
    lambda: [str(o) for o in OFFERS],
    lambda: [str(p) for p in PREFERENCES],
]


def main():
    lines: List[str] = []
    lines.append('ALTER TRIGGER PREF_REG_TRG DISABLE;\n')
    lines.append('ALTER TRIGGER PREF_RESULT_TRG DISABLE;\n')
    for func in FUNCTIONS:
        lines += func()
        lines.append("COMMIT;\n")
        lines.append('\n')
    lines.append('ALTER TRIGGER PREF_REG_TRG ENABLE;\n')
    lines.append('ALTER TRIGGER PREF_RESULT_TRG ENABLE;\n')

    write_lines(lines)


if __name__ == '__main__':
    main()
