# C1_ZERO

Проект для разработки на платформе 1С:Предприятие 8.3 с использованием Cursor IDE.

## Структура проекта

```
C1_ZERO/
├── .cursor/                  # Правила и конфигурации Cursor
│   ├── agents/               # AI-агенты (developer, architect, tester, ...)
│   ├── rules/                # Правила разработки на 1С (.mdc)
│   ├── skills/               # Навыки (1c-metadata-manage, mermaid, ...)
│   ├── commands/             # Команды (deploy_and_test, getconfigfiles)
│   ├── mcp.json              # MCP-серверы (локально, не в Git)
│   └── README.md             # Документация правил
├── Projects/                 # Проекты обработок и отчётов
├── docs/                     # Документация
├── scripts/                  # Скрипты автоматизации
├── tests/                    # Тесты
├── .cursorrules              # Глобальные правила Cursor
└── README.md                 # Этот файл
```

## Правила Cursor

Правила разработки взяты из репозитория [cursor_rules_1c](https://github.com/vgorunov777-cpu/cursor_rules_1c) (форк [comol/cursor_rules_1c](https://github.com/comol/cursor_rules_1c)).

Полная документация по правилам, агентам, навыкам и MCP-инструментам находится в [.cursor/README.md](.cursor/README.md).

## MCP-серверы

Для работы AI-агентов требуются MCP-серверы. Настройки хранятся локально в `.cursor/mcp.json` (не коммитируются). См. [.dev.env.example](https://github.com/vgorunov777-cpu/cursor_rules_1c) для примера конфигурации.

## Лицензия

MIT
