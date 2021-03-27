#Использовать fs

Перем ИсполнительБДД;
Перем ВозможныеСтатусыВыполнения;
Перем ТипыСостояния;

// Сформировать лог-файл проверки в формате Generic Execution для Sonarqube
//  https://docs.sonarqube.org/latest/analysis/generic-test/#header-2
//
// Параметры:
//   РезультатыВыполнения - ДеревоЗначение
//   СтатусВыполнения - СтатусыВыполнения
//   ПутьОтчетаХМЛ - Строка - путь к лог-файлу проверки в формате Generic Execution
//
Процедура Сформировать(Знач РезультатыВыполнения, Знач СтатусВыполнения, Знач ПутьОтчетаХМЛ) Экспорт
    
    // ДатаНачала = Неопределено;
    
    ИсполнительБДД = Новый ИсполнительБДД;
    ВозможныеСтатусыВыполнения = ИсполнительБДД.ВозможныеСтатусыВыполнения();
    
    ЧитательГеркин = Новый ЧитательГеркин;
    ВозможныеТипыШагов = ЧитательГеркин.ВозможныеТипыШагов();
    
    ТипШага_Функциональность = ВозможныеТипыШагов.Функциональность; 
    МассивШагов = Новый Массив;
    МассивШагов.Добавить(ТипШага_Функциональность);
    МассивШагов.Добавить(ВозможныеТипыШагов.Сценарий);
    СтруктураИтогов = ИсполнительБДД.ПолучитьИтоговыеРезультатыВыполнения(РезультатыВыполнения, МассивШагов);
    
    ЗаписьXML = Новый ЗаписьXML;
    ЗаписьXML.УстановитьСтроку("UTF-8");
    ЗаписьXML.ЗаписатьОбъявлениеXML();
    
    КоличествоОшибок = СтруктураИтогов[ТипШага_Функциональность][ВозможныеСтатусыВыполнения.Сломался];
    КоличествоНереализованныхТестов = СтруктураИтогов[ТипШага_Функциональность][ВозможныеСтатусыВыполнения.НеРеализован];
    ВсегоТестов = СтруктураИтогов[ТипШага_Функциональность][ВозможныеСтатусыВыполнения.Пройден] 
				+ КоличествоОшибок + КоличествоНереализованныхТестов;
    
    // ВремяВыполнения = ТекущаяДата() - ДатаНачала;
    ВремяВыполнения = 0; // TODO вычислять время выполнения прогона фич, шагов и сценариев
    
    ЗаписьXML.ЗаписатьНачалоЭлемента("testExecutions");
    ЗаписьXML.ЗаписатьАтрибут("version", XMLСтрока("1"));
    
    РезультатыПоФайлам = Новый Соответствие;
    Для Каждого Узел Из РезультатыВыполнения.Строки Цикл
        ПутьФайла = Узел.ПутьФайла;
        УзлыСценариев = РезультатыПоФайлам.Получить(ПутьФайла);
        Если Не ЗначениеЗаполнено(УзлыСценариев) Тогда
            УзлыСценариев = Новый Массив;
        КонецЕсли;
        УзлыСценариев.Добавить(Узел);
        РезультатыПоФайлам.Вставить(ПутьФайла, УзлыСценариев);
    КонецЦикла;
    
    Для Каждого КлючЗначение Из РезультатыПоФайлам Цикл
        ПутьФайла = КлючЗначение.Ключ;
        ОтносительныйПуть = ФС.ОтносительныйПуть(ТекущийКаталог(), ПутьФайла);
        ОтносительныйПуть = СтрЗаменить(ОтносительныйПуть, "\", "/");

        УзлыСценариев = КлючЗначение.Значение;
        ЗаписьXML.ЗаписатьНачалоЭлемента("file");
        ЗаписьXML.ЗаписатьАтрибут("path", ОтносительныйПуть);

        Для каждого УзелСценария Из УзлыСценариев Цикл
            ЗаполнитьРезультатТестовогоСлучая(ЗаписьXML, УзелСценария);
        КонецЦикла;
        
        ЗаписьXML.ЗаписатьКонецЭлемента();
    КонецЦикла;
        
    ЗаписьXML.ЗаписатьКонецЭлемента();
    
    СтрокаХМЛ = ЗаписьXML.Закрыть();
    
    ФайлОтчета = Новый Файл(ОбъединитьПути(ТекущийКаталог(), ПутьОтчетаХМЛ));
    
    ЗаписьXML = Новый ЗаписьXML;
    ЗаписьXML.ОткрытьФайл(ФайлОтчета.ПолноеИмя);
    ЗаписьXML.ЗаписатьБезОбработки(СтрокаХМЛ);// таким образом файл будет записан всего один раз, и не будет проблем с обработкой на билд-сервере TeamCity
    ЗаписьXML.Закрыть();
    Сообщить(" ");
	Сообщить(СтрШаблон("Путь к лог-файлу проверки в формате Generic Execution для Sonarqube <%1>", ФайлОтчета.ПолноеИмя));
    
КонецПроцедуры

Процедура ЗаполнитьРезультатТестовогоСлучая(ЗаписьXML, Знач УзелСценария)
    
    ЗаписьXML.ЗаписатьНачалоЭлемента("testCase");
    ЗаписьXML.ЗаписатьАтрибут("name", УзелСценария.Тело);
    ЗаписьXML.ЗаписатьАтрибут("duration", 1); // TODO вычислить время выполнения сценария и всех его шагов
    
    СтатусВыполнения = УзелСценария.СтатусВыполнения;
    ТипСостояния = ПолучитьТипыСостояния()[СтатусВыполнения];
    Если ЗначениеЗаполнено(ТипСостояния) Тогда
        
        ЗаписьXML.ЗаписатьНачалоЭлемента(ТипСостояния);
        ОписаниеОшибкиВыполнения = УзелСценария.ОписаниеОшибкиВыполнения;
		Сообщить(СтрШаблон("ОписаниеОшибкиВыполнения %1", ОписаниеОшибкиВыполнения));
        // TODO: НайтиНедопустимыеСимволыXML()
        XMLОписаниеОшибкиВыполнения = XMLСтрока(ОписаниеОшибкиВыполнения);

        КомментарийПоУпавшемуШагу = "";
        Для Каждого УзелШага Из УзелСценария.Строки Цикл
            ТипСостоянияУпавшегоШага = ПолучитьТипыСостояния()[УзелШага.СтатусВыполнения];
            Если ЗначениеЗаполнено(ТипСостоянияУпавшегоШага) Тогда
                КомментарийПоУпавшемуШагу = УзелШага.Тело;
            КонецЕсли;
        КонецЦикла;	
        
        ЗаписьXML.ЗаписатьАтрибут("message", КомментарийПоУпавшемуШагу);
        ЗаписьXML.ЗаписатьТекст(XMLОписаниеОшибкиВыполнения); 
        ЗаписьXML.ЗаписатьКонецЭлемента();
    КонецЕсли;
    
    ЗаписьXML.ЗаписатьКонецЭлемента();
    
КонецПроцедуры

Функция ПолучитьТипыСостояния()
    Если ТипыСостояния = Неопределено Тогда
        
        ТипыСостояния = Новый Соответствие;
        ТипыСостояния.Вставить(ВозможныеСтатусыВыполнения.Пройден, "");
        ТипыСостояния.Вставить(ВозможныеСтатусыВыполнения.Сломался, "failure");
        ТипыСостояния.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, "skipped");
        ТипыСостояния.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, "");
        ТипыСостояния = Новый ФиксированноеСоответствие(ТипыСостояния);
    КонецЕсли;
    Возврат ТипыСостояния;
КонецФункции
