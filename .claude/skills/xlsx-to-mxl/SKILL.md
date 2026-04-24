---
name: xlsx-to-mxl
description: Конвертация XLSX в Template.xml или MXL через MCP HTTP-сервис 1С. Используй когда есть готовый Excel-макет печатной формы и нужно получить Template.xml или MXL
argument-hint: <XlsxPath> [OutputPath] [-Format xml|mxl]
allowed-tools:
  - Bash
  - Read
  - Glob
---

# /xlsx-to-mxl — Конвертация Excel в макет 1С

Конвертирует XLSX-файл в Template.xml (или MXL) через HTTP-сервис MCP 1С. Отправляет файл как base64, получает результат как base64 — быстро, без запуска 1С.

## Использование

```
/xlsx-to-mxl <XlsxPath> [OutputPath] [-Format xml|mxl]
```

## Параметры

| Параметр   | Обязательный | Описание                                                      |
|------------|:------------:|---------------------------------------------------------------|
| XlsxPath   | да           | Путь к исходному XLSX-файлу                                   |
| OutputPath | нет          | Куда положить результат (по умолчанию — Template.xml рядом)   |
| Format     | нет          | `xml` (по умолчанию) или `mxl`                                |

## Команда

```powershell
powershell.exe -NoProfile -File .claude/skills/xlsx-to-mxl/scripts/xlsx-to-mxl.ps1 -XlsxPath "<путь>.xlsx" [-OutputPath "<путь>/Template.xml"] [-Format xml]
```

## Что делает скрипт

1. Читает XLSX-файл и кодирует в base64
2. Отправляет JSON-RPC запрос `tools/call convert_file` на MCP-сервис 1С
3. Получает ответ с base64 результата (XML или MXL)
4. Декодирует и записывает файл

## Рабочий процесс для печатных форм

Типичный сценарий — есть готовый Excel с идеальным оформлением, нужно сделать из него макет печатной формы:

1. Claude вызывает `/xlsx-to-mxl` для конвертации XLSX → Template.xml
2. Claude копирует Template.xml в папку макета обработки (`Templates/ИмяМакета/Ext/Template.xml`)
3. Claude вызывает `/mxl-decompile` для получения JSON-определения
4. Claude модифицирует JSON: добавляет именованные области, заменяет хардкод на параметры `[ParamName]`
5. Claude вызывает `/mxl-compile` для генерации финального Template.xml
6. Claude вызывает `/mxl-validate` для проверки

## Альтернативный подход (без декомпиляции)

Если нужно только заменить текст на параметры без изменения структуры:

1. Claude вызывает `/xlsx-to-mxl` → получает Template.xml
2. Claude редактирует Template.xml напрямую (Edit tool): заменяет конкретные значения на `[ParamName]`
3. Claude добавляет именованную область в XML (атрибут `Name` у `Area`)
4. Claude копирует в макет обработки

## Требования

- MCP-сервис 1С должен быть запущен (http://server-1c:3080/work/hs/mcp/)
- Расширение MCP_Сервер с инструментом `convert_file` загружено в базу
