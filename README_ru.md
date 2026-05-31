# Clicker — счётчик нажатий для Garmin

*Read this in [English](README.md).*

Простое приложение для часов Garmin (Connect IQ / Monkey C), которое работает как
ручной счётчик-кликер: считает людей, предметы, повторения и т.п.

## Что умеет

- **+1** — нажатие на основную кнопку часов (START/SELECT) или тап по экрану на
  сенсорных моделях. Каждое нажатие сопровождается системным звуком часов
  (`Attention.TONE_KEY`).
- **Сброс на 0** — долгое нажатие кнопки меню (MENU / удержание UP) показывает
  диалог подтверждения; ответ «Yes» обнуляет счётчик.
- Текущее значение сохраняется в `Application.Storage`, поэтому не теряется при
  выходе из приложения или перезагрузке часов.

Управление: `onSelect` / `onTap` → +1, `onMenu` → сброс (см.
[`source/ClickerDelegate.mc`](source/ClickerDelegate.mc)).

## Структура проекта

```
manifest.xml                     описание приложения и список устройств
monkey.jungle                    конфигурация сборки
source/ClickerApp.mc             точка входа (AppBase)
source/ClickerView.mc            отрисовка счётчика + хранение значения
source/ClickerDelegate.mc        обработка кнопок/тапов, звук, сброс
resources/strings/strings.xml    строки (eng)
resources-rus/strings/...        строки (rus)
resources/drawables/...          иконка приложения
```

---

## 1. Подготовка окружения

1. Установите **Connect IQ SDK Manager**:
   <https://developer.garmin.com/connect-iq/sdk/>
   Через него скачайте последнюю версию SDK и образы устройств (Devices).
2. Установите **VS Code** и расширение **Monkey C** (издатель Garmin) — оно даёт
   команды сборки/запуска и подсветку синтаксиса.
3. Сгенерируйте **developer key** (одноразово), он нужен для подписи приложения:

   ```bash
   openssl genrsa -out developer_key.pem 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER \
       -in developer_key.pem -out developer_key -nocrypt
   ```

   Полученный файл `developer_key` указывайте в командах сборки (флаг `-y`).

Убедитесь, что инструменты SDK (`monkeyc`, `monkeydo`, `connectiq`) доступны в
`PATH` (SDK Manager обычно кладёт их в `~/.Garmin/ConnectIQ/Sdks/<версия>/bin`).

---

## 2. Запуск в эмуляторе

### Через VS Code (проще всего)

1. Откройте папку проекта в VS Code.
2. `Ctrl/Cmd + Shift + P` → **Monkey C: Build for Device** (выберите устройство,
   например `fenix7`) — расширение попросит указать developer key при первом
   запуске.
3. `Ctrl/Cmd + Shift + P` → **Monkey C: Run App** — соберёт проект, запустит
   симулятор и установит в него приложение. Нажмите `F5` для запуска с отладкой.

### Через командную строку

```bash
# 1. собрать .prg под конкретное устройство
monkeyc -d fenix7 -f monkey.jungle -o bin/clicker.prg -y developer_key

# 2. запустить симулятор (отдельное окно, оставьте работать)
connectiq

# 3. установить и запустить приложение в симуляторе
monkeydo bin/clicker.prg fenix7
```

В симуляторе кнопки эмулируются мышью/клавиатурой; для сенсорных устройств
работает клик по экрану. Меню симулятора (Simulation → ...) позволяет проверить
звук и поведение кнопок.

---

## 3. Установка на свои часы (sideload)

1. Соберите `.prg` под модель именно ваших часов (см. список id в
   [`manifest.xml`](manifest.xml)):

   ```bash
   monkeyc -d fenix7 -f monkey.jungle -o bin/clicker.prg -y developer_key
   ```

2. Подключите часы к компьютеру USB-кабелем — они смонтируются как накопитель
   (`GARMIN`).
3. Скопируйте `bin/clicker.prg` в папку **`GARMIN/APPS`** на часах
   (на некоторых моделях — `Garmin/Apps`).
4. Безопасно отключите часы. Приложение появится в списке Connect IQ приложений /
   активностей.

> Sideload подходит для личного тестирования. Приложение, собранное с вашим
> developer key, работает на ваших часах без публикации в магазине.

---

## 4. Публикация в Garmin Connect IQ Store

1. Соберите **package-файл `.iq`** (содержит сборки сразу под все устройства из
   манифеста):

   ```bash
   monkeyc -e -f monkey.jungle -o bin/clicker.iq -y developer_key
   ```

   В VS Code то же самое: **Monkey C: Export Project**.

2. Зарегистрируйте аккаунт разработчика и войдите в дашборд:
   <https://apps.garmin.com/developer/dashboard>
3. Нажмите **Upload an App**, загрузите `bin/clicker.iq`.
4. Заполните карточку приложения: название, описание, категория, скриншоты
   (можно снять в симуляторе), иконку магазина.
5. Отправьте на проверку. После одобрения Garmin приложение станет доступно
   пользователям в Connect IQ Store / приложении Garmin Connect.

### Полезное перед публикацией

- Проверьте, что в `manifest.xml` перечислены все устройства, которые хотите
  поддерживать, и что приложение собирается под каждое из них.
- Прогоните проверку типов: `monkeyc ... -l 3` (строгий type-check) помогает
  отловить ошибки до загрузки.
- Версию приложения Garmin берёт из загруженного `.iq`; обновление — повторная
  загрузка нового `.iq` в карточку.
