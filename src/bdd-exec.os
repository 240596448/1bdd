//----------------------------------------------------------
//This Source Code Form is subject to the terms of the
//Mozilla Public License, v.2.0. If a copy of the MPL
//was not distributed with this file, You can obtain one
//at http://mozilla.org/MPL/2.0/.
//----------------------------------------------------------

/////////////////////////////////////////////////////////////////
//
// Объект-помощник для выполнения приемочного/BDD тестирования
//
//////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать asserts
#Использовать strings

// #Использовать ".."

Перем Лог;
Перем ЧитательГеркин;

Перем ПредставленияСтатусовВыполнения;
Перем ВозможныеСтатусыВыполнения;
Перем ВозможныеТипыШагов;
Перем ВозможныеКлючиПараметров;
Перем ВозможныеЦветаСтатусовВыполнения;

Перем ТекущийУровень;

Перем Контекст;

Перем мФайлФичи;
Перем мНаборБиблиотечныхШагов;
Перем мИспользоватьБыстрыйОстановНаОшибке;
Перем мИмяЭлементаСценария;

////////////////////////////////////////////////////////////////////
//{ Программный интерфейс

//{ использование контекста внутри шагов сценариев

// Параметры специально передаются без "Знач" для универсальности
Процедура СохранитьВКонтекст(Ключ, Значение) Экспорт
	Контекст.Вставить(Ключ, Значение);
КонецПроцедуры

Функция ПолучитьИзКонтекста(Знач Ключ) Экспорт
	Возврат Контекст[Ключ];
КонецФункции // ПолучитьИзКонтекста(Знач Ключ) Экспорт
// }

//{ вызов шагов сценариев
Процедура ВыполнитьШаг(Знач НаименованиеШагаСценария) Экспорт
	ТекстФичи = СтрШаблон("# language: ru%1%2", Символы.ПС, НаименованиеШагаСценария);
	РезультатыРазбора = ЧитательГеркин.ПрочитатьТекстФичи(ТекстФичи);
	РезультатыВыполнения = ВыполнитьДеревоФич(мФайлФичи, мНаборБиблиотечныхШагов, РезультатыРазбора);

	СтатусВыполнения = ПолучитьИтоговыйСтатусВыполнения(РезультатыВыполнения);
	Если СтатусВыполнения <> ВозможныеСтатусыВыполнения().Пройден Тогда
		ВызватьИсключение СтрШаблон("Неверно выполнен шаг <%1>", НаименованиеШагаСценария);
	КонецЕсли;
КонецПроцедуры
// }

Функция ВыполнитьФичу(Знач ПарамФайлФичи, Знач ФайлБиблиотек = Неопределено, Знач ИскатьВПодкаталогах = Истина, 
	Знач ПарамИспользоватьБыстрыйОстановНаОшибке = Ложь, Знач ПарамИмяЭлементаСценария = "") Экспорт

	мФайлФичи = ПарамФайлФичи;
	мИспользоватьБыстрыйОстановНаОшибке = ПарамИспользоватьБыстрыйОстановНаОшибке;
	мИмяЭлементаСценария = ПарамИмяЭлементаСценария; 

	мНаборБиблиотечныхШагов = ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек);
	Лог.Отладка(СтрШаблон("Найдено библиотечных шагов: %1 шт.", ?(ЗначениеЗаполнено(мНаборБиблиотечныхШагов), мНаборБиблиотечныхШагов.Количество(), "0")));

	Если мФайлФичи.ЭтоКаталог() Тогда
		Лог.Отладка("Подготовка к выполнению сценариев в каталоге "+мФайлФичи.ПолноеИмя);
		МассивФайлов = НайтиФайлы(мФайлФичи.ПолноеИмя, "*.feature", ИскатьВПодкаталогах);

		НаборРезультатовВыполнения = Новый Массив;
		Для каждого НовыйФайлФичи Из МассивФайлов Цикл
			Если НовыйФайлФичи.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-фичи "+НовыйФайлФичи.ПолноеИмя;
			КонецЕсли;
			РезультатВыполнения = ВыполнитьФичуСУчетомБиблиотечныхШагов(НовыйФайлФичи);
			НаборРезультатовВыполнения.Добавить(РезультатВыполнения);
			Если мИспользоватьБыстрыйОстановНаОшибке И ПолучитьИтоговыйСтатусВыполнения(РезультатВыполнения) <> ВозможныеСтатусыВыполнения().Пройден Тогда
				Прервать;				
			КонецЕсли;
		КонецЦикла;
		РезультатыВыполнения = СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения);

	Иначе

		РезультатыВыполнения = ВыполнитьФичуСУчетомБиблиотечныхШагов(мФайлФичи);

	КонецЕсли;

	Возврат РезультатыВыполнения;
