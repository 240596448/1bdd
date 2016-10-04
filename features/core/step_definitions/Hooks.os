﻿// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd

#Использовать asserts

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ЯПодставилФайлШаговФичиИзКаталога");
	ВсеШаги.Добавить("ТекстФайла_ЖурналаРавен");

	Возврат ВсеШаги;
КонецФункции

// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт
	Ожидаем.Что(БДД, "Должен быть доступен объект БДД, а он не доступен. ПередЗапускомСценария").ЭтоНе().ЕстьНеопределено();
КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт
	Ожидаем.Что(БДД, "Должен быть доступен объект БДД, а он не доступен. ПослеЗапускаСценария").ЭтоНе().ЕстьНеопределено();
КонецПроцедуры

//я подставил файл шагов фичи "ПроверкаХуков" из каталога "tests\fixtures"
Процедура ЯПодставилФайлШаговФичиИзКаталога(Знач ИмяФичи, Знач КаталогФичи) Экспорт
	ИмяИсполнителяШагов = ИмяФичи + ".os";
	ИсходныйФайлИсполнителяШагов = Новый Файл(ОбъединитьПути(КаталогПроекта(), КаталогФичи, "step_definitions", ИмяИсполнителяШагов ));
	ФайлИсполнителяШагов = Новый Файл(ОбъединитьПути("step_definitions", ИмяИсполнителяШагов ));

	Если ФайлИсполнителяШагов.Существует() Тогда
		УдалитьФайлы(ФайлИсполнителяШагов.ПолноеИмя);
	КонецЕсли;
	КопироватьФайл(ИсходныйФайлИсполнителяШагов.ПолноеИмя, ФайлИсполнителяШагов.ПолноеИмя);
КонецПроцедуры

//текст файла-журнала равен "ПередЗапускомСценария;ШагСценария"
Процедура ТекстФайла_ЖурналаРавен(Знач ТекстЖурнала) Экспорт
	 СтрокаИзЖурнала = ПрочитатьЖурнал();
	 Ожидаем.Что(СтрокаИзЖурнала).Равно(ТекстЖурнала);
КонецПроцедуры

//TODO дубль с ПроверкаХуков.os
Функция ПрочитатьЖурнал()
	ФайлЖурнала = Новый Файл(ПутьФайлаЖурнала());
	Если ФайлЖурнала.Существует() Тогда
		
		ЧтениеТекста = Новый ЧтениеТекста;
		ЧтениеТекста.Открыть(ПутьФайлаЖурнала(),"UTF-8");

		СтрокаИзЖурнала = ЧтениеТекста.ПрочитатьСтроку();
		ЧтениеТекста.Закрыть();
	Иначе
		СтрокаИзЖурнала = "";
	КонецЕсли;
	Возврат СтрокаИзЖурнала;
КонецФункции

//TODO дубль с ПроверкаХуков.os
Функция ПутьФайлаЖурнала()
	Возврат "ФайлЖурнала.log";
КонецФункции // ПутьФайлаЖурнала()

Функция КаталогПроекта() Экспорт
	КаталогПроекта = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..", "..");
	Возврат КаталогПроекта;
КонецФункции // ПолучитьКаталогИсходников()
