# NOCTO Brand/Product Bible v1

Дата: 2026-05-05
Статус: активен продуктово-брандов source of truth
Repo: `/Users/mariozah-/Documents/New project/NOCTO_SAFE`

## 1. Цел

Този документ заключва NOCTO като продукт, бранд, интерфейс и архитектурна посока.

Той не замества кода. Кодът остава реалността. Документът е компасът, по който всеки следващ PR трябва да се равнява.

Основно правило:

> NOCTO помага на потребителя да избере вечерта си по-бързо, с повече вкус и с по-малко шум.

Ако дадена функция, визуален ефект, анимация или текст не подкрепя това правило, не влиза в продукта.

## 2. Продуктова дефиниция

NOCTO е iPhone-first приложение за нощния живот в София.

То отговаря на един конкретен въпрос:

> Къде наистина си струва да изляза тази вечер в София?

NOCTO не е:

- generic каталог със заведения
- социална мрежа
- booking app
- копие на Google Maps
- декоративен nightlife moodboard

NOCTO е:

- curated night decision engine
- селективен нощен гид
- локален Sofia nightlife signal layer
- premium utility за избор на място тази вечер

Стратегическа разлика:

> Google Maps показва всички места. NOCTO показва местата, които имат смисъл тази вечер.

## 3. Master Product Line

Финално описание:

> NOCTO е интелигентен нощен гид за София, който филтрира шума, чете пулса на града и показва само местата, които си заслужават вечерта.

Кратко позициониране:

> OLED nightlife intelligence for Sofia.

Публичен тон:

> Know the night. Choose the vibe.

Вътрешен принцип:

> Signal over noise.

## 4. Brand Personality

NOCTO трябва да се усеща:

- селективно
- magnetic
- точно
- premium
- дискретно
- Sofia-coded
- уверено
- after-dark
- леко арогантно, но контролирано
- GenZ-aware, без да става childish

NOCTO не трябва да се усеща:

- шумно
- cute
- туристическо
- детско
- хаотично
- generic nightclub
- dating-app pink
- crypto-luxury
- sci-fi dashboard noise

Брандът не трябва да крещи. Трябва да взима уверено решение.

## 5. Продуктова логика

NOCTO не трябва да започва като безкраен списък.

Началото трябва да бъде decision layer:

- състояние на вечерта
- текущ city/night signal
- най-добър часови прозорец
- избрана енергия
- малко, но смислени препоръки

Предпочитана структура на `Начало`:

1. Tonight контекст
2. кратък Night Pulse summary
3. избор на енергия/вайб
4. curated venue recommendations
5. ясна причина за всяко място

Всяка venue карта трябва да има причина. Не е достатъчно да показва име, адрес и работно време.

Информационна йерархия:

- име на мястото
- тип
- защо сега
- най-силно след
- вайб
- crowd/capacity signal
- работно време
- дистанция/локационен контекст

## 6. Текуща техническа реалност

Активен source of truth:

`/Users/mariozah-/Documents/New project/NOCTO_SAFE`

Текущо състояние:

- SwiftUI iOS app
- local-first venue data
- Firebase detached
- `NOCTOCore` валидира и decode-ва venue данните
- `VenueRepository` зарежда през `VenueDataSource`
- текущият adapter е `LocalVenueDataSource`
- `venues.json` е активният локален data source
- `FavoritesManager` пази любимите локално през `UserDefaults`
- `OperationalSnapshot` изчислява локални сигнали за `Пулс` и `Админ`

Текущ data flow:

1. `ContentView` иска venues през `VenueRepository`.
2. `VenueRepository` делегира към `VenueDataSource`.
3. `LocalVenueDataSource` зарежда и валидира `venues.json` през `NOCTOCore`.
4. Views получават чисти `Venue` модели.
5. `FavoritesManager` управлява локално favorite state.
6. `OperationalSnapshot` извежда локални operational сигнали.

Архитектурно правило:

> UI може да е изразителен. Data boundary трябва да е скучен, ясен и стабилен.

## 7. Firebase Posture

Firebase е detached и остава detached, докато няма реална remote data стойност.

Активно решение:

- няма Firebase runtime initialization
- няма Firebase target linkage
- няма tracked реален `GoogleService-Info.plist`
- CI guard пази от случайно Firebase re-link-ване

Всичко в старите chat/brief материали, което говори за Firebase Firestore repository като текуща архитектура, е:

> DEPRECATED / Historical context.

Това значи:

- може да се ползва за контекст
- не е активна implementation посока
- не е причина да върнем Firebase

Firebase може да се върне само ако има:

