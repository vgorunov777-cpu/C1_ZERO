# C1_ZERO

Проект для разработки на платформе 1С:Предприятие 8.3 с использованием Cursor IDE.

## Структура проекта

```
C1_ZERO/
├── .cursor/                  # Правила и конфигурации Cursor
│   ├── agents/               # 12 AI-агентов (developer, architect, tester, ...)
│   ├── rules/                # 15 правил разработки на 1С (.mdc)
│   ├── skills/               # 71 навык (64 из cc-1c-skills + 7 из cursor_rules_1c)
│   ├── commands/             # Команды (deploy_and_test, getconfigfiles)
│   ├── mcp.json              # MCP-серверы (локально, не в Git)
│   └── README.md             # Документация правил
├── Projects/                 # Проекты обработок и отчётов
├── docs/                     # Спецификации и руководства (34 документа)
├── scripts/                  # Скрипты автоматизации (switch.py и др.)
├── tests/                    # Тесты
├── .cursorrules              # Глобальные правила Cursor
└── README.md                 # Этот файл
```

## Правила и агенты Cursor

Правила разработки взяты из репозитория [cursor_rules_1c](https://github.com/vgorunov777-cpu/cursor_rules_1c) (форк [comol/cursor_rules_1c](https://github.com/comol/cursor_rules_1c)).

Полная документация по правилам, агентам и MCP-инструментам: [.cursor/README.md](.cursor/README.md).

## Навыки (Skills)

Навыки из двух репозиториев объединены в `.cursor/skills/`:

### cursor_rules_1c — диспетчерский навык и утилиты

| Навык | Описание |
|---|---|
| `1c-metadata-manage` | Диспетчерский навык: 17 доменов, 30+ PowerShell-инструментов |
| `img-grid-analysis` | Наложение сетки на изображение для анализа пропорций |
| `mermaid-diagrams` | Создание Mermaid-диаграмм |
| `powershell-windows` | Правила работы с PowerShell на Windows |

### cc-1c-skills — 64 специализированных навыка

Из репозитория [cc-1c-skills](https://github.com/vgorunov777-cpu/cc-1c-skills) (форк [Nikolay-Shirokov/cc-1c-skills](https://github.com/Nikolay-Shirokov/cc-1c-skills)):

| Группа | Навыки | Описание |
|---|---|---|
| EPF (7) | `epf-init`, `epf-add-form`, `epf-build`, `epf-dump`, `epf-validate`, `epf-bsp-init`, `epf-bsp-add-command` | Внешние обработки |
| ERF (4) | `erf-init`, `erf-build`, `erf-dump`, `erf-validate` | Внешние отчёты |
| MXL (4) | `mxl-info`, `mxl-validate`, `mxl-compile`, `mxl-decompile` | Табличные документы |
| Form (6) | `form-info`, `form-compile`, `form-validate`, `form-edit`, `form-patterns`, `form-add` | Управляемые формы |
| Role (3) | `role-info`, `role-compile`, `role-validate` | Роли и права |
| SKD (4) | `skd-info`, `skd-compile`, `skd-edit`, `skd-validate` | Схемы компоновки |
| Meta (5) | `meta-info`, `meta-compile`, `meta-edit`, `meta-remove`, `meta-validate` | Метаданные (23 типа) |
| CF (4) | `cf-info`, `cf-init`, `cf-edit`, `cf-validate` | Конфигурация |
| CFE (5) | `cfe-init`, `cfe-borrow`, `cfe-patch-method`, `cfe-validate`, `cfe-diff` | Расширения |
| Subsystem (4) | `subsystem-info`, `subsystem-compile`, `subsystem-edit`, `subsystem-validate` | Подсистемы |
| Interface (2) | `interface-edit`, `interface-validate` | Командный интерфейс |
| DB (9) | `db-list`, `db-create`, `db-dump-cf`, `db-load-cf`, `db-dump-xml`, `db-load-xml`, `db-update`, `db-run`, `db-load-git` | Базы данных |
| Web (4) | `web-publish`, `web-info`, `web-stop`, `web-unpublish` | Веб-публикация |
| Web Test (1) | `web-test` | Тестирование через веб-клиент |
| Утилиты (2) | `img-grid`, `template-add/remove`, `help-add`, `form-remove` | Универсальные операции |

Документация по навыкам: [docs/](docs/) — гайды, спецификации, DSL.

## MCP-серверы

Для работы AI-агентов требуются MCP-серверы. Настройки хранятся локально в `.cursor/mcp.json` (не коммитируются).

## Лицензия

MIT
