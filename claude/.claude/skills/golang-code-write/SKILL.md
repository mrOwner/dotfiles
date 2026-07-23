---
name: golang-code-write
description: Use when writing, editing, or reviewing Go code (.go files) — enforces personal Go conventions for fx-modules, hot/cold path discipline, sentinel errors (errcodes), naming (lgr/cfg/ctx/ds), type-blocks, defer policy, performance reflexes (sync.Pool, atomic_ring, fasthttp, sonic, jsonparser), pkg/util helpers, comment style, and forbidden patterns (no encoding/json/net/http on hot path, no fmt.Errorf in logic, no sleep for sync).
---

## Структура пакета

Каждый «модуль» (fx-модуль) — отдельный пакет с типовым набором файлов:

```
pkg/
  cfg.go            // Config + grouped types, env+yaml теги
  ds.go             // data structures (request/response/DTO/internal)
  deps.go           // interfaces в месте использования + //go:generate mockgen + var _ I = (*T)(nil)
  module.go         // fx.Module(...)
  <name>.go         // основной тип (Client/Engine/Window) + New + Start/Stop
  <feature>.go      // расщеплённая логика (orders.go, signer.go, ...)
  <name>_test.go    // unit + table-driven
  integration_test.go // отдельный, под env/build-tag
  mocks_test.go     // сгенерённые mockgen
```

## type-блоки

Всегда группируем декларации в `type ( ... )` — даже одиночные:

```go
type (
    Client struct { ... }

    liveCreds struct { ... }
)
```

## cfg.go

- Корневой `Config` оборачивает sub-config: `Polymarket PolymarketConfig \`yaml:"polymarket"\``.
- Теги: `env:"..."`, `env-default:"..."` / `env-required:"true"`, `yaml:"..."`.
- Длинные строки гасим `//nolint:lll` если нельзя иначе.
- Геттеры-обёртки (`func (c *Config) URL() string`) если нужно скрыть путь.
- Используй скилл `golang-samber-lo`

## module.go

```go
const (
    moduleName = "rest_polymarket_clob"
)

func Module(path string) fx.Option {
    return fx.Module(
        moduleName,
        fx.Provide(
            cfg.NewConfig[Config](path),
            New,
        ),
        fx.Decorate(decorator.WithLoggerComponent(moduleName)),
        fx.Invoke(func(lc fx.Lifecycle, c *Client) {
            lc.Append(fx.Hook{OnStart: c.Start, OnStop: c.Stop})
        }),
    )
}
```

## Start/Stop (fx-хуки)

- Передаваемый ctx **игнорируем** (`_ context.Context`) — он короткоживущий (startup/shutdown).
- Долгоживущий контекст: `ctx, c.cancel = context.WithCancel(context.Background())`.
- `started bool` guard, возврат `errcodes.ErrAlreadyStarted`.
- `Stop` — idempotent: `if !c.started { return nil }`.
- Логируем фактом: `c.lgr.Info().Msg("X has started" / "X has stopped")`.
- Фоновые горутины запускаем `//nolint:contextcheck`.

## Ошибки (pkg/errcodes)

- **Только sentinel-ошибки**, регистрируются глобально `New("...")` в `errocodes.go`.
- Никаких динамических `fmt.Errorf("...: %w", err)` в логике — оборачиваем через sentinel:
  - `errcodes.ErrFoo.With(err)` → `"foo: <err>"`
  - `errcodes.ErrFoo.WithMsg(msg)` → `"foo: <msg>"` (статичный класс, динамическая деталь)
- Исключения помечаем `// ponytail: ...`. Пример из client.go:

  ```go
  return fmt.Errorf("http %d: %s", code, resp.Body()) // ponytail: 2 dyn args, exception
  ```

## Interfaces (deps.go)

```go
//go:generate mockgen -destination=mocks_test.go -package=window_test -source=deps.go

type (
    Feeder interface {
        Subscribe(key string, p ds.Product) <-chan struct{}
        Unsubscribe(key string)
        Read(p ds.Product) ds.VolSnaps
    }
    OB interface { ... }
)

var (
    _ Feeder = (*ds.Feed)(nil)
    _ OB     = (*market.Client)(nil)
)
```

Маленькие интерфейсы (1-4 метода), объявлены **в месте использования**.

## Параметры конструктора

- Plain struct → `windowsParam`
- fx-injection → `engineParam struct { fx.In; ... }` с тегами `\`name:"..."\``
- Названия полей — lowercase (`lgr`, `cfg`, `feeder`).

## Naming

- Receiver: одна буква (`c`, `w`, `e`, `s`).
- Logger — всегда `lgr` (не `logger`, не `log`).
- Config — `cfg`.
- Контекстная переменная — `ctx`.
- Пакеты с DTO — `ds`.
- Sentinel errors — `ErrXxx` в `pkg/errcodes`.
- Константы путей/полей — кучка `const (...)` сверху файла (`pathOrder`, `OrderTypeFAK`, ...).

