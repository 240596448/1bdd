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
Перем ВозможныеКодыВозвратовПроцесса;

Перем ТекущийУровень;

Перем Контекст;

Перем ФайлФичи;
Перем НаборБиблиотечныхШагов;
Перем ИспользоватьБыстрыйОстановНаОшибке;
Перем ИмяЭлементаСценария;

Перем КешИсполнителейШагов;

////////////////////////////////////////////////////////////////////
//{ Программный интерфейс

//{ использование контекста внутри шагов сценариев

// Параметры специально передаются без "Знач" для универсальности
Процедура СохранитьВКонтекст(Ключ, Значение) Экспорт
	Контекст.Вставить(Ключ, Значение);
КонецПроцедуры

// Возвращает ранее сохраненное значение из контекста по ключу
//
// Параметры:
//   Ключ - Любой - Ключ для выбора значения
//
//  Возвращаемое значение:
//   Любой - значение
//
Функция ПолучитьИзКонтекста(Знач Ключ) Экспорт
	Возврат Контекст[Ключ];
КонецФункции // ПолучитьИзКонтекста(Знач Ключ) Экспорт
// }

//{ вызов шагов сценариев
Процедура ВыполнитьШаг(Знач НаименованиеШагаСценария) Экспорт
	ТекстФичи = СтрШаблон("# language: ru%1%2", Символы.ПС, НаименованиеШагаСценария);
	РезультатыРазбора = ЧитательГеркин.ПрочитатьТекстФичи(ТекстФичи);
	РезультатыВыполнения = ВыполнитьДеревоФич(РезультатыРазбора, НаборБиблиотечныхШагов, Неопределено);
	
	СтатусВыполнения = ПолучитьИтоговыйСтатусВыполнения(РезультатыВыполнения);
	Если СтатусВыполнения <> ВозможныеСтатусыВыполнения().Пройден Тогда
		ВызватьИсключение СтрШаблон("Неверно выполнен шаг <%1>", НаименованиеШагаСценария);
	КонецЕсли;
КонецПроцедуры
// }

Функция ВыполнитьФичу(Знач ПарамФайлФичи, Знач ФайлБиблиотек = Неопределено, Знач ИскатьВПодкаталогах = Истина, 
	Знач ПарамИспользоватьБыстрыйОстановНаОшибке = Ложь, Знач ПарамИмяЭлементаСценария = "") Экспорт
	
	ФайлФичи = ПарамФайлФичи;
	ИспользоватьБыстрыйОстановНаОшибке = ПарамИспользоватьБыстрыйОстановНаОшибке;
	ИмяЭлементаСценария = ПарамИмяЭлементаСценария; 
	
	НаборБиблиотечныхШагов = ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек);
	Лог.Отладка("Найдено библиотечных шагов: %1 шт.", 
			?(ЗначениеЗаполнено(НаборБиблиотечныхШагов), НаборБиблиотечныхШагов.Количество(), "0"));
	
	Если ФайлФичи.ЭтоКаталог() Тогда
		Лог.Отладка("Подготовка к выполнению сценариев в каталоге %1", ФайлФичи.ПолноеИмя);
		МассивФайлов = НайтиФайлы(ФайлФичи.ПолноеИмя, "*.feature", ИскатьВПодкаталогах);
		
		НаборРезультатовВыполнения = Новый Массив;
		Для каждого НовыйФайлФичи Из МассивФайлов Цикл
			Если НовыйФайлФичи.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-фичи " + НовыйФайлФичи.ПолноеИмя;
			КонецЕсли;
			РезультатВыполнения = ВыполнитьФичуСУчетомБиблиотечныхШагов(НовыйФайлФичи);
			НаборРезультатовВыполнения.Добавить(РезультатВыполнения);
			Если ИспользоватьБыстрыйОстановНаОшибке 
				И ПолучитьИтоговыйСтатусВыполнения(РезультатВыполнения) <> ВозможныеСтатусыВыполнения().Пройден Тогда
					Прервать;				
			КонецЕсли;
		КонецЦикла;
		РезультатыВыполнения = СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения);
		
	Иначе
		
		РезультатыВыполнения = ВыполнитьФичуСУчетомБиблиотечныхШагов(ФайлФичи);
		
	КонецЕсли;
	
	Возврат РезультатыВыполнения;
КонецФункции

