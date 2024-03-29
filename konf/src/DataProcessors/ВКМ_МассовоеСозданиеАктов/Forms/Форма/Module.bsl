#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	ЗапуститьОперациюЗаполненияТЧ();
КонецПроцедуры 

#КонецОбласти


#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура ОбновитьТЧ(Команда)
	Если ЗначениеЗаполнено(Объект.Период) Тогда
		ЗапуститьОперациюЗаполненияТЧ();			
	Иначе 
		Объект.СписокДоговоровиРеализаций.Очистить();
		ОбщегоНазначенияКлиент.СообщитьПользователю("Выберите период.");	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте

Процедура СформироватьРеализации(Команда)
	ЗапуститьОперациюСформироватьРеализации();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаКлиенте
Процедура ЗапуститьОперациюЗаполненияТЧ()
	
	
	ПараметрыЗапуска = Новый Структура;
	ПараметрыЗапуска.Вставить("Период", Объект.Период);
	
	
	СтруктураФоновогоЗадания 	= ВыполнитьФоновоеЗаданиеНаСервере(ПараметрыЗапуска, УникальныйИдентификатор);
	
	ПараметрыОжидания 	= ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.Интервал  = 0;
	
	ДлительныеОперацииКлиент.ОжидатьЗавершение(СтруктураФоновогоЗадания, Новый ОписаниеОповещения("ЗаполнитьТЧ_НаКлиенте", ЭтотОбъект), ПараметрыОжидания);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТЧ_НаКлиенте(Результат, ДополнительныеПараметры) Экспорт
	
	ЗаполнитьТЧ(Результат, ДополнительныеПараметры);	

КонецПроцедуры


&НаСервере
Функция ВыполнитьФоновоеЗаданиеНаСервере(ПараметрыЗапуска, УникальныйИдентификатор)
	
	НаименованиеЗадания = "Получения списка договоров и реализици товаров и услуг.";
	ВыполняемыйМетод = "Обработки.ВКМ_МассовоеСозданиеАктов.ЗаполнитьТЧ";
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияФункции(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НаименованиеЗадания;
	ПараметрыВыполнения.ЗапуститьВФоне = Истина;
	
	СтруктураФоновогоЗадания = ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения, ВыполняемыйМетод, ПараметрыЗапуска.Период); 
	
	Возврат СтруктураФоновогоЗадания;
	
КонецФункции
//@skip-check export-method-in-command-form-module
// Заполняет ТЧ после выполнения длительной операции
//
// Параметры:
//  Результат - Строка - Адрес во временном хранилище.
//  ДополнительныеПараметры - Структура - Не импользуетсяz
//
&НаСервере
Процедура ЗаполнитьТЧ(Результат, ДополнительныеПараметры) Экспорт
	
	ТЗ_Данные = ПолучитьИЗВременногоХранилища(Результат.АдресРезультата);
	
	Если Не ЗначениеЗаполнено(ТЗ_Данные) Тогда 
		Объект.СписокДоговоровиРеализаций.Очистить();
		Возврат;
	КонецЕсли;
	
	Объект.СписокДоговоровиРеализаций.Загрузить(ТЗ_Данные);
	
КонецПроцедуры


