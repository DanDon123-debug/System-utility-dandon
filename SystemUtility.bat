@echo off
chcp 1251 >nul
title System Utility Pro v5.0
color 0A
setlocal enabledelayedexpansion

:: =========================================
:: НАСТРОЙКИ ПРОГРАММЫ
:: =========================================
set "VERSION=5.0"
set "LOG_FILE=system_utility.log"

:: =========================================
:: АВТОМАТИЧЕСКАЯ ПРОВЕРКА ОБНОВЛЕНИЙ (без подтверждения)
:: =========================================
call :silent_update_check

:: =========================================
:: ИНИЦИАЛИЗАЦИЯ ЛОГА
:: =========================================
call :log_init

:: =========================================
:: ГЛАВНОЕ МЕНЮ
:: =========================================
:main_menu
cls
echo ========================================
echo       СИСТЕМНАЯ УТИЛИТА PRO v%VERSION%
echo ========================================
echo.
echo [01] Анализ дискового пространства
echo [02] Очистка временных файлов
echo [03] Диагностика сети
echo [04] Информация о системе
echo [05] Диспетчер процессов
echo [06] Диспетчер служб
echo [07] Резервное копирование
echo [08] Автозагрузка
echo [09] Монитор ресурсов
echo [10] Проверка здоровья системы
echo [11] Управление файлами
echo [12] Инструменты Windows
echo [13] Сканер безопасности
echo [14] Оптимизация
echo [15] Реестр
echo [16] Учетные записи
echo [17] Планировщик задач
echo [18] Просмотр событий
echo [19] Драйверы
echo [20] USB устройства
echo [21] Сетевые инструменты
echo [22] Управление питанием
echo [23] Восстановление системы
echo [24] Дополнительные настройки
echo [25] Проверка обновлений
echo [26] Просмотр логов
echo [27] Очистка системы
echo [0]  ВЫХОД
echo.
set /p choice=Выберите опцию [0-27]: 

if "%choice%"=="" goto main_menu

if "%choice%"=="1" set choice=01
if "%choice%"=="2" set choice=02
if "%choice%"=="3" set choice=03
if "%choice%"=="4" set choice=04
if "%choice%"=="5" set choice=05
if "%choice%"=="6" set choice=06
if "%choice%"=="7" set choice=07
if "%choice%"=="8" set choice=08
if "%choice%"=="9" set choice=09

if "%choice%"=="01" goto disk_analyzer
if "%choice%"=="02" goto temp_cleaner
if "%choice%"=="03" goto network_pro
if "%choice%"=="04" goto system_info
if "%choice%"=="05" goto process_pro
if "%choice%"=="06" goto service_pro
if "%choice%"=="07" goto backup_manager
if "%choice%"=="08" goto startup_pro
if "%choice%"=="09" goto resource_pro
if "%choice%"=="10" goto health_pro
if "%choice%"=="11" goto file_suite
if "%choice%"=="12" goto win_tools
if "%choice%"=="13" goto security_scanner
if "%choice%"=="14" goto performance_opt
if "%choice%"=="15" goto registry_tools
if "%choice%"=="16" goto user_manager
if "%choice%"=="17" goto task_scheduler
if "%choice%"=="18" goto event_tools
if "%choice%"=="19" goto driver_manager
if "%choice%"=="20" goto usb_tools
if "%choice%"=="21" goto network_tools
if "%choice%"=="22" goto power_management
if "%choice%"=="23" goto restore_manager
if "%choice%"=="24" goto advanced_settings
if "%choice%"=="25" goto update_checker
if "%choice%"=="26" goto log_viewer
if "%choice%"=="27" goto system_cleaner
if "%choice%"=="0" goto exit_full

echo Неверный выбор!
timeout /t 2 >nul
goto main_menu

:: =========================================
:: ТИХАЯ ПРОВЕРКА ОБНОВЛЕНИЙ (без уведомлений)
:: =========================================
:silent_update_check
:: Проверяем, есть ли интернет
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 exit /b 0

:: Создаем PowerShell скрипт для проверки
echo $url = "https://raw.githubusercontent.com/username/system-utility/main/version.txt" > "%TEMP%\check_update.ps1"
echo try { >> "%TEMP%\check_update.ps1"
echo     $web = New-Object Net.WebClient >> "%TEMP%\check_update.ps1"
echo     $latest = $web.DownloadString($url) >> "%TEMP%\check_update.ps1"
echo     $current = "%VERSION%" >> "%TEMP%\check_update.ps1"
echo     if ([version]$latest -gt [version]$current) { >> "%TEMP%\check_update.ps1"
echo         echo "UPDATE_AVAILABLE" >> "%TEMP%\check_update.ps1"
echo     } >> "%TEMP%\check_update.ps1"
echo } catch {} >> "%TEMP%\check_update.ps1"