КонецФункции

Процедура ВывестиИтоговыеРезультатыВыполнения(РезультатыВыполнения, Знач ПоказыватьИтогиФич) Экспорт
	МассивИтогов = Новый Массив;
	МассивИтогов.Добавить(ВозможныеТипыШагов.Функциональность);
	МассивИтогов.Добавить(ВозможныеТипыШагов.Сценарий);
	МассивИтогов.Добавить(ВозможныеТипыШагов.Шаг);

	СтруктураИтогов = Новый Структура;
	Для каждого Элем Из МассивИтогов Цикл
		СтруктураИтогов.Вставить(Элем, СтатусыВыполненияДляПодсчета());
	КонецЦикла;

	РекурсивноПосчитатьИтогиВыполнения(РезультатыВыполнения, СтруктураИтогов);

	ИмяПоляИтога = "Итог";
	Для каждого Итоги Из СтруктураИтогов Цикл
		ДобавитьОбщееКоличествоКИтогам(Итоги.Ключ, Итоги.Значение, ИмяПоляИтога);
	КонецЦикла;

	ТекущийУровень = 0;
	Лог.Информация("");

	Для каждого Элем Из МассивИтогов Цикл
		Итог = СтруктураИтогов[Элем];
		ВыводимИтог = Истина;
		Если НЕ ПоказыватьИтогиФич И Элем = ВозможныеТипыШагов.Функциональность И Итог[ИмяПоляИтога] = 1 Тогда
			ВыводимИтог = Ложь;
		КонецЕсли;
		Если ВыводимИтог Тогда
			ВывестиПредставлениеИтога(Итог, Элем, ИмяПоляИтога);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

// Статусы выполнения тестов - ВАЖЕН порядок значение (0,1...), используется в ЗапомнитьСамоеХудшееСостояние
Функция ВозможныеСтатусыВыполнения() Экспорт
	Рез = Новый Структура;
	Рез.Вставить("НеВыполнялся", "0 Не выполнялся"); // использую подобное текстовое значение для удобных ассертов при проверке статусов выполнения
	Рез.Вставить("Пройден", "1 пройден");
	Рез.Вставить("НеРеализован", "2 не реализован");
	Рез.Вставить("Сломался", "3 Сломался");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция ВозможныеКодыВозвратовПроцесса() Экспорт
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 1);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 2);
	Возврат Рез;
КонецФункции // ВозможныеКодыВозвратовПроцесса()

Функция ИмяЛога() Экспорт
	Возврат "bdd";
КонецФункции

//}

////////////////////////////////////////////////////////////////////
//{ Реализация

Функция ВыполнитьФичуСУчетомБиблиотечныхШагов(Знач ФайлФичи)
	Лог.Отладка("Подготовка к выполнению сценария "+ФайлФичи.ПолноеИмя);

	Лог.Отладка("Читаю фичу");

	Лог.Отладка(СтрШаблон("Найдено библиотечных шагов: %1 шт.", ?(ЗначениеЗаполнено(мНаборБиблиотечныхШагов), мНаборБиблиотечныхШагов.Количество(), "0")));

	РезультатыРазбора = ЧитательГеркин.ПрочитатьФайлСценария(ФайлФичи);

	НовыйНаборБиблиотечныхШагов = ДополнитьНаборШаговИзИсполнителяШаговФичи(ФайлФичи, мНаборБиблиотечныхШагов);
	
	РезультатыВыполнения = ВыполнитьДеревоФич(ФайлФичи, НовыйНаборБиблиотечныхШагов, РезультатыРазбора);

	Возврат РезультатыВыполнения;
КонецФункции