// Возвращается структура, ключ - ТипШага, значение - соответствие из СтатусыВыполненияДляПодсчета (ключ - статус выполнения, значение - количество)
Функция ПолучитьИтоговыеРезультатыВыполнения(РезультатыВыполнения, МассивИтогов) Экспорт
	Если МассивИтогов = Неопределено Тогда
		МассивИтогов = Новый Массив;
		МассивИтогов.Добавить(ВозможныеТипыШагов.Функциональность);
		МассивИтогов.Добавить(ВозможныеТипыШагов.Сценарий);
		МассивИтогов.Добавить(ВозможныеТипыШагов.Шаг);
	КонецЕсли;
	
	СтруктураИтогов = Новый Соответствие;
	Для каждого Элем Из МассивИтогов Цикл
		СтруктураИтогов.Вставить(Элем, СтатусыВыполненияДляПодсчета());
	КонецЦикла;
	
	РекурсивноПосчитатьИтогиВыполнения(РезультатыВыполнения, СтруктураИтогов);
	
	ИмяПоляИтога = "Итог";
	Для каждого Итоги Из СтруктураИтогов Цикл
		ДобавитьОбщееКоличествоКИтогам(Итоги.Ключ, Итоги.Значение, ИмяПоляИтога);
	КонецЦикла;
	
	Возврат СтруктураИтогов;
КонецФункции

// Вывести итоговые результаты выполнения в консоль
//		сколько фич, сценариев, шагов выполнено, пройдено, упало, не реализовано
//
// Параметры:
//   РезультатыВыполнения - ДеревоЗначений - дерево результатов
//   ПоказыватьИтогиФич - Булево - Истина = показывать итоги по фичам; Ложь - не показывать
//
Процедура ВывестиИтоговыеРезультатыВыполнения(Знач РезультатыВыполнения, Знач ПоказыватьИтогиФич = Истина) Экспорт
	
	ТекущийУровень = 0;
	Лог.Информация("");

	МассивИтогов = Неопределено;
	СтруктураИтогов = ПолучитьИтоговыеРезультатыВыполнения(РезультатыВыполнения, МассивИтогов);
	СтатусВыполнения = ПолучитьИтоговыйСтатусВыполнения(РезультатыВыполнения);
	
	ИмяПоляИтога = "Итог";
	Для каждого Элем Из МассивИтогов Цикл
		Итог = СтруктураИтогов[Элем];
		ВыводимИтог = Истина;
		Если НЕ ПоказыватьИтогиФич И Элем = ВозможныеТипыШагов.Функциональность И Итог[ИмяПоляИтога] = 1 Тогда
			ВыводимИтог = Ложь;
		КонецЕсли;
		Если ВыводимИтог Тогда
			ВывестиПредставлениеИтога(Итог, Элем, ИмяПоляИтога, СтатусВыполнения);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Статусы выполнения тестов - ВАЖЕН порядок значение (0,1...), используется в ЗапомнитьСамоеХудшееСостояние
Функция ВозможныеСтатусыВыполнения() Экспорт
	Если ВозможныеСтатусыВыполнения = Неопределено Тогда
		Рез = Новый Структура;
		Рез.Вставить("НеВыполнялся", "0 Не выполнялся"); // использую подобное текстовое значение для удобных ассертов при проверке статусов выполнения
		Рез.Вставить("Пройден", "1 пройден");
		Рез.Вставить("НеРеализован", "2 не реализован");
		Рез.Вставить("Сломался", "3 Сломался");
		ВозможныеСтатусыВыполнения = Новый ФиксированнаяСтруктура(Рез);
	КонецЕсли;
	Возврат ВозможныеСтатусыВыполнения;
КонецФункции

// Возвращает соответствие статусов выполнения (ключ) и кодов возврата процесса (значение)
// 	Используется кеширование на время работы.
//
//  Возвращаемое значение:
//   Соответствие - соответствие статусов выполнения (ключ) и кодов возврата процесса (значение)
//
Функция ВозможныеКодыВозвратовПроцесса() Экспорт
	Если ВозможныеКодыВозвратовПроцесса = Неопределено Тогда
		Рез = Новый Соответствие;
		Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
		Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
		Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 1);
		Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 2);
		ВозможныеКодыВозвратовПроцесса = Новый ФиксированноеСоответствие(Рез);
	КонецЕсли;
	Возврат ВозможныеКодыВозвратовПроцесса;
КонецФункции // ВозможныеКодыВозвратовПроцесса()