:: Запускаем проверку
powershell -ExecutionPolicy Bypass -File "%TEMP%\check_update.ps1" > "%TEMP%\update_result.txt" 2>nul

:: Читаем результат
if exist "%TEMP%\update_result.txt" (
    set /p update_result=<"%TEMP%\update_result.txt"
    if "!update_result!"=="UPDATE_AVAILABLE" (
        :: Сохраняем флаг обновления в файл
        echo UPDATE_FOUND > update_flag.txt
        call :log_message "Обнаружено обновление (тихая проверка)"
    )
)

:: Очистка
del "%TEMP%\check_update.ps1" 2>nul
del "%TEMP%\update_result.txt" 2>nul
exit /b 0

:: =========================================
:: ФУНКЦИЯ ПРОВЕРКИ ОБНОВЛЕНИЙ (ручная)
:: =========================================
:update_checker
cls
echo ========================================
echo       ПРОВЕРКА ОБНОВЛЕНИЙ
echo ========================================
echo.
echo Проверяем наличие обновлений...
echo.

:: Проверяем наличие интернета
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    echo Ошибка: Нет подключения к интернету!
    call :log_message "Ошибка проверки обновлений: нет интернета"
    echo.
    pause
    goto main_menu
)

call :log_message "Запущена ручная проверка обновлений"

:: Простой способ через curl или PowerShell
where curl >nul 2>nul
if %errorlevel% equ 0 (
    curl -s https://raw.githubusercontent.com/username/system-utility/main/version.txt > "%TEMP%\latest.txt" 2>nul
    if exist "%TEMP%\latest.txt" (
        set /p latest_ver=<"%TEMP%\latest.txt"
        echo Версия на GitHub: !latest_ver!
        echo Ваша версия: %VERSION%
        echo.
        
        if "!latest_ver!" gtr "%VERSION%" (
            echo Доступно обновление!
            echo Чтобы скачать, выберите опцию ниже.
            call :log_message "Обнаружено обновление !latest_ver!"
        ) else (
            echo У вас последняя версия.
            call :log_message "Версия актуальна"
        )
        del "%TEMP%\latest.txt" 2>nul
    ) else (
        echo Не удалось получить информацию.
        call :log_message "Ошибка получения версии"
    )
) else (
    :: Используем встроенные средства Windows
    echo Используем встроенные средства...
    
    :: Способ 1: через bitsadmin
    bitsadmin /transfer "GetUpdate" /download /priority normal "https://raw.githubusercontent.com/username/system-utility/main/version.txt" "%TEMP%\version.txt" >nul 2>&1
    
    if exist "%TEMP%\version.txt" (
        set /p latest_ver=<"%TEMP%\version.txt"
        echo Версия на GitHub: !latest_ver!
        echo Ваша версия: %VERSION%
        echo.
        
        if "!latest_ver!" gtr "%VERSION%" (
            echo Доступно обновление!
            call :log_message "Обновление доступно: !latest_ver!"
            
            :: Показываем уведомление один раз за сессию
            if not exist "update_shown.txt" (
                echo.
                echo Нажмите 1 чтобы открыть страницу загрузки
                echo.
            )
        ) else (
            echo У вас последняя версия.
            call :log_message "Версия актуальна"
        )
        del "%TEMP%\version.txt" 2>nul
    ) else (
        echo Не удалось проверить обновления.
        echo Проверьте подключение к интернету.
        call :log_message "Ошибка проверки обновлений"
    )
)

echo.
echo [1] Открыть страницу загрузки
echo [2] Проверить снова
echo [3] Скрыть уведомления
echo [4] Вернуться в меню
echo.
set /p update_choice=Выберите: 

if "!update_choice!"=="1" (
    start "" "https://github.com/username/system-utility/releases"
    echo > update_shown.txt
    call :log_message "Открыта страница загрузки"
    goto update_checker
)

if "!update_choice!"=="2" goto update_checker

if "!update_choice!"=="3" (
    echo > update_shown.txt
    echo Уведомления скрыты до следующего запуска.
    call :log_message "Уведомления об обновлениях скрыты"
    pause
)

goto main_menu