// возвращает Неопределено, если не найдено, или соответствие, где ключ - имя шага, значение - Структура.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция ПолучитьНаборБиблиотечныхШагов(Знач ФайлБиблиотек) Экспорт //TODO перенести в секцию публичных методов или вообще в другой класс
	Если Не ЗначениеЗаполнено(ФайлБиблиотек) Тогда
		Возврат Неопределено
	КонецЕсли;
	КоллекцияШагов = Новый Структура;

	Лог.Отладка("Получение всех шагов из библиотеки "+ФайлБиблиотек.ПолноеИмя);
	МассивОписанийИсполнителяШагов = ПолучитЬМассивОписанийИсполнителяШагов(ФайлБиблиотек);
	Для каждого ОписаниеИсполнителяШагов Из МассивОписанийИсполнителяШагов Цикл
		Исполнитель = ОписаниеИсполнителяШагов.Исполнитель;
		МассивОписанийШагов = ПолучитьМассивОписанийШагов(Исполнитель);
		Для каждого ИмяШага Из МассивОписанийШагов Цикл
			АдресШага = ЧитательГеркин.НормализоватьАдресШага(ИмяШага);
			Если Не КоллекцияШагов.Свойство(АдресШага) Тогда
				КоллекцияШагов.Вставить(АдресШага, ОписаниеИсполнителяШагов);
				Лог.Отладка(СтрШаблон("Найдено имя шага <%1>, источник %2", ИмяШага, ОписаниеИсполнителяШагов.Файл.Имя));
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	Возврат КоллекцияШагов;
КонецФункции // ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек)