## Hot path определение

Hot path — это поток событий от driver'а до результата стратегии:

```
ws OB / ws coinbase / ws binance (driver)
  → feed/window (агрегация snapshot'а)
  → strategy (decide)
  → order builder
  → rest clob (POST /order)
  → order pool (state)
  → ws user (ack/fill)
  → strategy (react)
```

На этом пути максимум скорость, минимум аллокаций. Всё, что можно
переиспользовать — переиспользуется (pool, ring, pre-allocated buf).
В хипе аллоцировать только если другого выхода нет.

Cold path — startup, refresh creds, config, отчёты, batch-recalculation,
admin/health endpoints. Здесь читаемость > наносекунды.

При сомнениях — функция на hot-path? Спроси: «вызывается ли она от
ws-тика?». Если да — hot. Если только из Start/Stop/refresh — cold.

## Defer policy

- **Hot path: defer избегать.** Накладные ~50–150ns + блокирует inline
  - усложняет escape analysis. Освобождай ресурсы явно в конце функции
    и на ошибочных ветках.
- **Cold path: defer предпочтителен.** Читаемость и cleanup-safety важнее
  наносекунд (Start/Stop, refresh creds, signer init, тесты).
- Исключения на hot-path помечать `// ponytail: defer ok, ...`.

Пример hot-path без defer:

```go
req := fasthttp.AcquireRequest()
resp := fasthttp.AcquireResponse()

if err := c.do(ctx, req, resp); err != nil {
    fasthttp.ReleaseRequest(req)
    fasthttp.ReleaseResponse(resp)

    return err
}

// ... use resp ...

fasthttp.ReleaseRequest(req)
fasthttp.ReleaseResponse(resp)
```

В cold-path тот же код пишется с `defer` — так читабельнее.

## Performance reflexes (hot path)

- **Reuse first.** Прежде чем аллоцировать — есть ли pool/ring/буфер
  уже под рукой? sync.Pool, atomic_ring, pre-allocated slice — приоритет.
- **`sync.Pool`** для горячих буферов (HMAC-Hash pre-keyed, encode-buffer,
  fasthttp req/resp). Положи в pool готовый-к-использованию объект.
- **`pkg/atomic_ring.Pointer[T]`** — single-writer multi-reader publish
  snapshot'а с **нулевыми аллокациями** на Write. Используй везде, где
  идёт частая публикация маленького snapshot'а (BestBidAsk per market,
  PriceTick, любые per-product `T`).  
  `atomic.Pointer[T].Store(&v)` — alloc на каждый Store (v escape'ит в
  heap). Применяем только для **редко** меняющегося immutable bundle
  (creds, конфиг-snapshot).
- **AtomicFloat64 = `atomic.Uint64` + `math.Float64bits` bitcast.** Это
  uber-go/atomic style: 0 alloc, поддерживает Add через CAS-loop.
  Не используй `atomic.Value` (interface boxing + type-assert) и
  `atomic.Pointer[float64]` (alloc на Store).
- **HTTP — `valyala/fasthttp`** (`AcquireRequest`/`ReleaseRequest`),
  без client-level Read/WriteTimeout, дедлайн только из ctx.
- **JSON в struct — `bytedance/sonic`**.
- **JSON-роутинг по типу события** (event_type / type) — `buger/jsonparser`
  `EachKey` за один проход, без аллокаций.
- **Decode quoted-int** (`"1779393446409"`) — `data[1:len(data)-1]` +
  `strconv.ParseInt`, не Unmarshal.
- **Числа** — `float64` + `valyala/fastjson/fastfloat.Parse` для строк
  из JSON. Decimal-либ на hot-path нет. Decimals разрешены только в
  отчётности / PNL / settlement.
- **WS-подписки** — собирать вручную `strings.Builder` с `Grow(cap)`,
  без `json.Marshal`.
- **string ↔ []byte** — `pkg/util.UnsafeBytes` / `pkg/util.UnsafeString`
  (zero-copy). Только для read-only consumer'ов: запись по `[]byte`
  от string — UB.
- **Малые буферы на стеке**: `var sumBuf [sha256.Size]byte; sum := h.Sum(sumBuf[:0])`.
- **Hex/base64 без `fmt`**: ручной `hex.Encode(out[2:], sig)`.
- **Single-writer-per-slot** — без мьютексов на писательском пути.
- **`for b.Loop()`** в бенчмарках (Go 1.24+), не `for i := 0; i < b.N; i++`.
  `b.ReportAllocs()` + `b.SetBytes(...)` где меряем throughput.