// Возвращает имя лога 1bdd
//
//  Возвращаемое значение:
//   Строка - имя лога
Функция ИмяЛога() Экспорт
	Возврат "bdd";
КонецФункции

//}

////////////////////////////////////////////////////////////////////
//{ Реализация

Функция ВыполнитьФичуСУчетомБиблиотечныхШагов(Знач ФайлФичи)
	Лог.Отладка("Подготовка к выполнению сценария %1", ФайлФичи.ПолноеИмя);
	
	Лог.Отладка("Читаю фичу");
	
	Лог.Отладка("Найдено библиотечных шагов: %1 шт.", 
		?(ЗначениеЗаполнено(НаборБиблиотечныхШагов), НаборБиблиотечныхШагов.Количество(), "0"));
	
	РезультатыРазбора = ЧитательГеркин.ПрочитатьФайлСценария(ФайлФичи);
	
	ОписаниеИсполнителяШагов = Неопределено;
	НовыйНаборБиблиотечныхШагов = ДополнитьНаборШаговИзИсполнителяШаговФичи(ФайлФичи, 
			НаборБиблиотечныхШагов, ОписаниеИсполнителяШагов);
	
	РезультатыВыполнения = ВыполнитьДеревоФич(РезультатыРазбора, НовыйНаборБиблиотечныхШагов, ОписаниеИсполнителяШагов);
	
	Возврат РезультатыВыполнения;
КонецФункции

