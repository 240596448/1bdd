# language: ru

Функционал: Использование контекста
	Как Разработчик
	Я Хочу чтобы у нескольких сценариев был одинаковое начальное окружение

Контекст:
  Допустим Я сохранил значение "ЗначениеВКонтексте" в исполнителе

Сценарий: Первый сценарий

  Тогда я получаю значение "ЗначениеВКонтексте" от исполнителя
  И Я сохранил значение "Значение" в исполнителе
  И я получаю значение "Значение" от исполнителя

Сценарий: Второй сценарий

  Тогда я получаю значение "ЗначениеВКонтексте" от исполнителя

Структура сценария: Проверяю передачу параметров

	Тогда я получаю значение <ЗначениеВКонтексте> от исполнителя
	И Я сохранил значение <Значение> в исполнителе
	И я получаю значение "Еще одно значение" от исполнителя

Примеры:
	  | ЗначениеВКонтексте       | Значение |
	  | ЗначениеВКонтексте | Еще одно значение |

Контекст:
  Допустим Я сохранил значение "НовоеЗначениеВКонтексте" в исполнителе

Структура сценария: Проверяю передачу параметров для второго контекста
	
	Тогда я получаю значение <ЗначениеВКонтексте> от исполнителя
	И Я сохранил значение <Значение> в исполнителе
	И я получаю значение "Другое значение" от исполнителя
	
Примеры:
	| ЗначениеВКонтексте       | Значение |
	| НовоеЗначениеВКонтексте | Другое значение |

Сценарий: Первый сценарий второго контекста

  Тогда я получаю значение "НовоеЗначениеВКонтексте" от исполнителя
  И Я сохранил значение "НовоеЗначение" в исполнителе
  И я получаю значение "НовоеЗначение" от исполнителя

Сценарий: Второй сценарий второго контекста

  Тогда я получаю значение "НовоеЗначениеВКонтексте" от исполнителя
  
