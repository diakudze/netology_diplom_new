#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	
	#Область СлужебныеПроцедурыИФункции 
	
	Функция ЗаполнитьТЧ(Период) Экспорт
		Результат = Неопределено;
		
		ТЗ_Данные = ПолучитьТЗДоговорыИРеализации(Период);
		
		Если ЗначениеЗаполнено(ТЗ_Данные) Тогда
			Результат = ТЗ_Данные;
			
		КонецЕсли;  
		
		Возврат Результат;		
	КонецФункции
	
	Функция ФормированиеДокументов(МассивСтрокТЧ) Экспорт
		
		
		Комментарий = "Документ создан автоматически обработкой ""ВКМ_МассовоеСозданиеАктов""";
		
		МассивСозданныхДокументов = Новый Массив; 
				Для Каждого СтрокаДоговор из МассивСтрокТЧ Цикл
			Структура = Новый Структура;
			Структура.Вставить("Договор", СтрокаДоговор.Договор);
			
			МассивДанныхДляЗаполнения = Новый Массив; 
			СтруктураДанных = Новый Структура;
			СтруктураДанных.Вставить("Контрагент",СтрокаДоговор.Контрагент);
			СтруктураДанных.Вставить("Дата",СтрокаДоговор.ОкончаниеПериода); 
			
			СтруктураДанных.Вставить("Договор",СтрокаДоговор.Договор);
			СтруктураДанных.Вставить("Организация",СтрокаДоговор.Организация); 
			СтруктураДанных.Вставить("Комментарий", Комментарий);
			МассивДанныхДляЗаполнения.Добавить(СтруктураДанных);		
			
			НачатьТранзакцию();	
			ДокументОбъект = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
			
			ДокументОбъект.Заполнить(МассивДанныхДляЗаполнения);  
			ДокументЗаполнен = ДокументОбъект.ПроверитьЗаполнение();
			
			Если ДокументЗаполнен Тогда
				Попытка
					ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
					Структура.Вставить("ДокументСсылка", ДокументОбъект.Ссылка);
					Структура.Вставить("Контрагент",СтрокаДоговор.Контрагент); 
					Структура.Вставить("НеЗаполненныеРеквизиты", Неопределено);
					
					
					МассивСозданныхДокументов.Добавить(Структура);
					ЗафиксироватьТранзакцию();
				Исключение                     
					ОтменитьТранзакцию();
					
					ЗаписьЖурналаРегистрации("ОБРАБОТКА: Массовое создание актов", УровеньЖурналаРегистрации.Ошибка, Метаданные.Обработки.ВКМ_МассовоеСозданиеАктов, СтрШаблон("Не удалось создать док. РеализацияТоваровУслуг для договора: %1, котрагент: %2, организация: %3.", СтрокаДоговор.Договор, СтрокаДоговор.Контрагент, СтрокаДоговор.Организация),,);   
				КонецПопытки; 
			Иначе
				
				ОтменитьТранзакцию();
				
				НеЗаполненныеРеквизиты = Новый Массив;
				
				Если Не ЗначениеЗаполнено(ДокументОбъект.Контрагент) Тогда
					НеЗаполненныеРеквизиты.Добавить("Контрагент"); 
				КонецЕсли;
				
				Если Не ЗначениеЗаполнено(ДокументОбъект.Договор)Тогда
					НеЗаполненныеРеквизиты.Добавить("Договор");  
				КонецЕсли;
				
				Если Не ЗначениеЗаполнено(ДокументОбъект.Организация) Тогда
					НеЗаполненныеРеквизиты.Добавить("Организация"); 
				КонецЕсли;  
				
				Если Не ЗначениеЗаполнено(ДокументОбъект.Услуги) Тогда
					НеЗаполненныеРеквизиты.Добавить("Таблица Услуги"); 
				КонецЕсли; 
				
				Структура.Вставить("ДокументСсылка",);        
				Структура.Вставить("Контрагент",СтрокаДоговор.Контрагент); 
				Структура.Вставить("НеЗаполненныеРеквизиты", НеЗаполненныеРеквизиты);  
				МассивСозданныхДокументов.Добавить(Структура);
				
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = СтрШаблон("Не удалось создать документ для договора: %1 , контрагент: %2 . Не заполнены реквизиты: ", СтрокаДоговор.Договор, СтрокаДоговор.Контрагент);
				Сообщение.Сообщить();
				ЗаписьЖурналаРегистрации("ОБРАБОТКА: Массовое создание актов", УровеньЖурналаРегистрации.Ошибка, Метаданные.Обработки.ВКМ_МассовоеСозданиеАктов, СтрШаблон("Не удалось создать док. РеализацияТоваровУслуг для договора: %1, котрагент: %2, организация: %3.", СтрокаДоговор.Договор, СтрокаДоговор.Контрагент, СтрокаДоговор.Организация),,);   
				
			КонецЕсли; 
			
					
		КонецЦикла;
		
		Возврат МассивСозданныхДокументов;
	КонецФункции    
	  
	
	Функция ПолучитьТЗДоговорыИРеализации(Период);
		
		Запрос = Новый Запрос(); 
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ВКМ_ВыполненныеКлиентуРаботы.Договор КАК Договор,
		|	МАКСИМУМ(ВЫБОР
		|			КОГДА ТИПЗНАЧЕНИЯ(ВКМ_ВыполненныеКлиентуРаботы.Регистратор) = &Регистратор
		|					ИЛИ ВКМ_ВыполненныеКлиентуРаботы.Регистратор = НЕОПРЕДЕЛЕНО
		|				ТОГДА ВКМ_ВыполненныеКлиентуРаботы.Регистратор
		|		КОНЕЦ) КАК РеализацияТоваровИУслуг,
		|	ВКМ_ВыполненныеКлиентуРаботы.Клиент КАК Контрагент,
		|	&ОкончаниеПериода КАК ОкончаниеПериода,
		|	ВКМ_ВыполненныеКлиентуРаботы.Договор.Организация КАК Организация
		|ИЗ
		|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы КАК ВКМ_ВыполненныеКлиентуРаботы
		|ГДЕ
		|	ВКМ_ВыполненныеКлиентуРаботы.Период МЕЖДУ &НачалоПериода И &ОкончаниеПериода
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ВыполненныеКлиентуРаботы.Договор,
		|	ВКМ_ВыполненныеКлиентуРаботы.Клиент";
		
		Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(Период));  
		Запрос.УстановитьПараметр("ОкончаниеПериода", КонецМесяца(Период));
		Запрос.УстановитьПараметр("Регистратор", Тип("ДокументСсылка.РеализацияТоваровУслуг"));
		
		ТЗ_Данные = Запрос.Выполнить().Выгрузить();
		
		Возврат ТЗ_Данные  
		
	КонецФункции
	
	#КонецОбласти
	
#КонецЕсли


