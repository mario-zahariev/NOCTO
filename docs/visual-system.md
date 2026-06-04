# NOCTO Visual System v2

> NOCTO е тъмен, жив и материален интерфейс за нощен живот.
> Цветът и светлината се използват като **информационен сигнал**, а не като декорация.
> Всеки glow трябва да означава нещо.

## 1. Color Palette

| Token | Value | Usage | Notes |
| --- | --- | --- | --- |
| `bgBase` | `#0A0A0C` | Основен фон | Почти черно |
| `surface` | `#141416` | Стандартни карти | Базова материална повърхност |
| `surfaceElevated` | `#1C1C1F` | Повдигнати елементи и модали | За по-висок слой |
| `borderSoft` | `#2C2C30` | Леки разделители | Нисък контраст |
| `borderHot` | `#FF2E63` | Активни и важни граници | Много пестеливо |
| `glass` | `rgba(255,255,255,0.04)` | Glass ефект | Само при нужда |
| `accentPink` | `#FF2E63` | Основен сигнал | Горещо, активно, live |
| `accentCyan` | `#00D4FF` | Вторичен сигнал | Информация и локация |
| `accentPurple` | `#A855F7` | Премиум състояния | Рядко |
| `accentGold` | `#EAB308` | Изключителни събития | Много ограничено |
| `textPrimary` | `#FFFFFF` | Основен текст | Максимална четимост |
| `textSecondary` | `#9CA3AF` | Вторичен текст | Метаданни и помощен текст |

## 2. Typography

- Font: `SF Pro`
- Weights: `Regular`, `Medium`, `Semibold`
- Large Title: 28pt / Semibold
- Title 2: 22pt / Semibold
- Body: 16pt / Regular
- Subheadline: 15pt / Regular
- Caption: 12pt / Regular

## 3. Iconography

- Иконите са чисти, материални и с минимален glow.
- Glow се използва само за активен статус или реален сигнал.
- Размерът в tab bar е 26x26pt.
- Неактивните икони са в `textSecondary`.
- Accent цвят се използва само когато иконата носи сигнал.

## 4. Effects & Elevation

- Glow е контролиран сигнал, не свободна декорация.
- Shadows са леки и материални, не неонови.
- Карти: 12-14pt radius.
- Модали: 16-18pt radius.
- Tab bar: 24pt radius.
- Glass и blur се използват ограничено, само когато добавят дълбочина.

## 5. Tab Bar

- Височина: 84pt, включително safe area.
- Фон: `surface`.
- Стил: инструментален, не доминиращ.
- Активна иконка: accent цвят + лек signal glow.
- Неактивна иконка: `textSecondary`.

## 6. Map Pins

Пиновете на картата са основен функционален сигнал. Те трябва да са видими веднага, особено при нощна употреба, но светлината им трябва да изглежда вградена в картата.

| Състояние | Поведение |
| --- | --- |
| `hot` | Най-видим pin, мек широк halo и силен core |
| `event` | Висока видимост, специален акцент и по-чист halo |
| `afterhours` | По-хладен, по-тих cyan сигнал |
| `steady` | Средна видимост, без конкуренция с hot/event |
| `inactive` | Потънал в картата, почти без glow |

Правилото е: не по-малко цвят, а по-добре вграден цвят.

## 7. Selected Route Focus

При избор на място картата влиза във focus режим. Това не е навигация в пълния смисъл, а визуален контекст за това къде се намира избраното място спрямо потребителя.

- Активният маршрут използва cyan линия с мек материален glow.
- Появява се ляв route rail с destination, turn context, pulse и приблизително време.
- Пиновете остават интерактивни; route overlay не трябва да блокира pan/zoom.
- Bottom sheet-ът показва избраното място като активен фокус, но запазва бърз избор на други места.

## 8. SwiftUI Contract

`NoctoTheme` държи semantic tokens, а не произволни цветове по екраните:

```swift
enum NoctoTheme {
    enum Colors { ... }
    enum Radius { ... }
    enum Glow { ... }
}
```

Основните modifiers:

```swift
.noctoSurface()
.noctoElevatedSurface()
.noctoSignalGlow(_:)
.noctoGlass()
```

`NoctoTheme.Glow` е контролирана система:

```swift
enum Glow {
    case none
    case active
    case hot
    case live
}
```

## 9. Core Principles

1. **Signal over Decoration**
   Светлината и цветът показват статус, не просто визуален шум.

2. **Material First**
   Повърхности, граници и elevation са по-важни от неоновите ефекти.

3. **Restraint**
   Ако всичко свети, нищо не е важно. Glow се използва целенасочено.

4. **Premium Nightlife**
   Усещането е тъмно, модерно и зряло, а не клубно неоново.