- Горячая функция несёт ремарку: `// Hot path: ...` / `// ≤44 bytes escapes`.

## pkg/util (использовать вместо самописа)

- **`util.UnsafeBytes(s) []byte`** / **`util.UnsafeString(b) string`** —
  zero-copy конверсия (read-only consumer). Везде, где `[]byte(s)` /
  `string(b)` идёт в API, который не пишет.
- **`util.LowerASCII(s) string`** — без аллокации если `s` уже lower.
  Для биржевых тикеров (всегда ASCII).
- **`util.Remove[E](s, v) (S, bool)`** / **`util.RemoveAt[E](s, i) S`** —
  swap-with-last, O(1), зануляет слот для GC. Используй вместо
  `slices.Delete` где порядок не важен.

## Bench-derived rules (`bench/` — справочник, не выкидывать)

`bench/` собирает все альтернативы по hot-path-критичным операциям.
Перед тем как тянуть новую либу — посмотри, нет ли там бенча, и какой
победитель уже выбран. Текущие выводы:

| Задача                           | Победитель                           | Почему                              |
| -------------------------------- | ------------------------------------ | ----------------------------------- |
| JSON unmarshal в struct          | `bytedance/sonic`                    | JIT-кодеген, без reflect в hot path |
| JSON роутинг по 2-3 ключам       | `buger/jsonparser` + `EachKey`       | один проход буфера, 0 alloc         |
| Quoted JSON int → int64          | `data[1:len-1]` + `strconv.ParseInt` | без Unmarshal-обёртки               |
| Float parse из JSON-строки       | `valyala/fastjson/fastfloat.Parse`   | быстрее strconv, без alloc          |
| WS-клиент (Polymarket)           | `lxzan/gws`                          | минимум alloc/op на стрим           |
| Atomic float64                   | `atomic.Uint64` + bitcast            | 0 alloc, Add через CAS-loop         |
| Snapshot publish (per-market)    | `pkg/atomic_ring.Pointer[T]`         | 0 alloc на Write                    |
| Immutable bundle, редкий refresh | `atomic.Pointer[T]` + COW            | новый ptr на Store — допустимо      |
| string → []byte (read-only)      | `unsafe.Slice(unsafe.StringData...)` | через `pkg/util.UnsafeBytes`        |
| Subscribe-payload build          | `strings.Builder` + `Grow(cap)`      | без `json.Marshal`                  |
| Decimal на hot-path              | **нет**                              | `float64` + fastfloat               |

## Комментарии

- Godoc — английский, одна строка перед экспортируемым символом.
- Внутренние объяснения «почему» — русский, развёрнутые блоки разрешены когда речь о тонкой механике (атомики, ownership, lifecycle, ракурс гонок).
- Алгоритмы / математика — package-level doc с TeX-стилем (см. `internal/formula/confidence.go`).
- Никаких комментариев «что делает строка кода». Только «почему».
- Ссылки на док API — комментом над методом: `// https://docs.polymarket.com/...`.
- Намеренное упрощение — `// ponytail: <ceil>, upgrade if <signal>`.

## nolint-директивы

Используем явно с причиной, или файлом сверху:

```go
//nolint:gochecknoglobals,lll
package clob
```

```go
var b64 = base64.URLEncoding //nolint:gochecknoglobals

httpC := &fasthttp.Client{ //nolint:exhaustruct
    ...
}
```

## fasthttp pattern

```go
req := fasthttp.AcquireRequest()
resp := fasthttp.AcquireResponse()

defer fasthttp.ReleaseRequest(req)
defer fasthttp.ReleaseResponse(resp)

req.Header.SetMethod(fasthttp.MethodPost)
req.SetRequestURI(c.url + path)
req.Header.Set("Accept", "application/json")
// ... auth headers ...

if err := c.do(ctx, req, resp); err != nil {
    return err
}
```

## Formatting reflexes

- Пустая строка между логическими группами (после `var (...)`, перед `for`, перед `if err != nil`).
- Early return, ранний guard вместо вложенности.
- Имена констант — `pathOrder`, `pathOrders`, не `OrderPath`.
- Stdlib first: `slices`, `cmp`, `errors.Join`, `wg.Go(...)` (Go 1.25+).
- `samber/lo` для коллекций (`lo.PartitionBy`), но не везде где можно стдлибом.

## Что НЕ делать

- Никаких generic interface{} wrappers / factories под одну реализацию.
- Никакого `encoding/json` на hot-path — `sonic`.
- Никакого `net/http` на hot-path — `fasthttp`.
- Никакой динамической ошибки на месте — добавь sentinel в `errcodes`.
- Никаких `log` / `fmt.Println` — только `zerolog` через `c.lgr`.
- Никаких `sleep` для синхронизации
- Не мутируй переданный `Config`. Не держи lock через сетевой вызов.