// возвращает Массив структур.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция ПолучитьМассивОписанийИсполнителяШагов(Знач ФайлБиблиотек)
	МассивОписанийИсполнителяШагов = Новый Массив;
	Если Не ФайлБиблиотек.ЭтоКаталог() Тогда
		ОписаниеИсполнителяШагов = НайтиИсполнителяШагов(ФайлБиблиотек);
		Если ЗначениеЗаполнено(ОписаниеИсполнителяШагов) Тогда
			МассивОписанийИсполнителяШагов.Добавить(ОписаниеИсполнителяШагов);
			Лог.Отладка("Нашли исполнителя шагов "+ФайлБиблиотек.ПолноеИмя);
		КонецЕсли;
	Иначе
		МассивФайлов = НайтиФайлы(ФайлБиблиотек.ПолноеИмя, "*.os", Истина);

		Для каждого ФайлИсполнителя Из МассивФайлов Цикл
			Если ФайлИсполнителя.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-шага "+ФайлИсполнителя.ПолноеИмя;
			КонецЕсли;

			ПоказыватьОшибкиИсполнителей = ФайлНаходитсяВСпециальномКаталогеРеализацииШагов(ФайлИсполнителя);
			ОписаниеИсполнителяШагов = ПолучитьИсполнителяШагов(ФайлИсполнителя, ПоказыватьОшибкиИсполнителей);
			Если ЗначениеЗаполнено(ОписаниеИсполнителяШагов) Тогда
				МассивОписанийИсполнителяШагов.Добавить(ОписаниеИсполнителяШагов);
				Лог.Отладка("Нашли исполнителя шагов "+ФайлИсполнителя.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Возврат МассивОписанийИсполнителяШагов;
КонецФункции // ПолучитЬМассивОписанийИсполнителяШагов(ФайлБиблиотек)

Функция ВыполнитьДеревоФич(Знач ФайлФичи, Знач НаборБиблиотечныхШагов, РезультатыРазбора)

	ДеревоФич = РезультатыРазбора.ДеревоФич;
	Ожидаем.Что(ДеревоФич, "Ожидали, что дерево фич будет передано как дерево значений, а это не так").ИмеетТип("ДеревоЗначений");

	РезультатыВыполнения = ДеревоФич.Скопировать();
	РекурсивноУстановитьСтатусДляВсехУзлов(РезультатыВыполнения.Строки[0], ВозможныеСтатусыВыполнения.НеВыполнялся);

	РезультатыВыполнения.Строки[0].СтатусВыполнения = РекурсивноВыполнитьШаги(ФайлФичи, НаборБиблиотечныхШагов, РезультатыВыполнения.Строки[0]);

	Возврат РезультатыВыполнения;
КонецФункции

Функция ДополнитьНаборШаговИзИсполнителяШаговФичи(Знач ФайлСценария, Знач НаборБиблиотечныхШагов)
	ОписаниеИсполнителяШагов = НайтиИсполнителяШагов(ФайлСценария);
	Если ОписаниеИсполнителяШагов <> Неопределено Тогда

		НаборШаговИсполнителя = ПолучитьНаборБиблиотечныхШагов(ФайлСценария);
		Если ЗначениеЗаполнено(НаборШаговИсполнителя) Тогда
			Лог.Отладка(СтрШаблон("найдено шагов исполнителя %1", НаборШаговИсполнителя.Количество()));
		КонецЕсли;
		Если ЗначениеЗаполнено(НаборБиблиотечныхШагов) Тогда
			Для каждого КлючЗначение Из НаборШаговИсполнителя Цикл
				НаборБиблиотечныхШагов.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
			КонецЦикла;
		Иначе
			НаборБиблиотечныхШагов = НаборШаговИсполнителя;
			Если Не ЗначениеЗаполнено(НаборБиблиотечныхШагов) Тогда
				ВызватьИсключение СтрШаблон("Не найдено шагов для фичи %1", ФайлСценария.ПолноеИмя);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат НаборБиблиотечныхШагов;
КонецФункции

Функция ПолучитьМассивОписанийШагов(Знач ИсполнительШагов)
	Рефлектор = Новый Рефлектор;
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(ЭтотОбъект);
	Попытка
		МассивОписанийШагов = Рефлектор.ВызватьМетод(ИсполнительШагов, ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов(), МассивПараметров);
		Возврат МассивОписанийШагов;
		
	Исключение
	КонецПопытки;

	Возврат Новый Массив;
	
КонецФункции // ПолучитьМассивОписанийШагов()

// возвращает Неопределено или структуру.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция НайтиИсполнителяШагов(Знач ФайлСценария)
	Лог.Отладка("Ищу исполнителя шагов в каталоге "+ФайлСценария.Путь);
	ПутьКИсполнителю = ОбъединитьПути(ФайлСценария.Путь, "step_definitions");
	ПутьКИсполнителю = ОбъединитьПути(ПутьКИсполнителю, ФайлСценария.ИмяБезРасширения+ ".os");

	ФайлИсполнителя = Новый Файл(ПутьКИсполнителю);
	ОписаниеИсполнителя = ПолучитьИсполнителяШагов(ФайлИсполнителя, Истина);
	Возврат ОписаниеИсполнителя;
КонецФункции

// возвращает Неопределено или структуру.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция ПолучитьИсполнителяШагов(Знач ФайлИсполнителя, Знач ПоказыватьОшибкиИсполнителей = Ложь)
	Лог.Отладка("Ищу исполнителя шагов в файле "+ФайлИсполнителя.ПолноеИмя);

	Если ФайлИсполнителя.Существует() Тогда
		Попытка
			ИсполнительШагов = ЗагрузитьСценарий(ФайлИсполнителя.ПолноеИмя);
			ОписаниеИсполнителя = Новый Структура("Исполнитель,Файл", ИсполнительШагов, ФайлИсполнителя);
		Исключение
			Инфо = ИнформацияОбОшибке();
			Если ПоказыватьОшибкиИсполнителей Тогда
				Лог.Предупреждение("Ошибка при загрузке файла %1 %2%3", ФайлИсполнителя.ПолноеИмя, Символы.ПС, ПодробноеПредставлениеОшибки(Инфо));							
			КонецЕсли;

			ОписаниеИсполнителя = Неопределено;
		КонецПопытки;
		
	Иначе
		ОписаниеИсполнителя = Неопределено;
	КонецЕсли;
	
	Возврат ОписаниеИсполнителя;
КонецФункции // ПолучитьИсполнителяШагов()

Функция ФайлНаходитсяВСпециальномКаталогеРеализацииШагов(Знач ФайлСкрипта)
	КаталогРодитель = Новый Файл(ФайлСкрипта.Путь);
	Возврат ВРег(КаталогРодитель.ИмяБезРасширения) = "step_definitions";
КонецФункции // ФайлНаходитсяВСпециальномКаталогеРеализацииШагов(ФайлСкрипта)

Функция РекурсивноВыполнитьШаги(Знач ФайлСценария, Знач НаборБиблиотечныхШагов, Знач Узел)
	ТекущийУровень = Узел.Уровень();
	ПредставлениеЛексемы = ?(Узел.ТипШага <> ВозможныеТипыШагов.Описание, Узел.Лексема +" ", "");

	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Если Узел.ТипШага = ВозможныеТипыШагов.Сценарий И Не ИмяСценарияПодходитПодФильтр(Узел.Тело, мИмяЭлементаСценария) Тогда
		Возврат СтатусВыполнения; 
	КонецЕсли;

	Если Узел.ТипШага <> ВозможныеТипыШагов.Шаг Тогда
		Лог.Информация(ПредставлениеЛексемы + Узел.Тело);
	КонецЕсли;

	Лог.Отладка(СтрШаблон("Выполняю узел <%1>, адрес <%2>, тело <%3>", Узел.ТипШага, Узел.АдресШага, Узел.Тело));

	ХукВыполненУспешно = ВыполнитьХукУзла(ЧитательГеркин.ВозможныеХуки().ПередЗапускомСценария, ФайлСценария, Узел);
	Если Не ХукВыполненУспешно Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
	Иначе
		
		СтатусВыполнения = ВыполнитьДействиеУзла(НаборБиблиотечныхШагов, Узел);

		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Сломался Тогда
			Для Каждого СтрокаДерева Из Узел.Строки Цикл
				НовыйСтатус = РекурсивноВыполнитьШаги(ФайлСценария, НаборБиблиотечныхШагов, СтрокаДерева);
				СтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(СтатусВыполнения, НовыйСтатус);
				Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден Тогда
					Если мИспользоватьБыстрыйОстановНаОшибке или СтрокаДерева.ТипШага = ВозможныеТипыШагов.Шаг Тогда
						Прервать;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	ХукВыполненУспешно = ВыполнитьХукУзла(ЧитательГеркин.ВозможныеХуки().ПослеЗапускаСценария, ФайлСценария, Узел);
	Если Не ХукВыполненУспешно Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
	КонецЕсли;

	Узел.СтатусВыполнения = СтатусВыполнения;

	Если Узел.ТипШага <> ВозможныеТипыШагов.Шаг И Узел.ТипШага <> ВозможныеТипыШагов.Описание Тогда
		Лог.Информация("");
	КонецЕсли;

	Возврат СтатусВыполнения;
КонецФункции

Функция ИмяСценарияПодходитПодФильтр(Знач Тело, Знач ИмяЭлементаСценария)
	Если ИмяЭлементаСценария = "" Тогда
		СценарийПодходит = Истина;
	Иначе
		СценарийПодходит = Найти(НРег(Тело), НРег(ИмяЭлементаСценария)) <> 0;
	КонецЕсли;
	Если СценарийПодходит Тогда
		Лог.Отладка("Сценарий <%1> будет выполнен, т.к он подходит под фильтр <%2>", Тело, ИмяЭлементаСценария);
	Иначе
		Лог.Отладка("Сценарий не будет выполнен <%1>, т.к. он не подходит под фильтр <%2>", Тело, ИмяЭлементаСценария);
	КонецЕсли;
	Возврат СценарийПодходит;
КонецФункции // ИмяСценарияПодходитПодФильтр(Знач Тело, Знач ИмяЭлементаСценария)

Функция ВыполнитьХукУзла(Знач ОписаниеХука, Знач ФайлСценария, Знач Узел, Знач ПредставлениеШага = "")
	Рез = Истина;
	Если Узел.ТипШага = ОписаниеХука.ТипШага Тогда
		АдресХука = ОписаниеХука.АдресШага;
		ОписаниеИсполнителяШагов = НайтиИсполнителяШагов(ФайлСценария);
		Если ОписаниеИсполнителяШагов <> Неопределено Тогда
			Рефлектор = Новый Рефлектор;

			СтрокаПараметров = "Узел";
			МассивПараметров = Новый Массив;
			МассивПараметров.Добавить(Узел); 

			ИмяФайлаШагов = ОписаниеИсполнителяШагов.Файл.Имя;
			Лог.Отладка(СтрШаблон("	Выполняю шаг <%1>, параметры <%2>, источник %3", 
			АдресХука, СтрокаПараметров, ИмяФайлаШагов));

			Попытка
				Рефлектор.ВызватьМетод(ОписаниеИсполнителяШагов.Исполнитель, АдресХука, МассивПараметров);
				
			Исключение

				Инфо = ИнформацияОбОшибке();
				текстОшибки = ПодробноеПредставлениеОшибки(Инфо);

				Если Инфо.Описание <> СтрШаблон("Метод объекта не обнаружен (%1)", АдресХука) Тогда
					Рез = Ложь;
					ПредставлениеШага = СтрШаблон("Не удалось выполнить хук <%1> для шага <%2>
					|%3
					|%4", АдресХука, ИмяФайлаШагов, ПредставлениеШага, текстОшибки);
					ВывестиСообщение(ПредставлениеШага, ВозможныеСтатусыВыполнения.Сломался);
				КонецЕсли;

			КонецПопытки;
		КонецЕсли;
	КонецЕсли;

	Возврат Рез;
КонецФункции // ВыполнитьХукУзла_ПередВыполнением(Узел)

Функция ВыполнитьДействиеУзла(Знач НаборБиблиотечныхШагов, Знач Узел)

	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Если Узел.ТипШага = ВозможныеТипыШагов.Шаг Тогда
		СтатусВыполнения = ВыполнитьШагСценария(Узел.АдресШага, Узел.Параметры, НаборБиблиотечныхШагов, Узел.Тело);

		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден Тогда
			Отступ = ПолучитьОтступ(ТекущийУровень);
			Лог.Информация(Отступ + ПредставленияСтатусовВыполнения[СтатусВыполнения]);
		КонецЕсли;
	ИначеЕсли Узел.ТипШага = ВозможныеТипыШагов.Описание Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
	КонецЕсли;
	Узел.СтатусВыполнения = СтатусВыполнения;

	Возврат СтатусВыполнения;
КонецФункции

Функция ВыполнитьШагСценария(Знач АдресШага, Знач ПараметрыШага, Знач НаборБиблиотечныхШагов, Знач ПредставлениеШага)
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	ОписаниеИсполнителяШагов = Неопределено;
	ШагРеализован = НаборБиблиотечныхШагов.Свойство(ЧитательГеркин.НормализоватьАдресШага(АдресШага), ОписаниеИсполнителяШагов);
	Если Не ШагРеализован ИЛИ ОписаниеИсполнителяШагов = Неопределено Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
	Иначе
		Рефлектор = Новый Рефлектор;

		СтрокаПараметров = "";
		МассивПараметров = Новый Массив;
		ПолучитьМассивПараметров(МассивПараметров, ПараметрыШага, СтрокаПараметров);

		СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров)-1);
		Лог.Отладка(СтрШаблон("	Выполняю шаг <%1>, параметры <%2>, источник %3", 
		АдресШага, СтрокаПараметров, ОписаниеИсполнителяШагов.Файл.Имя));

		Если Не Рефлектор.МетодСуществует(ОписаниеИсполнителяШагов.Исполнитель, АдресШага) Тогда //вдруг сняли Экспорт с метода или метода вообще нет
			СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
		Иначе
			Попытка
				Рефлектор.ВызватьМетод(ОписаниеИсполнителяШагов.Исполнитель, АдресШага, МассивПараметров);
				СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
				
			Исключение

				Инфо = ИнформацияОбОшибке();
				текстОшибки = ПодробноеПредставлениеОшибки(Инфо);

				Если Инфо.Параметры = ЧитательГеркин.ПараметрИсключенияДляЕщеНеРеализованногоШага() Тогда
					СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
				ИначеЕсли Инфо.Описание = "Слишком много фактических параметров" Тогда //в случае неверного разбора можем получить неверный адрес или неверные параметры
					СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
					ПредставлениеШага = ПредставлениеШага + Символы.ПС + текстОшибки + Символы.ПС +
					СтрШаблон("Дополнительно: Для шага <%1> передано или неверное количество параметров %2 или неверные параметры <%3>", АдресШага, МассивПараметров.Количество(), СтрокаПараметров);
				Иначе
					СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
					ПредставлениеШага = ПредставлениеШага + Символы.ПС + текстОшибки;
				КонецЕсли;

			КонецПопытки;
		КонецЕсли;
	КонецЕсли;

	ВывестиСообщение(ПредставлениеШага, СтатусВыполнения);

	Возврат СтатусВыполнения;
