
&НаКлиенте
Процедура ВыполнитьКоманда(Команда)
	
	//РазрешитьОтгрузкуНаСервере("0101-139364_20", 2);
	Возврат;

	//Попытка
	//	COMcomApplication = new COMОбъект("AXSalesAllowShipmentService.AXServiceClass");
	//Исключение
	//	Сообщить("НЕ установлена компанента связи с АХ2012!");
	//	Возврат;
	//КонецПопытки;
	//
	////COMcomApplication.url = "net.tcp://nsk-aos12-14:8202/DynamicsAx/Services/KDVSalesAllowShipmentServiceGroup";
	//COMcomApplication.url = "net.tcp://nsk-aos12-13:8201/DynamicsAx/Services/KDVSalesAllowShipmentServiceGroup";
	//COMcomApplication.userName = "tsk_1C_Ax";
	//COMcomApplication.password = "Qwerty123!@#";
	//COMcomApplication.domain   = "kdvm";
	//
	//ТекстОшибки = COMcomApplication.updateNow("0101-139364_20", 2);
	//Сообщить(ТекстОшибки);

КонецПроцедуры

&НаКлиенте
Процедура РазрешитьОтгрузку(Команда)
	ТД = Элементы.СписокЗаказов.ТекущиеДанные;
	
	Если ТД <> Неопределено Тогда
    	РазрешитьОтгрузкуНаСервере(ТД.Номер + "_" + Формат(ТД.Дата, "ДФ=yy"), 1);
	КонецЕсли; 
КонецПроцедуры


&НаКлиенте
Процедура ЗапретитьОтгрузку(Команда)
	ТД = Элементы.СписокЗаказов.ТекущиеДанные;
	
	Если ТД <> Неопределено Тогда
    	РазрешитьОтгрузкуНаСервере(ТД.Номер + "_" + Формат(ТД.Дата, "ДФ=yy"), 2);
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Процедура РазрешитьОтгрузкуНаСервере(НомерДокумента, Отгрузка)
	Попытка
		COMcomApplication = new COMОбъект("AXSalesAllowShipmentService.AXServiceClass");
	Исключение
		Сообщить("НЕ установлена компанента связи с АХ2012!");
		Возврат;
	КонецПопытки;
	
	КодУзла = ВнешнийМодульРаботаСWebПолучениеДанных.ПолучитьКодТекущегоУзла();
	Если КодУзла = "000" Тогда
		//COMcomApplication.url = "net.tcp://nsk-aos12-13:8201/DynamicsAx/Services/KDVSalesAllowShipmentServiceGroup";
		COMcomApplication.url = "net.tcp://nsk-aos12-15:8201/DynamicsAx/Services/KDVSalesAllowShipmentServiceGroup";  //Толмачево2-Камелот.
	Иначе
		COMcomApplication.url = "net.tcp://msk-aos12-01:8201/DynamicsAx/Services/KDVSalesAllowShipmentServiceGroup";
	КонецЕсли; 
	
	COMcomApplication.userName = "tsk_1C_Ax";
	COMcomApplication.password = "Qwerty123!@#";
	COMcomApplication.domain   = "kdvm";
	
	ТекстОшибки = COMcomApplication.updateNow(НомерДокумента, Отгрузка);
	Если ПустаяСтрока(ТекстОшибки) Тогда
		Сообщить("Выполнено без ошибок!");
	Иначе
		Сообщить(ТекстОшибки);
		Сообщить("При выполнении возникла ошибка!");
	КонецЕсли; 
КонецПроцедуры