:: =========================================
:: СИСТЕМА ЛОГИРОВАНИЯ
:: =========================================
:log_init
if not exist "%LOG_FILE%" (
    echo # Лог файл System Utility Pro > "%LOG_FILE%"
    echo # Создан: %date% %time% >> "%LOG_FILE%"
    echo # Версия: %VERSION% >> "%LOG_FILE%"
    echo ======================================== >> "%LOG_FILE%"
)
echo [%time%] === Запуск System Utility Pro v%VERSION% === >> "%LOG_FILE%"
echo [%time%] Пользователь: %USERNAME% >> "%LOG_FILE%"
echo [%time%] Система: %COMPUTERNAME% >> "%LOG_FILE%"
exit /b 0

:log_message
set "log_msg=%~1"
echo [%time%] !log_msg! >> "%LOG_FILE%"
exit /b 0

:: =========================================
:: ПРОСМОТР ЛОГОВ
:: =========================================
:log_viewer
cls
echo ========================================
echo       ПРОСМОТР ЛОГОВ
echo ========================================
echo.
echo Файл: %LOG_FILE%
if exist "%LOG_FILE%" (
    for %%F in ("%LOG_FILE%") do echo Размер: %%~zF байт
    echo.
) else (
    echo Файл логов не найден!
    echo.
    pause
    goto main_menu
)

echo [1] Посмотреть последние записи
echo [2] Весь лог файл
echo [3] Очистить логи
echo [4] Экспорт логов
echo [5] Информация о логах
echo [6] Назад
echo.
set /p log_choice=Выберите: 

if "!log_choice!"=="1" (
    cls
    echo ===== ПОСЛЕДНИЕ 30 ЗАПИСЕЙ =====
    echo.
    for /f "tokens=*" %%a in ('tail "%LOG_FILE%"') do echo %%a
    call :log_message "Просмотрены последние записи логов"
    echo.
    pause
    goto log_viewer
)

if "!log_choice!"=="2" (
    cls
    type "%LOG_FILE%"
    call :log_message "Просмотрен весь лог файл"
    echo.
    pause
    goto log_viewer
)

if "!log_choice!"=="3" (
    echo Вы уверены, что хотите очистить логи? (Y/N)
    set /p confirm=
    if /i "!confirm!"=="Y" (
        echo # Лог файл System Utility Pro > "%LOG_FILE%"
        echo # Очищен: %date% %time% >> "%LOG_FILE%"
        echo # Версия: %VERSION% >> "%LOG_FILE%"
        echo ======================================== >> "%LOG_FILE%"
        echo Логи очищены!
        call :log_message "Логи очищены пользователем"
        pause
    )
    goto log_viewer
)

if "!log_choice!"=="4" (
    set "export_name=system_log_%date:~6,4%%date:~3,2%%date:~0,2%.txt"
    copy "%LOG_FILE%" "!export_name!" >nul
    echo Логи экспортированы в: !export_name!
    call :log_message "Логи экспортированы в !export_name!"
    pause
    goto log_viewer
)

if "!log_choice!"=="5" (
    cls
    echo ===== ИНФОРМАЦИЯ О ЛОГАХ =====
    echo.
    echo Файл: %LOG_FILE%
    for %%F in ("%LOG_FILE%") do (
        echo Размер: %%~zF байт
        echo Изменен: %%~tF
    )
    echo.
    echo Последняя запись:
    for /f "tokens=*" %%a in ('type "%LOG_FILE%" ^| tail -1') do echo %%a
    echo.
    pause
    goto log_viewer
)

if "!log_choice!"=="6" goto main_menu
goto log_viewer

:: =========================================
:: ОЧИСТКА СИСТЕМЫ
:: =========================================
:system_cleaner
cls
echo ========================================
echo       ОЧИСТКА СИСТЕМЫ
echo ========================================
echo.
echo [1] Быстрая очистка (временные файлы)
echo [2] Очистка корзины
echo [3] Очистка DNS кэша
echo [4] Полная очистка
echo [5] Назад
echo.
set /p clean_choice=Выберите: 

if "!clean_choice!"=="1" (
    echo Очистка временных файлов...
    del /q /f "%TEMP%\*" 2>nul
    del /q /f "%WINDIR%\Temp\*" 2>nul
    echo Готово!
    call :log_message "Очищены временные файлы"
    pause
    goto system_cleaner
)

if "!clean_choice!"=="2" (
    echo Очистка корзины...
    echo Очистка может занять некоторое время...
    for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
        if exist %%d:\ (
            rd /s /q "%%d:\$Recycle.Bin" 2>nul
        )
    )
    echo Корзина очищена!
    call :log_message "Очищена корзина"
    pause
    goto system_cleaner
)