КонецФункции // ВыполнитьШагСценария()

Процедура ПолучитьМассивПараметров(МассивПараметров, Знач Параметры, РезСтрокаПараметров)
	Если ЗначениеЗаполнено(Параметры) Тогда
		Для Каждого КлючЗначение Из Параметры Цикл
			МассивПараметров.Добавить(КлючЗначение.Значение);
			РезСтрокаПараметров = РезСтрокаПараметров + КлючЗначение.Значение + ",";
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

Функция СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения)
	РезультатВыполнения = ЧитательГеркин.СоздатьДеревоФич();
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	Для каждого РезультатВыполненияФичи Из НаборРезультатовВыполнения Цикл
		Подстрока = РезультатВыполнения.Строки.Добавить();
		ЧитательГеркин.СкопироватьДерево(Подстрока, РезультатВыполненияФичи.Строки[0]);
	КонецЦикла;

	Возврат РезультатВыполнения;
КонецФункции // СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения)

Функция ПолучитьИтоговыйСтатусВыполнения(Знач РезультатыВыполнения) Экспорт
	ИтоговыйСтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Для каждого РезультатВыполненияФичи Из РезультатыВыполнения.Строки Цикл
		ИтоговыйСтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(РезультатВыполненияФичи.СтатусВыполнения, ИтоговыйСтатусВыполнения);
	КонецЦикла;

	Возврат ИтоговыйСтатусВыполнения;