&НаКлиенте
Процедура ЗапуститьОперациюСформироватьРеализации()
	
	Если Объект.СписокДоговоровиРеализаций.Количество() > 0 Тогда 
		
		МассивСтрокТЧ = Новый Массив;
		Для Каждого СтрокаТЧ из Объект.СписокДоговоровиРеализаций Цикл
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.РеализацияТоваровИУслуг) Тогда
				Структура = Новый Структура;
				Структура.Вставить("Договор", СтрокаТЧ.Договор);
				Структура.Вставить("РеализацияТоваровИУслуг", СтрокаТЧ.РеализацияТоваровИУслуг);
				Структура.Вставить("Контрагент", СтрокаТЧ.Контрагент);    
				Структура.Вставить("Организация", СтрокаТЧ.Организация); 
				Структура.Вставить("ОкончаниеПериода", СтрокаТЧ.ОкончаниеПериода);
				МассивСтрокТЧ.Добавить(Структура);
			КонецЕсли;
		КонецЦикла; 
		
		Если Не ЗначениеЗаполнено(МассивСтрокТЧ) Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю("В этом месяце по всем договорам уже сформированы документы ""Реализация товаров и услуг""");
			Возврат;
		КонецЕсли;
		
		ПараметрыЗапуска = Новый Структура;
		ПараметрыЗапуска.Вставить("МассивСтрокТЧ", МассивСтрокТЧ);
		
		СтруктураФоновогоЗадания 	= ВыполнитьФоновоеЗаданиеФормированиеДокументовНаСервере(ПараметрыЗапуска, УникальныйИдентификатор);
		
		ПараметрыОжидания 	= ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
		ПараметрыОжидания.Интервал  = 0;
		
		ДлительныеОперацииКлиент.ОжидатьЗавершение(СтруктураФоновогоЗадания, Новый ОписаниеОповещения("ОбработатьРезультатФОрмированияДокументов", ЭтотОбъект), ПараметрыОжидания);
		
	КонецЕсли;

КонецПроцедуры    

&НаСервере
Функция ВыполнитьФоновоеЗаданиеФормированиеДокументовНаСервере(ПараметрыЗапуска, УникальныйИдентификатор)
	
	НаименованиеЗадания = "Формирование документов";
	ВыполняемыйМетод = "Обработки.ВКМ_МассовоеСозданиеАктов.ФормированиеДокументов";
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияФункции(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НаименованиеЗадания;
	ПараметрыВыполнения.ЗапуститьВФоне = Истина;
	
	СтруктураФоновогоЗадания = ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения, ВыполняемыйМетод, ПараметрыЗапуска.МассивСтрокТЧ); 
	
	Возврат СтруктураФоновогоЗадания;
	
КонецФункции    

&НаКлиенте
Процедура ОбработатьРезультатФОрмированияДокументов(Результат, ДополнительныеПараметры) Экспорт
	
	МассивСсылокДокументов = ПолучитьИЗВременногоХранилища(Результат.АдресРезультата);
	
	Если Не ЗначениеЗаполнено(МассивСсылокДокументов) Тогда 
		Возврат;
	КонецЕсли;
	
	
	Для Каждого ЭлементМассива из МассивСсылокДокументов Цикл
		Если ЗначениеЗаполнено(ЭлементМассива.ДокументСсылка) Тогда
			ТекстСообщения = (" создан документ ");	
		Иначе
			ТекстСообщения = (" не удалось создать документ ");	  
			
			Если ЗначениеЗаполнено(ЭлементМассива.НеЗаполненныеРеквизиты) Тогда  
				ТекстСообщенияРеквизиты = ". Не заполнены реквизиты: ";
				Для Каждого РеквизитСтрока Из ЭлементМассива.НеЗаполненныеРеквизиты Цикл
					ТекстСообщенияРеквизиты = ТекстСообщенияРеквизиты + РеквизитСтрока + " | ";
				КонецЦикла; 
				
				ТекстСообщения = СтрШаблон("%1 %2", ТекстСообщения, ТекстСообщенияРеквизиты); 
				
			КонецЕСли;
		КонецЕсли;		                          
		
		ТекстСообщенияПолный = СтрШаблон("Для договора: %1 , контрагент: %2 %3 %4", ЭлементМассива.Договор, ЭлементМассива.Контрагент, ТекстСообщения, ЭлементМассива.ДокументСсылка);
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ТекстСообщенияПолный;
		Сообщение.Сообщить();
			
	КонецЦикла; 
	
	ЗапуститьОперациюЗаполненияТЧ();
	
КонецПроцедуры       

#КонецОбласти