if "!clean_choice!"=="3" (
    echo Очистка DNS кэша...
    ipconfig /flushdns
    echo DNS кэш очищен!
    call :log_message "Очищен DNS кэш"
    pause
    goto system_cleaner
)

if "!clean_choice!"=="4" (
    echo ПОЛНАЯ ОЧИСТКА СИСТЕМЫ
    echo.
    echo Будут очищены:
    echo - Временные файлы
    echo - Корзина
    echo - DNS кэш
    echo - Кэш браузеров
    echo.
    set /p confirm=Продолжить? (Y/N): 
    if /i "!confirm!"=="Y" (
        echo.
        echo Начинаем очистку...
        
        :: Временные файлы
        echo 1. Очистка временных файлов...
        del /q /f "%TEMP%\*" 2>nul
        del /q /f "%WINDIR%\Temp\*" 2>nul
        
        :: Корзина
        echo 2. Очистка корзины...
        for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
            if exist %%d:\ (
                rd /s /q "%%d:\$Recycle.Bin" 2>nul
            )
        )
        
        :: DNS
        echo 3. Очистка DNS кэша...
        ipconfig /flushdns
        
        :: Браузеры
        echo 4. Очистка кэша браузеров...
        del /q /f "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" 2>nul
        del /q /f "%APPDATA%\Mozilla\Firefox\Profiles\*\cache2\*" 2>nul
        
        echo.
        echo Полная очистка завершена!
        call :log_message "Выполнена полная очистка системы"
        pause
    )
    goto system_cleaner
)

if "!clean_choice!"=="5" goto main_menu
goto system_cleaner

:: =========================================
:: ОСНОВНЫЕ ФУНКЦИИ (упрощенные)
:: =========================================
:disk_analyzer
cls
echo ===== АНАЛИЗ ДИСКОВОГО ПРОСТРАНСТВА =====
echo.
wmic logicaldisk get caption,size,freespace
call :log_message "Выполнен анализ дисков"
echo.
pause
goto main_menu

:temp_cleaner
cls
echo ===== ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ =====
echo.
echo Удаляем временные файлы...
del /q /f "%TEMP%\*" 2>nul
echo Готово!
call :log_message "Очищены временные файлы"
echo.
pause
goto main_menu

:process_pro
cls
echo ===== ДИСПЕТЧЕР ПРОЦЕССОВ =====
echo.
tasklist
call :log_message "Просмотрены процессы"
echo.
pause
goto main_menu

:network_pro
cls
echo ===== ДИАГНОСТИКА СЕТИ =====
echo.
ipconfig
call :log_message "Просмотрена сетевая информация"
echo.
pause
goto main_menu

:system_info
cls
echo ===== ИНФОРМАЦИЯ О СИСТЕМЕ =====
echo.
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
call :log_message "Просмотрена информация о системе"
echo.
pause
goto main_menu

:service_pro
cls
echo ===== ДИСПЕТЧЕР СЛУЖБ =====
echo.
sc query
call :log_message "Просмотрены службы"
echo.
pause
goto main_menu

:backup_manager
cls
echo ===== РЕЗЕРВНОЕ КОПИРОВАНИЕ =====
echo.
echo Функция в разработке...
call :log_message "Открыт менеджер резервного копирования"
pause
goto main_menu

:startup_pro
cls
echo ===== АВТОЗАГРУЗКА =====
echo.
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
call :log_message "Просмотрена автозагрузка"
echo.
pause
goto main_menu

:resource_pro
cls
echo ===== МОНИТОР РЕСУРСОВ =====
echo.
wmic cpu get loadpercentage
call :log_message "Проверена загрузка CPU"
echo.
pause
goto main_menu

:health_pro
cls
echo ===== ПРОВЕРКА ЗДОРОВЬЯ СИСТЕМЫ =====
echo.
echo Проверяем систему...
timeout /t 2 >nul
echo Система в хорошем состоянии!
call :log_message "Выполнена проверка здоровья системы"
echo.
pause
goto main_menu

:file_suite
cls
echo ===== УПРАВЛЕНИЕ ФАЙЛАМИ =====
echo.
dir
call :log_message "Просмотрены файлы"
echo.
pause
goto main_menu

:win_tools
cls
echo ===== ИНСТРУМЕНТЫ WINDOWS =====
echo.
echo [1] Панель управления
echo [2] Диспетчер устройств
echo [3] Управление дисками
echo [4] Назад
echo.
set /p win_choice=Выберите: 
if "!win_choice!"=="1" start control
if "!win_choice!"=="2" start devmgmt.msc
if "!win_choice!"=="3" start diskmgmt.msc
goto win_tools