КонецФункции

Процедура РекурсивноПосчитатьИтогиВыполнения(Узел, СтруктураИтогов)
	Если ТипЗнч(Узел) <> Тип("ДеревоЗначений") Тогда
		НужныйИтог = Неопределено;
		ЕстьИтог = СтруктураИтогов.Свойство(Узел.ТипШага, НужныйИтог);
		Если НЕ ЕстьИтог Тогда
			Возврат;
		КонецЕсли;

		НужныйИтог[Узел.СтатусВыполнения] = НужныйИтог[Узел.СтатусВыполнения] + 1;
	КонецЕсли;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		РекурсивноПосчитатьИтогиВыполнения(СтрокаДерева, СтруктураИтогов);
	КонецЦикла;
КонецПроцедуры

Процедура ДобавитьОбщееКоличествоКИтогам(ИмяИтогов, Итоги, ИмяПоляИтога)
	Счетчик = 0;
	Для каждого Итог Из Итоги Цикл
		Счетчик = Счетчик + Итог.Значение;
	КонецЦикла;
	Итоги.Вставить(ИмяПоляИтога, Счетчик);
КонецПроцедуры

Процедура ВывестиПредставлениеИтога(Итог, ПредставлениеШага, ИмяПоляИтога)
	Представление = СтрШаблон("%9 %10 ( %1 %2, %3 %4, %5 %6, %7 %8 )",
	Итог[ВозможныеСтатусыВыполнения.Пройден], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Пройден],
	Итог[ВозможныеСтатусыВыполнения.НеРеализован], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеРеализован],
	Итог[ВозможныеСтатусыВыполнения.Сломался], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Сломался],
	Итог[ВозможныеСтатусыВыполнения.НеВыполнялся], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеВыполнялся],
	Итог[ИмяПоляИтога], ПредставлениеШага
	);
	Лог.Информация(Представление);