- remote `VenueDataSource` adapter
- ясен backend data contract
- telemetry/health model
- fallback strategy
- security rules и secrets hygiene
- доказана продуктова стойност в PR

## 8. Навигационна стратегия

Текущи tabs:

- `Начало`
- `Карта`
- `Любими`
- `Пулс`
- `Админ`

Целеви публични tabs:

- `Начало`
- `Карта`
- `Любими`
- `Пулс`
- `Профил`

`Админ` е operational surface. Той помогна за стабилизиране на продукта, но не трябва да остане публичен user-facing tab.

Целево състояние:

- `Админ` става hidden/dev-only/role-based/debug достъп.
- `Профил` / `Night Pass` става бъдещият пети публичен tab.

Naming правило:

- В публичния UI използваме `Любими`, защото е ясно за български потребител.
- В продуктова концепция може да го мислим като `Nightlist`.
- В кода `FavoritesManager` остава валидно име, докато rename не носи реална архитектурна стойност.

## 9. Core Screens

### Начало

Роля: decision layer за вечерта.

Трябва да съдържа:

- кратка NOCTO идентичност
- текущ night context
- Pulse summary
- energy/vibe selector
- curated venue list
- venue cards с реална причина

Да избягва:

- безкраен generic списък
- hero блокове без сигнал
- шумни gradients
- текст, който обяснява очевидни функции

### Карта

Роля: пространствено ориентиране след като потребителят вече има намерение.

Картата е помощен слой, не главният продукт.

Трябва да съдържа:

- venue pins
- category filters
- selected venue preview
- clear directions path

Да избягва:

- Google Maps clone усещане
- показване на всичко
- география над decision quality

### Любими

Роля: личен shortlist за вечерта.

Трябва да се усеща като:

- personal night list
- бързо за сканиране
- лесно за премахване
- полезно преди излизане и в движение

### Пулс

Роля: signature feature.

`Пулс` трябва да показва:

- city activity
- active spots
- best time window
- energy level
- category-level signal
- data freshness

`Пулс` не е декорация. Това е intelligence layer.

### Профил / Night Pass

Роля: бъдещ personal/premium слой.

Възможен scope:

- preferences
- taste profile
- Night Pass
- premium identity
- controlled flex moment

Това е бъдеща посока и не трябва да измества core discovery/Pulse работата сега.

### Админ

Роля: operational visibility.

Трябва да остане:

- полезен за development
- честен за data state
- ясен за counts, errors, freshness и local signals

Не трябва да остане:

- публичен по default
- част от final consumer navigation

## 10. UI Direction

NOCTO използва quiet luxury за production UI.

Интерфейсът трябва да е:

- dark
- контролиран
- четим
- utility-first
- Apple-like
- premium без overdesign
- атмосферичен само когато атмосферата носи сигнал

Icon/brand boards могат да имат повече glow и драматичност. Production UI трябва да е по-тих.

Правило:

> Neon е акцент, не интерфейс.

## 11. Color System

Core colors:

- Void Black / OLED Black: `#000000`
- Obsidian: `#050508`
- Deep Black: `#0A0A0A`
- Surface: `#12141B`
- Elevated Graphite: `#171A23`
- Platinum: `#E8EAF2`
- System Light: `#F2F2F7`
- Secondary Text: `#8E8E93`
- Ultraviolet: `#7B3FF2`
- Violet Glow: `#B388FF`
- Ember Glow: `#FF6A3D`

Правила:

- Черното е пространство, не празен фон.
- Platinum носи яснота и hierarchy.
- Ultraviolet носи signal, focus и premium nightlife energy.
- Ember носи heat, active hotspots и live moments.
- Pink се ползва внимателно, защото лесно мести продукта към dating-app/generic GenZ зона.

## 12. Typography

Предпочитан system:

- SF Pro Display за големи заглавия
- SF Pro Text за body/UI
- ясна йерархия
- без декоративна font зависимост
- без прекален letter spacing в dense UI

Brand boards могат да използват spaced wordmark. Production UI приоритизира четимост.

## 13. Components

Core components:

- venue card
- energy chips
- category chips
- status badges
- Pulse cards
- map venue preview
- favorite action
- admin stat rows
- empty states

Правила:

- Cards трябва да са стабилни и лесни за сканиране.
- Chips трябва да отговарят на реални filters или signals.
- Buttons трябва да имат ясна action стойност.
- Status indicators трябва да представят данни, не декорация.
- Повтарящи се компоненти ползват shared patterns преди нова визуална измислица.

## 14. Motion And Haptics

Motion философия:

> Alive, not noisy.

NOCTO не трябва да мига, подскача или вибрира като евтин клубен flyer.

Motion трябва да се усеща като:

- controlled pulse
- signal lock
- quiet state change
- smooth route into detail
- subtle living glow само когато има смисъл

Haptics hierarchy:

- Soft Tap: chips, tabs, favorite toggles
- Signal Lock: map pin select, venue open, directions
- Hot Now Pulse: high-signal active venue
- Access Moment: бъдещ Night Pass reveal или premium event

Haptics трябва да са редки, за да останат premium.

## 15. App Icon Direction

Финална icon посока:

> Portal N

Core symbol elements:

- portal arch: вход към нощта
- N monogram: brand identity
- Vitosha ridge: скрит Sofia code
- signal node: live intelligence / active hotspot
- ultraviolet LED: nightlife energy
- platinum finish: premium discipline
- ember accent: warmth и live signal

Production icon правило:

Финалната икона трябва да бъде vector-friendly, четима в малък размер и exportable за iOS icon sizes.

Reference direction:

- production skeleton: Flat Prime
- brand DNA: Portal N / Cut Portal / Portal N LED
- UI atmosphere: OLED Depth / Living Glow

Да се избягва:

- complex compass symbols
- fantasy/game metal
- excessive glow
- crowded orbit systems
- micro details, които се губят
- generic AI luxury marks

## 16. Sofia Coding

София трябва да присъства, но не туристически.

Добри Sofia signals:

- Vitosha ridge silhouette
- Софийски nightlife квартали през данни
- локален copy tone
- реална venue curation
- city pulse behavior

Да се избягва:

- postcard landmarks като главна идентичност
- generic skyline decoration
- прекалено буквално обясняване на София

NOCTO трябва да се усеща направено за София, не украсено със София.

## 17. Copy Tone

Copy-то трябва да е:

- кратко
- уверено
- полезно
- селективно
- естествено на български в публичния UI
- premium без корпоративна кухота

Добри примери:

- `Пулсът тази вечер`
- `Струва си вечерта`
- `Най-силно след 00:30`
- `Живо в момента`
- `Спокойно`
- `Висока енергия`

Да се избягва:

- generic marketing slogans
- дълги onboarding обяснения
- fake hype
- шумни nightlife клишета

## 18. Data And Signal Model

NOCTO има нужда от реални сигнали, дори докато е local-first.

Текущи локални signal sources:

- venue type
- working hours
- favorites count
- venue count
- local data validation
- computed `OperationalSnapshot`

Следващи signal directions:

- best after time
- live/active/quiet state
- area-level density
- vibe score
- crowd estimate
- data freshness
- venue completeness score
- favorites-derived interest

Сигналите трябва да са честни. Ако нещо е estimate, трябва да е моделирано като estimate, не като live truth.

## 19. Implementation Guardrails

Всеки PR трябва да отговори:

- Кое продуктово решение подкрепя?
- Коя surface променя?
- Пази ли local-first architecture?
- Пази ли Firebase detachment?
- Подобрява ли signal quality, clarity или polish?
- UI-то по-ясно, по-тихо или по-полезно ли става?

Да се избягва:

- random rebuilds
- нови abstractions без payoff
- декоративен UI без signal
- unverified asset churn
- generated archives в git
- случайно връщане на Firebase
- превръщане на `Админ` в consumer UX

## 20. Acceptance Checklist For Future UI PRs

Преди merge:

- JSON validator passes
- Firebase detachment guard passes
- Swift tests pass
- simulator build passes, ако промяната засяга app UI
- публичните UI labels са на български
- няма black-on-black unreadable text
- няма clipped български labels
- няма public Admin regression без изрично решение
- няма unreviewed `.xcodeproj` churn
- няма real secrets или production plists

## 21. Roadmap Alignment

Near-term:

1. `NOCTO_SAFE` остава green и local-first.
2. Public UI се равнява по Product Bible.
3. `Админ` минава към hidden/dev-only достъп.
4. `Пулс` се подсилва с реални local computed signals.
5. Подготвя се production-ready app icon export pack.

Mid-term:

1. `Профил` / `Night Pass` влиза, когато core discovery е стабилен.
2. Venue data quality и freshness се разширяват.
3. Remote adapter contract се дефинира преди backend activation.
4. Добавят се snapshot/UI tests за ключови екрани.

Long-term:

1. Remote intelligence layer.
2. Реални live signals.
3. Premium Night Pass identity.
4. Sofia nightlife network с curated operational confidence.

## 22. Final Operating Line

NOCTO не е списък със заведения.

NOCTO е селективен nightlife intelligence layer за София.

Продуктът трябва да се усеща така, сякаш вече знае нощта, филтрира шума и дава на потребителя уверен следващ ход.