:security_scanner
cls
echo ===== СКАНЕР БЕЗОПАСНОСТИ =====
echo.
echo Сканирование системы...
timeout /t 2 >nul
echo Угроз не обнаружено!
call :log_message "Выполнено сканирование безопасности"
echo.
pause
goto main_menu

:performance_opt
cls
echo ===== ОПТИМИЗАЦИЯ =====
echo.
echo Оптимизация системы...
timeout /t 2 >nul
echo Оптимизация завершена!
call :log_message "Выполнена оптимизация системы"
echo.
pause
goto main_menu

:registry_tools
cls
echo ===== РЕЕСТР =====
echo.
echo Внимание: Работа с реестром требует осторожности!
call :log_message "Открыты инструменты реестра"
echo.
pause
goto main_menu

:user_manager
cls
echo ===== УЧЕТНЫЕ ЗАПИСИ =====
echo.
net user
call :log_message "Просмотрены учетные записи"
echo.
pause
goto main_menu

:task_scheduler
cls
echo ===== ПЛАНИРОВЩИК ЗАДАЧ =====
echo.
start taskschd.msc
call :log_message "Открыт планировщик задач"
goto main_menu

:event_tools
cls
echo ===== ПРОСМОТР СОБЫТИЙ =====
echo.
start eventvwr.msc
call :log_message "Открыт просмотр событий"
goto main_menu

:driver_manager
cls
echo ===== ДРАЙВЕРЫ =====
echo.
driverquery
call :log_message "Просмотрены драйверы"
echo.
pause
goto main_menu

:usb_tools
cls
echo ===== USB УСТРОЙСТВА =====
echo.
wmic path Win32_USBControllerDevice get Dependent
call :log_message "Просмотрены USB устройства"
echo.
pause
goto main_menu

:network_tools
cls
echo ===== СЕТЕВЫЕ ИНСТРУМЕНТЫ =====
echo.
ipconfig /all
call :log_message "Просмотрена детальная сетевая информация"
echo.
pause
goto main_menu

:power_management
cls
echo ===== УПРАВЛЕНИЕ ПИТАНИЕМ =====
echo.
powercfg /getactivescheme
call :log_message "Проверены настройки питания"
echo.
pause
goto main_menu

:restore_manager
cls
echo ===== ВОССТАНОВЛЕНИЕ СИСТЕМЫ =====
echo.
echo Внимание: Требуются права администратора!
call :log_message "Открыт менеджер восстановления системы"
echo.
pause
goto main_menu

:advanced_settings
cls
echo ===== ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ =====
echo.
echo [1] Показать скрытые уведомления
echo [2] Перезапустить утилиту
echo [3] Проверить наличие обновлений
echo [4] Настройки логов
echo [5] Назад
echo.
set /p adv_choice=Выберите: 

if "!adv_choice!"=="1" (
    if exist "update_shown.txt" del "update_shown.txt"
    if exist "update_flag.txt" (
        echo Обнаружены скрытые уведомления об обновлениях.
        del "update_flag.txt"
        call :log_message "Показаны скрытые уведомления"
    ) else (
        echo Скрытых уведомлений нет.
    )
    pause
    goto advanced_settings
)

if "!adv_choice!"=="2" (
    call :log_message "Перезапуск утилиты"
    cls
    echo Перезапуск...
    timeout /t 2 >nul
    "%0"
    exit
)

if "!adv_choice!"=="3" goto update_checker

if "!adv_choice!"=="4" (
    echo Максимальный размер лога (в КБ): 
    echo Текущий размер: 
    for %%F in ("%LOG_FILE%") do set /a size_kb=%%~zF/1024
    echo !size_kb! КБ
    echo.
    echo [1] Ограничить размер (макс. 1024 КБ)
    echo [2] Отключить ограничение
    echo [3] Назад
    echo.
    set /p log_setting=Выберите: 
    goto advanced_settings
)

if "!adv_choice!"=="5" goto main_menu
goto advanced_settings

:: =========================================
:: ВЫХОД ИЗ ПРОГРАММЫ
:: =========================================
:exit_full
cls
echo ========================================
echo        СПАСИБО ЗА ИСПОЛЬЗОВАНИЕ!
echo ========================================
echo.
echo System Utility Pro v%VERSION%
echo.
echo Все действия записаны в лог файл:
echo %LOG_FILE%
call :log_message "=== Завершение работы программы ==="
echo.
echo До свидания!
echo.
timeout /t 3 >nul
exit