КонецПроцедуры

Процедура РекурсивноУстановитьСтатусДляВсехУзлов(Узел, НовыйСтатус)
	Узел.СтатусВыполнения = НовыйСтатус;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		РекурсивноУстановитьСтатусДляВсехУзлов(СтрокаДерева, НовыйСтатус);
	КонецЦикла;
КонецПроцедуры

// Устанавливает новое текущее состояние выполнения тестов
// в соответствии с приоритетами состояний:
// 		Красное - заменяет все другие состояния
// 		Желтое - заменяет только зеленое состояние
// 		Зеленое - заменяет только серое состояние (тест не выполнялся ни разу).
Функция ЗапомнитьСамоеХудшееСостояние(ТекущееСостояние, НовоеСостояние)
	ТекущееСостояние = Макс(ТекущееСостояние, НовоеСостояние);
	Возврат ТекущееСостояние;

КонецФункции

// реализация интерфейса раскладки для логов
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	Отступ = ПолучитьОтступ(ТекущийУровень);
	НаименованиеУровня = "";

	Если Уровень = УровниЛога.Информация Тогда
		НаименованиеУровня = ?(Лог.Уровень() <> Уровень, УровниЛога.НаименованиеУровня(Уровень) +Символы.Таб+ "- ", "");
		Сообщение = СтроковыеФункции.ДополнитьСлеваМногострочнуюСтроку(Сообщение, Отступ);
		Возврат СтрШаблон("%1%2", НаименованиеУровня, Сообщение);
	КонецЕсли;

	НаименованиеУровня = УровниЛога.НаименованиеУровня(Уровень);

	Сообщение = СтроковыеФункции.ДополнитьСлеваМногострочнуюСтроку(Сообщение, СтрШаблон("- %1", Отступ));
	Возврат СтрШаблон("%1 %2 %3", НаименованиеУровня, Символы.Таб, Сообщение);

