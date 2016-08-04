﻿Перем БДД;

Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;

	ВсеШаги = Новый Массив;

	ВсеШаги.Добавить("ПередаюПараметр_Строку");
	ВсеШаги.Добавить("РаскладываюПараметр_СтрокуПоРазделителюКавычкаВМассив");
	ВсеШаги.Добавить("ЭлементМассиваРавен");
	ВсеШаги.Добавить("РаскладываюПараметр_СтрокуПоРазделителюАпострофВМассив");

	Возврат ВсеШаги;
КонецФункции

// Процедура ПередЗапускомСценария(Знач Узел) Экспорт
// 	БДД.СохранитьВКонтекст("ПараметрСтрока", Неопределено);
// 	БДД.СохранитьВКонтекст("МассивИзСтроки", Неопределено);
// КонецПроцедуры

//передаю параметр-строку 'Начало "ВнутриКавычек" Конец'
Процедура ПередаюПараметр_Строку(Знач ПарамСтрока1) Экспорт
	БДД.СохранитьВКонтекст("ПараметрСтрока", ПарамСтрока1);
КонецПроцедуры

//раскладываю параметр-строку по разделителю кавычка в массив
Процедура РаскладываюПараметр_СтрокуПоРазделителюКавычкаВМассив() Экспорт
	ПарамСтрока = БДД.ПолучитьИзКонтекста("ПараметрСтрока");
	БДД.СохранитьВКонтекст("МассивИзСтроки", СтрРазделить(ПарамСтрока, """"));
КонецПроцедуры

//раскладываю параметр-строку по разделителю апостроф в массив
Процедура РаскладываюПараметр_СтрокуПоРазделителюАпострофВМассив() Экспорт
	ПарамСтрока = БДД.ПолучитьИзКонтекста("ПараметрСтрока");
	БДД.СохранитьВКонтекст("МассивИзСтроки", СтрРазделить(ПарамСтрока, "'"));
КонецПроцедуры

//0 элемент массива равен "Начало "
Процедура ЭлементМассиваРавен(Знач НомерВКоллекции, Знач ОжидаемаяПодстрока) Экспорт
	Массив = БДД.ПолучитьИзКонтекста("МассивИзСтроки");
	Ожидаем.Что(Массив[НомерВКоллекции]).Равно(ОжидаемаяПодстрока);
КонецПроцедуры