// возвращает Неопределено, если не найдено, или соответствие, где ключ - имя шага, значение - Структура.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция ПолучитьНаборБиблиотечныхШагов(Знач ФайлБиблиотек) Экспорт //TODO перенести в секцию публичных методов или вообще в другой класс
	Если Не ЗначениеЗаполнено(ФайлБиблиотек) Тогда
		Возврат Неопределено;
	КонецЕсли;
	КоллекцияШагов = Новый Структура;
	
	Лог.Отладка("Получение всех шагов из библиотеки %1", ФайлБиблиотек.ПолноеИмя);
	МассивОписанийИсполнителяШагов = ПолучитЬМассивОписанийИсполнителяШагов(ФайлБиблиотек);
	Для каждого ОписаниеИсполнителяШагов Из МассивОписанийИсполнителяШагов Цикл
		Исполнитель = ОписаниеИсполнителяШагов.Исполнитель;
		МассивОписанийШагов = ПолучитьМассивОписанийШагов(Исполнитель);
		Для каждого ИмяШага Из МассивОписанийШагов Цикл
			АдресШага = ЧитательГеркин.НормализоватьАдресШага(ИмяШага);
			ДобавитьАдресШагаВКоллекциюШагов(КоллекцияШагов, АдресШага, ИмяШага, ОписаниеИсполнителяШагов, Ложь);			
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
			Лог.Отладка("Нашли исполнителя шагов %1", ФайлБиблиотек.ПолноеИмя);
		КонецЕсли;
	Иначе
		МассивФайлов = НайтиФайлы(ФайлБиблиотек.ПолноеИмя, "*.os", Истина);
		
		Для каждого ФайлИсполнителя Из МассивФайлов Цикл
			Лог.Отладка("Нашли файл, скрипт-кандидат %1", ФайлБиблиотек.ПолноеИмя);
			Если ФайлИсполнителя.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-шага " + ФайлИсполнителя.ПолноеИмя;
			КонецЕсли;
			
			ПоказыватьОшибкиИсполнителей = ФайлНаходитсяВСпециальномКаталогеРеализацииШагов(ФайлИсполнителя);
			ОписаниеИсполнителяШагов = ПолучитьИсполнителяШагов(ФайлИсполнителя, ПоказыватьОшибкиИсполнителей);
			Если ЗначениеЗаполнено(ОписаниеИсполнителяШагов) Тогда
				МассивОписанийИсполнителяШагов.Добавить(ОписаниеИсполнителяШагов);
				Лог.Отладка("Нашли исполнителя шагов %1", ФайлИсполнителя.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат МассивОписанийИсполнителяШагов;
КонецФункции // ПолучитЬМассивОписанийИсполнителяШагов(ФайлБиблиотек)

Функция ВыполнитьДеревоФич(РезультатыРазбора, Знач НаборБиблиотечныхШагов, Знач ОписаниеИсполнителяШагов)
	
	ДеревоФич = РезультатыРазбора.ДеревоФич;
	Ожидаем.Что(ДеревоФич, "Ожидали, что дерево фич будет передано как дерево значений, а это не так")
		.ИмеетТип("ДеревоЗначений");
	
	РезультатыВыполнения = ДеревоФич.Скопировать();
	РекурсивноУстановитьСтатусДляВсехУзлов(РезультатыВыполнения.Строки[0], ВозможныеСтатусыВыполнения.НеВыполнялся);
	
	РезультатыВыполнения.Строки[0].СтатусВыполнения = РекурсивноВыполнитьШаги(ОписаниеИсполнителяШагов, 
		НаборБиблиотечныхШагов, РезультатыВыполнения.Строки[0]);
	
	Возврат РезультатыВыполнения;
КонецФункции

Функция ДополнитьНаборШаговИзИсполнителяШаговФичи(Знач ФайлСценария, Знач НаборБиблиотечныхШагов, 
			ОписаниеИсполнителяШагов)
	ОписаниеИсполнителяШагов = НайтиИсполнителяШагов(ФайлСценария);
	Если ОписаниеИсполнителяШагов <> Неопределено Тогда
		
		НаборШаговИсполнителя = ПолучитьНаборБиблиотечныхШагов(ФайлСценария);
		Если ЗначениеЗаполнено(НаборШаговИсполнителя) Тогда
			Лог.Отладка("найдено шагов исполнителя %1", НаборШаговИсполнителя.Количество());
		КонецЕсли;
		Если ЗначениеЗаполнено(НаборБиблиотечныхШагов) Тогда
			Для каждого КлючЗначение Из НаборШаговИсполнителя Цикл
				ДобавитьАдресШагаВКоллекциюШагов(НаборБиблиотечныхШагов, КлючЗначение.Ключ, КлючЗначение.Ключ, 
					КлючЗначение.Значение, Истина);
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

Процедура ДобавитьАдресШагаВКоллекциюШагов(КоллекцияШагов, Знач АдресШага, Знач ИмяШага, 
											Знач ОписаниеИсполнителяШагов, Знач ВставлятьДублиШагов)

	ОписаниеИсполнителяШаговДляСравнения = Неопределено;
	КоллекцияШагов.Свойство(АдресШага, ОписаниеИсполнителяШаговДляСравнения);
	ВставлятьШаг = Истина;

	Если ОписаниеИсполнителяШаговДляСравнения <> Неопределено 
		И ОписаниеИсполнителяШаговДляСравнения.Файл.ПолноеИмя <> ОписаниеИсполнителяШагов.Файл.ПолноеИмя Тогда

		Лог.Предупреждение(СтрШаблон("Обнаружено дублирование шага <%1> в 2-х разных файлах шагов <%2> и <%3>", ИмяШага,
			ОписаниеИсполнителяШаговДляСравнения.Файл.ПолноеИмя, ОписаниеИсполнителяШагов.Файл.ПолноеИмя));
		ВставлятьШаг = ВставлятьДублиШагов;
	КонецЕсли;
	Если ВставлятьШаг Тогда
		КоллекцияШагов.Вставить(АдресШага, ОписаниеИсполнителяШагов);
		Лог.Отладка("Найдено имя шага <%1>, источник %2", ИмяШага, ОписаниеИсполнителяШагов.Файл.Имя);
	КонецЕсли;	
КонецПроцедуры

Функция ПолучитьМассивОписанийШагов(Знач ИсполнительШагов)
	Рефлектор = Новый Рефлектор;

	ИмяМетода = ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов();
	Если Рефлектор.МетодСуществует(ИсполнительШагов, ИмяМетода) Тогда

		МассивПараметров = Новый Массив;
		МассивПараметров.Добавить(ЭтотОбъект);
		Попытка
			МассивОписанийШагов = Рефлектор.ВызватьМетод(ИсполнительШагов, ИмяМетода, МассивПараметров);

			РезМассивОписанийШагов = Новый Массив;
			Для каждого АдресШага Из МассивОписанийШагов Цикл
				Если Рефлектор.МетодСуществует(ИсполнительШагов, АдресШага) Тогда
					РезМассивОписанийШагов.Добавить(АдресШага);
				Иначе
					Лог.Предупреждение("Пропускаю использование метода шага %1, 
					|т.к. в модуле шага нет реализации этого метода, хотя в методе ""%2"" шаг %1 указан.", 
						АдресШага, ИмяМетода);
				КонецЕсли;
			КонецЦикла;
			Возврат РезМассивОписанийШагов;
			
		Исключение
			//пропускаю ошибки
		КонецПопытки;
	КонецЕсли;	
	Возврат Новый Массив;
	
КонецФункции // ПолучитьМассивОписанийШагов()

// возвращает Неопределено или структуру.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция НайтиИсполнителяШагов(Знач ФайлФичи)
	ПутьФичи = ФайлФичи.Путь;
	Лог.Отладка("Ищу исполнителя шагов в каталоге %1", ПутьФичи);
	ПутьКИсполнителю = ОбъединитьПути(ПутьФичи, "step_definitions");
	ПутьКИсполнителю = ОбъединитьПути(ПутьКИсполнителю, ФайлФичи.ИмяБезРасширения+ ".os");
	
	ФайлИсполнителя = Новый Файл(ПутьКИсполнителю);
	ОписаниеИсполнителя = ПолучитьИсполнителяШагов(ФайлИсполнителя, Истина);
	Возврат ОписаниеИсполнителя;
КонецФункции

// возвращает Неопределено или структуру.
// В структуре есть поля 
// 		"Исполнитель" - объект-исполнитель шага (os-скрипт)
// 		"Файл" - объект-файл с информацией о файле-исполнителе шага
Функция ПолучитьИсполнителяШагов(Знач ФайлИсполнителя, Знач ПоказыватьОшибкиИсполнителей = Ложь)
	ПутьИсполнителя = ФайлИсполнителя.ПолноеИмя;
	Лог.Отладка("Ищу исполнителя шагов в файле %1", ПутьИсполнителя);

	Если КешИсполнителейШагов = Неопределено Тогда
		КешИсполнителейШагов = Новый Соответствие();
	КонецЕсли;
	ОписаниеИсполнителя = КешИсполнителейШагов.Получить(ПутьИсполнителя);
	Если ОписаниеИсполнителя = Неопределено Тогда
	
		Если ФайлИсполнителя.Существует() Тогда
			Попытка
				ИсполнительШагов = ЗагрузитьСценарий(ПутьИсполнителя);
				ОписаниеИсполнителя = Новый Структура("Исполнитель,Файл", ИсполнительШагов, ФайлИсполнителя);
				КешИсполнителейШагов.Вставить(ПутьИсполнителя, ОписаниеИсполнителя);
			Исключение
				Инфо = ИнформацияОбОшибке();
				Если ПоказыватьОшибкиИсполнителей Тогда
					Лог.Предупреждение("Ошибка при загрузке файла %1 %2%3", 
						ПутьИсполнителя, Символы.ПС, ПодробноеПредставлениеОшибки(Инфо));
				КонецЕсли;
				
				ОписаниеИсполнителя = Неопределено;
			КонецПопытки;
			
		Иначе
			ОписаниеИсполнителя = Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОписаниеИсполнителя;
КонецФункции // ПолучитьИсполнителяШагов()

Функция ФайлНаходитсяВСпециальномКаталогеРеализацииШагов(Знач ФайлСкрипта)
	КаталогРодитель = Новый Файл(ФайлСкрипта.Путь);
	Возврат НРег(КаталогРодитель.Имя) = "step_definitions";
КонецФункции // ФайлНаходитсяВСпециальномКаталогеРеализацииШагов(ФайлСкрипта)

Функция РекурсивноВыполнитьШаги(Знач ОписаниеИсполнителяШагов, Знач НаборБиблиотечныхШагов, Знач Узел)
	ТекущийУровень = Узел.Уровень();
	ПредставлениеЛексемы = ?(Узел.ТипШага <> ВозможныеТипыШагов.Описание, Узел.Лексема + " ", "");
	
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Если Узел.ТипШага = ВозможныеТипыШагов.Сценарий И Не ИмяСценарияПодходитПодФильтр(Узел.Тело, ИмяЭлементаСценария) Тогда
		Возврат СтатусВыполнения; 
	КонецЕсли;
	
	Если Узел.ТипШага <> ВозможныеТипыШагов.Шаг Тогда
		Лог.Информация(ПредставлениеЛексемы + Узел.Тело);
	КонецЕсли;
	
	Лог.Отладка("Выполняю узел <%1>, адрес <%2>, тело <%3>", Узел.ТипШага, Узел.АдресШага, Узел.Тело);
	
	ХукВыполненУспешно = ВыполнитьХукУзла(ЧитательГеркин.ВозможныеХуки().ПередЗапускомСценария, 
		ОписаниеИсполнителяШагов, Узел);
	Если Не ХукВыполненУспешно Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
	Иначе
		
		СтатусВыполнения = ВыполнитьДействиеУзла(НаборБиблиотечныхШагов, Узел);
		
		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Сломался Тогда
			Для Каждого СтрокаДерева Из Узел.Строки Цикл
				НовыйСтатус = РекурсивноВыполнитьШаги(ОписаниеИсполнителяШагов, НаборБиблиотечныхШагов, СтрокаДерева);
				СтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(СтатусВыполнения, НовыйСтатус);
				ВыходитьПриНеудачномВыполнении = ИспользоватьБыстрыйОстановНаОшибке 
					Или СтрокаДерева.ТипШага = ВозможныеТипыШагов.Шаг;
				Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден И ВыходитьПриНеудачномВыполнении Тогда
						Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	ХукВыполненУспешно = ВыполнитьХукУзла(ЧитательГеркин.ВозможныеХуки().ПослеЗапускаСценария, 
			ОписаниеИсполнителяШагов, Узел);
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

Функция ВыполнитьХукУзла(Знач ОписаниеХука, Знач ОписаниеИсполнителяШагов, Знач Узел, Знач ПредставлениеШага = "")
	Рез = Истина;
	Если Узел.ТипШага = ОписаниеХука.ТипШага Тогда
		АдресХука = ОписаниеХука.АдресШага;
		Рефлектор = Новый Рефлектор;
		Если ОписаниеИсполнителяШагов <> Неопределено 
			И Рефлектор.МетодСуществует(ОписаниеИсполнителяШагов.Исполнитель, АдресХука) Тогда
			
			СтрокаПараметров = "Узел";
			МассивПараметров = Новый Массив;
			МассивПараметров.Добавить(Узел);			

			ИмяФайлаШагов = ОписаниеИсполнителяШагов.Файл.Имя;
			Лог.Отладка("	Выполняю шаг <%1>, параметры <%2>, источник %3", 
					АдресХука, СтрокаПараметров, ИмяФайлаШагов);

			Попытка
				Рефлектор.ВызватьМетод(ОписаниеИсполнителяШагов.Исполнитель, АдресХука, МассивПараметров);
				
			Исключение
				
				Инфо = ИнформацияОбОшибке();
				ТекстОшибки = ПодробноеПредставлениеОшибки(Инфо);
				
				Рез = Ложь;
				ПредставлениеШага = СтрШаблон("Не удалось выполнить хук <%1> для шага <%2>
				|%3
				|%4", АдресХука, ИмяФайлаШагов, ПредставлениеШага, ТекстОшибки);
				ВывестиСообщение(ПредставлениеШага, ВозможныеСтатусыВыполнения.Сломался);
				
				Узел.ОписаниеОшибкиВыполнения = ПредставлениеШага;
				
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Рез;
КонецФункции // ВыполнитьХукУзла_ПередВыполнением(Узел)

Функция ВыполнитьДействиеУзла(Знач НаборБиблиотечныхШагов, Знач Узел)
	
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Если Узел.ТипШага = ВозможныеТипыШагов.Шаг Тогда
		СтатусВыполнения = ВыполнитьШагСценария(Узел.АдресШага, Узел.Параметры, 
			НаборБиблиотечныхШагов, Узел.Тело, Узел.ОписаниеОшибкиВыполнения);
		
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

Функция ВыполнитьШагСценария(Знач АдресШага, Знач ПараметрыШага, Знач НаборБиблиотечныхШагов, 
							Знач ПредставлениеШага, ОписаниеОшибкиВыполнения)

	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	ОписаниеОшибкиВыполнения = "";
	
	ОписаниеИсполнителяШагов = Неопределено;
	ШагРеализован = НаборБиблиотечныхШагов.Свойство(ЧитательГеркин.НормализоватьАдресШага(АдресШага), 
		ОписаниеИсполнителяШагов);

	Если Не ШагРеализован ИЛИ ОписаниеИсполнителяШагов = Неопределено Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
	Иначе
		Рефлектор = Новый Рефлектор;
		
		Если Не Рефлектор.МетодСуществует(ОписаниеИсполнителяШагов.Исполнитель, АдресШага) Тогда //вдруг сняли Экспорт с метода или метода вообще нет
			СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
		Иначе
			
			СтрокаПараметров = "";
			МассивПараметров = Новый Массив;
			ПолучитьМассивПараметров(МассивПараметров, ПараметрыШага, СтрокаПараметров);
			
			СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров) - 1);
			Лог.Отладка("	Выполняю шаг <%1>, параметры <%2>, источник %3", 
					АдресШага, СтрокаПараметров, ОписаниеИсполнителяШагов.Файл.Имя);

			Попытка
				Рефлектор.ВызватьМетод(ОписаниеИсполнителяШагов.Исполнитель, АдресШага, МассивПараметров);
				СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
				
			Исключение
				
				Инфо = ИнформацияОбОшибке();
				текстОшибки = ПодробноеПредставлениеОшибки(Инфо);
				
				ПредставлениеШага = "";
				Если Инфо.Параметры = ЧитательГеркин.ПараметрИсключенияДляЕщеНеРеализованногоШага() Тогда
					СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
				ИначеЕсли Инфо.Описание = "Слишком много фактических параметров" Тогда //в случае неверного разбора можем получить неверный адрес или неверные параметры
					СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
					ПредставлениеШага = ПредставлениеШага + Символы.ПС + текстОшибки + Символы.ПС +
					СтрШаблон("Дополнительно: Для шага <%1> передано или неверное количество параметров %2 
							|или неверные параметры <%3>", АдресШага, МассивПараметров.Количество(), СтрокаПараметров);
				Иначе
					СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
					ПредставлениеШага = ПредставлениеШага + Символы.ПС + текстОшибки;
				КонецЕсли;
				
				ОписаниеОшибкиВыполнения = ПредставлениеШага;
				Лог.Ошибка("ОписаниеОшибкиВыполнения %1", ОписаниеОшибкиВыполнения);
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

Функция ПолучитьИтоговыйСтатусВыполнения(Знач РезультатыВыполнения) Экспорт //TODO перенести в секцию публичных методов или вообще в другой класс
	ИтоговыйСтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Для каждого РезультатВыполненияФичи Из РезультатыВыполнения.Строки Цикл
		ИтоговыйСтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(РезультатВыполненияФичи.СтатусВыполнения, 
			ИтоговыйСтатусВыполнения);
	КонецЦикла;
	
	Возврат ИтоговыйСтатусВыполнения;
КонецФункции

Процедура РекурсивноПосчитатьИтогиВыполнения(Узел, СтруктураИтогов)
	Если ТипЗнч(Узел) <> Тип("ДеревоЗначений") Тогда
		НужныйИтог = СтруктураИтогов.Получить(Узел.ТипШага);
		Если НужныйИтог = Неопределено Тогда
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

Процедура ВывестиПредставлениеИтога(Знач Итог,  Знач ПредставлениеШага, Знач ИмяПоляИтога, Знач СтатусВыполнения)
	Представление = СтрШаблон("%9 %10 ( %1 %2, %3 %4, %5 %6, %7 %8 )",
	Итог[ВозможныеСтатусыВыполнения.Пройден], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Пройден],
	Итог[ВозможныеСтатусыВыполнения.НеРеализован], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеРеализован],
	Итог[ВозможныеСтатусыВыполнения.Сломался], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Сломался],
	Итог[ВозможныеСтатусыВыполнения.НеВыполнялся], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеВыполнялся],
	Итог[ИмяПоляИтога], ПредставлениеШага
	);
	ВывестиСообщение(Представление, СтатусВыполнения);
КонецПроцедуры

Процедура РекурсивноУстановитьСтатусДляВсехУзлов(Узел, Знач НовыйСтатус)
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
Функция ЗапомнитьСамоеХудшееСостояние(Знач ТекущееСостояние, Знач НовоеСостояние)
	ТекущееСостояние = Макс(ТекущееСостояние, НовоеСостояние);
	Возврат ТекущееСостояние;
	
КонецФункции

// реализация интерфейса раскладки для логов
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	Отступ = ПолучитьОтступ(ТекущийУровень);
	НаименованиеУровня = "";
	
	Если Уровень = УровниЛога.Информация Тогда
		НаименованиеУровня = ?(Лог.Уровень() <> Уровень, УровниЛога.НаименованиеУровня(Уровень) + Символы.Таб + "- ", "");
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

// Возвращается соответствие, где ключ - статус выполнения, значение - количество
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