КонецФункции

// здесь нужно использовать различные виды форматирования
Процедура ВывестиСообщение(Знач Сообщение, Знач СтатусВыполнения)
	Консоль = Новый Консоль();
	ПредыдущийЦветТекстаКонсоли = Консоль.ЦветТекста;
	
	НовыйЦветТекста = ВозможныеЦветаСтатусовВыполнения[СтатусВыполнения];
	Если НовыйЦветТекста = Неопределено Тогда
		НовыйЦветТекста = ПредыдущийЦветТекстаКонсоли;
	КонецЕсли;
	Консоль.ЦветТекста = НовыйЦветТекста;

	Если СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден Тогда
		Лог.Информация(Сообщение);
	ИначеЕсли СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался Тогда
		Лог.Ошибка(Сообщение);
	ИначеЕсли СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован Тогда
		Лог.Предупреждение(Сообщение);
	КонецЕсли;
	Консоль.ЦветТекста = ПредыдущийЦветТекстаКонсоли;
КонецПроцедуры

Функция ПолучитьОтступ(Количество)
	Возврат СтроковыеФункции.СформироватьСтрокуСимволов(" ", Количество* 3);
КонецФункции

Функция ВозможныеЦветаСтатусовВыполнения()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, Неопределено);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, ЦветКонсоли.Зеленый);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, ЦветКонсоли.Бирюза);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, ЦветКонсоли.Красный);

	Возврат Новый ФиксированноеСоответствие(Рез);
КонецФункции

Функция ЗаполнитьПредставленияСтатусовВыполнения()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, "Не выполнялся");
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, "Пройден");
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, "Не реализован");
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, "Сломался");
	Возврат Рез;
КонецФункции

Функция СтатусыВыполненияДляПодсчета()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 0);
	Возврат Рез;
КонецФункции // СтатусыВыполнения()

Функция Инициализация()
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	Лог.УстановитьРаскладку(ЭтотОбъект);

	ВозможныеСтатусыВыполнения = ВозможныеСтатусыВыполнения();
	ПредставленияСтатусовВыполнения = ЗаполнитьПредставленияСтатусовВыполнения();
	ВозможныеЦветаСтатусовВыполнения = ВозможныеЦветаСтатусовВыполнения();
	ТекущийУровень = 0;

	ЧитательГеркин = Новый ЧитательГеркин;

	ВозможныеТипыШагов = ЧитательГеркин.ВозможныеТипыШагов();
	ВозможныеКлючиПараметров = ЧитательГеркин.ВозможныеКлючиПараметров();

	Контекст = Новый Соответствие();
КонецФункции

// }

///////////////////////////////////////////////////////////////////
// Точка входа

Инициализация();
