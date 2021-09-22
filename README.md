<a id="markdown-1bdd-для-onescript" name="1bdd-для-onescript"></a>
# 1BDD для OneScript


[![GitHub release](https://img.shields.io/github/release/artbear/1bdd.svg)](https://github.com/artbear/1bdd/releases) 
[![Тестирование](https://github.com/artbear/1bdd/actions/workflows/testing.yml/badge.svg?branch=develop)](https://github.com/artbear/1bdd/actions/workflows/testing.yml)
[![Статус Порога Качества](https://sonar.openbsl.ru/api/project_badges/measure?project=1bdd&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=1bdd) 
[![Покрытие](https://sonar.openbsl.ru/api/project_badges/measure?project=1bdd&metric=coverage)](https://sonar.openbsl.ru/dashboard?id=1bdd)
[![Технический долг](https://sonar.openbsl.ru/api/project_badges/measure?project=1bdd&metric=sqale_index)](https://sonar.openbsl.ru/dashboard?id=1bdd)
[![Строки кода](https://sonar.openbsl.ru/api/project_badges/measure?project=1bdd&metric=ncloc)](https://sonar.openbsl.ru/dashboard?id=1bdd) 

<!-- [![Build status](https://ci.appveyor.com/api/projects/status/vbnk445352crljjn?svg=true)](https://ci.appveyor.com/project/artbear/1bdd)
[![Build Status](https://travis-ci.org/artbear/1bdd.svg?branch=develop)](https://travis-ci.org/artbear/1bdd)
[![Quality Gate](https://sonar.silverbulleters.org/api/badges/gate?key=opensource-1bdd)](https://sonar.silverbulleters.org/dashboard?id=opensource-1bdd)
[![Tech Debt](https://sonar.silverbulleters.org/api/badges/measure?key=opensource-1bdd&metric=sqale_debt_ratio)](https://sonar.silverbulleters.org/dashboard?id=opensource-1bdd) -->

<!-- TOC -->

- [1BDD для OneScript](#1bdd-для-onescript)
	- [Командная строка запуска](#командная-строка-запуска)
	- [Формат файла фичи](#формат-файла-фичи)
		- [Пример файла фичи](#пример-файла-фичи)
	- [Формат файла шагов](#формат-файла-шагов)
		- [Пример файла шагов](#пример-файла-шагов)
	- [API фреймворка](#api-фреймворка)
	- [Стандартная библиотека](#стандартная-библиотека)
	- [Расширения для Visual Studio Code](#расширения-для-visual-studio-code)

<!-- /TOC -->

[Vanessa open-source![Chat on Telegram vanessa_opensource_chat](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen.svg)](https://t.me/vanessa_opensource_chat) или [oscript_library ![Chat on Telegram oscript_library](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen.svg)](https://t.me/oscript_library) - в этих чатах вы можете задавать любые вопросы разработчикам и активным участникам.

`1bdd` - инструмент для выполнения автоматизированных требований/тестов, написанных на обычном, не программном языке.

Иными словами, это консольный фреймворк, реализующий `BDD` для проекта [OneScript](https://github.com/EvilBeaver/OneScript).
Для Windows и Linux.

Идеи черпаются из проекта [Cucumber](https://cucumber.io).

Основная документация находится [в каталоге документации](./docs/readme.md)

- в т.ч. библиотека полезных стандартных шагов
- API продукта

Ниже краткая информация о возможностях продукта.

<a id="markdown-командная-строка-запуска" name="командная-строка-запуска"></a>
## Командная строка запуска

```cmd
oscript bdd.os <features-path> [ключи]
oscript bdd.os <команда> <параметры команды> [ключи]

Возможные команды:
	<features-path> [ключи]
	или
	exec <features-path> [ключи]
		Выполняет сценарии BDD для Gherkin-спецификаций
		Параметры:
			features-path - путь к файлам *.feature.
			Можно указывать как каталоги, так и конкретные файлы.

			-fail-fast - Немедленное завершение выполнения на первом же не пройденном сценарии

			-name <ЧастьИмениСценария> - Выполнение сценариев, в имени которого есть указанная часть
			-junit-out <путь-файла-отчета> - выводить отчет тестирования в формате JUnit.xml

	gen <features-path> [ключи]
		Создает заготовки шагов для указанных Gherkin-спецификаций
		Параметры:
			features-path - путь к файлам *.feature.
				Можно указывать как каталог, так и конкретный файл.

Возможные общие ключи:
	-require <путь каталога или путь файла> - путь к каталогу фича-файлов или к фича-файлу, содержащим библиотечные шаги.
		Если эта опция не задана, загружаются все os-файлы шагов из каталога исходной фичи и его подкаталогов.
		Если опция задана, загружаются только os-файлы шагов из каталога фича-файлов или к фича-файла, содержащих библиотечные шаги.

	-out <путь лог-файла>
	-debug <on|off> - включает режим отладки (полный лог + остаются временные файлы)
	-verbose <on|off> - включается полный лог
```

Для подсказки по конкретной команде наберите
`bdd help <команда>`.

<a id="markdown-формат-файла-фичи" name="формат-файла-фичи"></a>
## Формат файла фичи

Файл фичи должен иметь расширение `feature` и написан согласно синтаксису языка `Gherkin`

<a id="markdown-пример-файла-фичи" name="пример-файла-фичи"></a>
### Пример файла фичи

```gherkin
# language: ru

Функционал: Выполнение файловых операций
    Как Пользователь
    Я хочу иметь возможность выполнять различные файловые операции в тексте фич
    Чтобы я мог проще протестировать и автоматизировать больше действий на OneScript

Сценарий: Каталог проекта
    Допустим Я создаю временный каталог и сохраняю его в контекст
    И Я устанавливаю временный каталог как рабочий каталог
    Когда Я сохраняю каталог проекта в контекст
    Тогда Я показываю каталог проекта
    И Я показываю рабочий каталог
```

или

```gherkin
# language: ru

Функционал: Использование программного контекста
	Как Разработчик
	Я Хочу чтобы шаги разных сценариев могли обмениваться данными через програмнный контекст продукта

Сценарий: Первый сценарий

  Когда Я сохранил ключ "Ключ1" и значение 10 в программном контексте
  И я получаю ключ "Ключ1" и значение 10 из программного контекста

Сценарий: Следующий сценарий

  Тогда я получаю ключ "Ключ1" и значение 10 из программного контекста
```

<a id="markdown-формат-файла-шагов" name="формат-файла-шагов"></a>
## Формат файла шагов

Это обычный os-скрипт, который располагает в подкаталоге `step_definitions` относительно файла фичи.

В этом файле должна быть служебная функция `ПолучитьСписокШагов`, которая возвращает массив всех шагов, заданных в этом скрипте.

Также внутри файла шагов могут располагаться специальные методы-обработчики (хуки) событий `ПередЗапускомСценария`/`ПослеЗапускаСценария`

<a id="markdown-пример-файла-шагов" name="пример-файла-шагов"></a>
### Пример файла шагов

```bsl
// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯСохранилКлючИЗначениеВПрограммномКонтексте");
	ВсеШаги.Добавить("ЯПолучаюКлючИЗначениеИзПрограммногоКонтекста");

	Возврат ВсеШаги;
КонецФункции

// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт

КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт

КонецПроцедуры

//Я сохранил ключ "Ключ1" и значение 10 в программном контексте
Процедура ЯСохранилКлючИЗначениеВПрограммномКонтексте(Знач Ключ, Знач Значение) Экспорт
	БДД.СохранитьВКонтекст(Ключ, Значение);
КонецПроцедуры

//я получаю ключ "Ключ1" и значение 10 из программного контекста
Процедура ЯПолучаюКлючИЗначениеИзПрограммногоКонтекста(Знач Ключ, Знач ОжидаемоеЗначение) Экспорт
	НовоеЗначение = БДД.ПолучитьИзКонтекста(Ключ);
	Ожидаем.Что(НовоеЗначение).Равно(ОжидаемоеЗначение);
КонецПроцедуры
```

<a id="markdown-api-фреймворка" name="api-фреймворка"></a>
## API фреймворка

Есть несколько вариантов использования API фреймворка из кода реализации шагов.

Основная документация по шагам находится [в каталоге документации](./docs/readme.md#api-фреймворка)

<a id="markdown-стандартная-библиотека" name="стандартная-библиотека"></a>
## Стандартная библиотека

Стандартные библиотечные шаги, подключаемые автоматически для любой фичи, находятся в каталоге `features/lib`

- `ВыполнениеКоманд.feature` - выполнение команд системы и запуск процессов
- `ФайловыеОперации.feature` - создание файлов/каталогов, их копирование, анализ содержимого файлов

Основная документация по шагам находится [в каталоге документации](./docs/readme.md#стандартная-библиотека-шагов)

<a id="markdown-расширения" name="расширения"></a>
## Расширения для Visual Studio Code

Для Visual Studio Code созданы расширения, облегчающие работу с файлами фич:

- [Snippets and Syntax Highlight for Gherkin (Cucumber)](https://marketplace.visualstudio.com/itemdetails?itemName=stevejpurves.cucumber) - подсветка синтаксиса и автодополнение ключевых слов Gherkin.
- [Gherkin step autocomplete](https://marketplace.visualstudio.com/itemdetails?itemName=silverbulleters.gherkin-autocomplete) - автодополнение шагов в файлах фич.
	У этого расширения есть настройка `gherkin-autocomplete.featureLibraries`, которая позволяет подключить внешние по отношению к проекту библиотеки шагов (например, установленную вместе с 1bdd).
	По `Shift+F12`/`Shift+Alt+F12` можно перейти к реализации текущего шага - если она есть в текущем проекте и/или внешних библиотеках.
