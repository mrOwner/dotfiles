---
name: writing-go-tests
description: "Use when writing or editing Go tests (*_test.go) in this user's projects — conventions for testify require/assert, table-driven tests with t.Run subtests (snake_case), go.uber.org/mock/gomock, google/go-cmp for large structs, gofakeit fakers, EventuallyWithT/synctest instead of sleep or channels, t.Context, t.Cleanup, ErrorAssertionFunc, testify/suite for per-case setup, fx.ValidateApp, carbon dates, proto pointer helpers. Apply whenever generating, refactoring, or reviewing Go test code."
user-invocable: true
---

# Writing Go Tests

Конвенции для тестов на Go в проектах этого пользователя. Держись их по умолчанию при написании и рефакторинге тестов.

## Quick Reference

| Ситуация                                 | Что использовать                                                                                                             |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Ассерты                                  | `require` (стоп при провале — предусловия, критичное) + `assert` (продолжить — накопить проверки). Использовать по максимуму |
| Разные входы → проверка ответа           | Table-driven: слайс тесткейсов со `struct { name; params; want; wantErr }`, цикл + `t.Run`                                   |
| Имена подтестов                          | `snake_case`                                                                                                                 |
| Группировка тестов / общий setup         | Один тест + подтесты `t.Run(...)`                                                                                            |
| Setup/teardown вокруг **каждого** кейса  | `github.com/stretchr/testify/suite`                                                                                          |
| Сравнение больших структур               | `github.com/google/go-cmp/cmp` + `cmpopts` (исключить ID/время/несущественное)                                               |
| Кейс проверяет и ошибку, и её отсутствие | `require.ErrorAssertionFunc` (`require.NoError` / `require.Error`)                                                           |
| Моки интерфейсов                         | `go.uber.org/mock/gomock`                                                                                                    |
| Ожидание (данные в БД и т.п.)            | `require.EventuallyWithT(...)` — **никаких** `time.Sleep` и каналов                                                          |
| Ускорение времени                        | `testing/synctest`                                                                                                           |
| Генерация значений                       | `github.com/brianvoe/gofakeit/v6`, faker создавать **отдельно** (не конкурентобезопасен)                                     |
| Контекст                                 | `t.Context()` вместо `context.Background()`                                                                                  |
| Указатель от значения                    | `google.golang.org/protobuf/proto` (`proto.String`, `proto.Int64`, `proto.Bool`, ...)                                        |
| Даты в тесткейсах                        | `github.com/dromara/carbon/v2`                                                                                               |
| Проверка fx-модуля                       | `require.NoError(t, fx.ValidateApp(Module))`                                                                                 |
| Обязательная очистка при любом исходе    | `t.Cleanup(...)` вместо `defer`                                                                                              |
| Повторяющийся код                        | DRY: выносить в функции/методы-хелперы с `t.Helper()`                                                                        |
| Всегда                                   | Проверять корнер-кейсы                                                                                                       |

## Каноничный table-driven тест

Объединяет большинство правил: слайс кейсов, `t.Run` со `snake_case`, `ErrorAssertionFunc`, gomock, `t.Context()`, отдельный faker, `go-cmp`.

```go
func TestService_CreateUser(t *testing.T) {
 faker := gofakeit.New(0) // отдельный инстанс — gofakeit не конкурентобезопасен

 type params struct {
  name string
  age  int
 }
 tests := []struct {
  name    string
  params  params
  setup   func(repo *mocks.MockRepo)
  want    *User
  wantErr require.ErrorAssertionFunc // и ошибка, и её отсутствие в одной таблице
 }{
  {
   name:   "ok",
   params: params{name: faker.Name(), age: 30},
   setup: func(repo *mocks.MockRepo) {
    repo.EXPECT().Save(gomock.Any(), gomock.Any()).Return(nil)
   },
   want:    &User{Name: "...", Age: 30},
   wantErr: require.NoError,
  },
  {
   name:    "negative_age", // корнер-кейс
   params:  params{name: faker.Name(), age: -1},
   setup:   func(repo *mocks.MockRepo) {}, // до репозитория не доходит
   want:    nil,
   wantErr: require.Error,
  },
 }

 for _, tt := range tests {
  t.Run(tt.name, func(t *testing.T) {
   ctrl := gomock.NewController(t) // ctrl.Finish вызовется через t.Cleanup сам
   repo := mocks.NewMockRepo(ctrl)
   tt.setup(repo)

   got, err := NewService(repo).CreateUser(t.Context(), tt.params.name, tt.params.age)

   tt.wantErr(t, err)
   // исключаем сгенерированные/временные поля
   if diff := cmp.Diff(tt.want, got, cmpopts.IgnoreFields(User{}, "ID", "CreatedAt")); diff != "" {
    t.Errorf("user mismatch (-want +got):\n%s", diff)
   }
  })
 }
}
```

## Точечные приёмы

**Ожидание без sleep/каналов** — например, появление записи в БД:

```go
require.EventuallyWithT(t, func(c *assert.CollectT) {
 got, err := repo.Get(t.Context(), id)
 require.NoError(c, err)
 assert.Equal(c, want, got)
}, 5*time.Second, 50*time.Millisecond)
```

**Ускорение времени** — фейковые часы, таймеры срабатывают мгновенно:

```go
synctest.Test(t, func(t *testing.T) {
 // таймеры/тикеры внутри идут по виртуальному времени
})
```

**Per-case setup/teardown → suite:**

```go
type UserSuite struct {
 suite.Suite
 db *DB
}
func (s *UserSuite) SetupTest()    { s.db = newDB(s.T()) }
func (s *UserSuite) TearDownTest() { s.db.Truncate() }
func TestUserSuite(t *testing.T)   { suite.Run(t, new(UserSuite)) }
```

**Хелперы (DRY) — всегда `t.Helper()`:**

```go
func newTestUser(t *testing.T, faker *gofakeit.Faker) *User {
 t.Helper()
 return &User{Name: faker.Name(), Age: faker.Number(18, 90)}
}
```

**Обязательная очистка при любом исходе:**

```go
srv := startServer(t)
t.Cleanup(srv.Close) // не defer — отработает даже при падении/панике теста
```

**Указатели и даты в тесткейсах:**

```go
Threshold: proto.Int64(100),               // *int64 без временной переменной
StartsAt:  carbon.Parse("2026-07-24").StdTime(),
```

**fx-модуль:**

```go
func TestModule(t *testing.T) {
 require.NoError(t, fx.ValidateApp(Module))
}
```

## Common Mistakes

- `time.Sleep` / ожидание через каналы → заменить на `require.EventuallyWithT` (или `synctest` для управляемого времени).
- `context.Background()` в тесте → `t.Context()`.
- `defer cleanup()` для того, что обязано выполниться → `t.Cleanup(cleanup)`.
- `reflect.DeepEqual` / ручное сравнение больших структур → `cmp.Diff` + `cmpopts`.
- Один общий `faker` на параллельные подтесты → отдельный faker на каждый (не конкурентобезопасен).
- Ручной указатель через промежуточную переменную (`v := int64(100); &v`) → `proto.Int64(100)`.
- Копипаста настройки в каждом тесте → хелпер с `t.Helper()` или `suite`.
- Отдельные `wantErr bool` + ветвление → `require.ErrorAssertionFunc`.
- Проверка только happy path → добавить корнер-кейсы (nil, пусто, границы, ошибки зависимостей).

```

```
