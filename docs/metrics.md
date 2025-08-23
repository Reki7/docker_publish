# 📊 Метрики приложения

Этот документ описывает все метрики, экспортируемые через `prom-client` в `/metrics`.

---

## 🧱 Стандартные метрики (`prom-client`)

### `nodejs_eventloop_lag_seconds`

- **Тип**: Gauge
- **Описание**: Задержка event loop в секундах.
- **Пример алерта**: > 0.1s — предупреждение.

### `nodejs_heap_size_total_bytes`

- **Тип**: Gauge
- **Описание**: Общий объём heap-памяти.

### `nodejs_heap_space_size_used_bytes`

- **Тип**: Gauge
- **Описание**: Используемая память по областям (new, old, etc.).

### `nodejs_active_handles`

- **Тип**: Gauge
- **Описание**: Количество активных handles (таймеры, сокеты и т.д.).

### `nodejs_active_requests`

- **Тип**: Gauge
- **Описание**: Количество активных запросов (например, HTTP).

---

## 🧠 Процессные метрики

### `process_cpu_usage`

- **Тип**: Gauge
- **Описание**: CPU usage процесса (относительное значение).

### `process_resident_memory_bytes`

- **Тип**: Gauge
- **Описание**: Физическая память, используемая процессом.

### `process_virtual_memory_bytes`

- **Тип**: Gauge
- **Описание**: Виртуальная память.

### `process_uptime_seconds`

- **Тип**: Gauge
- **Описание**: Время работы процесса в секундах.

---

## 🔧 Кастомные метрики

### `app_uptime_seconds`

- **Тип**: Gauge
- **Описание**: Аптайм приложения (от старта сервера).
- **Использование**: Мониторинг стабильности.

### `app_info`

- **Тип**: Gauge
- **Описание**: Информационная метрика с лейблами.
- **Лейблы**:
  - `version` — версия из `package.json`
  - `node_env` — окружение (`production`, `development`)
- **Значение**: `1` (флаг активности).

---

## 📈 HTTP Метрики (если добавлены)

### `http_requests_total`

- **Тип**: Counter
- **Описание**: Общее число HTTP-запросов.
- **Лейблы**:
  - `method` — `GET`, `POST`
  - `path` — URL пути
  - `status` — HTTP статус

---

## 📣 Алерты

| Алерт | Условие | Severity |
|------|--------|----------|
| `HighEventLoopLag` | `> 0.1s` | warning |
| `AppDown` | `up == 0` | critical |
| `HighMemoryUsage` | `> 80%` | warning |

---

> 💡 Подсказка: используй `rate(http_requests_total[1m])` для RPS.
