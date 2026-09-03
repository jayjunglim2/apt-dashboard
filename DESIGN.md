# DESIGN.md — 서남권 전세 지도 디자인 시스템

원티드 **Montage(WDS)** 의 시맨틱 토큰 구조를 참고해, 이 프로젝트(단일 `index.html` + Leaflet 지도)에 맞게 축소·구체화한 디자인 시스템이다.
Montage는 `Primary / Label / Fill / Line / Background / Status / Accent` 같은 **의미 기반 계층**으로 색을 나눈다. 여기서도 같은 계층 이름을 쓰되, 값은 이 대시보드용으로 고정한다.

참고: <https://github.com/wanteddev/montage-web> · <https://montage.wanted.co.kr/docs/foundations>

---

## 1. 원칙

1. **CSS 변수(`:root`)가 단일 원천(single source of truth).** 컴포넌트에 하드코딩된 hex 금지.
2. **의미로 이름 짓는다.** `--blue-500`이 아니라 `--color-primary`, `--color-label-neutral`.
3. **정보 우선.** 지도·수치가 주인공. 채도 높은 색은 데이터 상태 표현에만.
4. **한글 가독성 우선.** 본문 14px / line-height 1.5 이상, `word-break: keep-all`.
5. 라이트 모드 기준. 다크 모드는 토큰 재정의만으로 대응 가능하도록 설계(현재 미구현).

---

## 2. 색상 토큰 (Color)

### 2.1 Background — 화면 바탕

| 토큰 | 값 | 용도 |
|---|---|---|
| `--bg-normal` | `#f7f7f5` | 기본 화면 배경 |
| `--bg-elevated` | `#ffffff` | 패널·헤더·푸터·팝업 등 떠 있는 표면 |
| `--bg-alternative` | `#eeeeec` | 살짝 대비를 준 보조 영역(hover 등) |

### 2.2 Label — 텍스트 위계

| 토큰 | 값 | 용도 |
|---|---|---|
| `--label-normal` | `#1f2328` | 기본 본문·제목 |
| `--label-neutral` | `#4b5563` | 부제, 보조 설명 |
| `--label-assistive` | `#6b7280` | 캡션, 단위, 범례 라벨 |
| `--label-disable` | `#9ca3af` | 비활성 텍스트 |
| `--label-on-primary` | `#ffffff` | Primary 배경 위 텍스트 |

### 2.3 Line — 구분선·테두리

| 토큰 | 값 | 용도 |
|---|---|---|
| `--line-normal` | `#e5e7eb` | 패널 경계, 카드 테두리, 칩 외곽선 |
| `--line-strong` | `#d1d5db` | 강조 구분선, 포커스 아닌 입력 테두리 |

### 2.4 Primary — 핵심 액션·선택 상태

| 토큰 | 값 | 용도 |
|---|---|---|
| `--primary-normal` | `#2563eb` | 선택된 칩, 활성 토글, 링크 |
| `--primary-strong` | `#1d4ed8` | hover/pressed |
| `--primary-bg` | `#dbeafe` | Primary의 옅은 배경(선택 영역 하이라이트) |

### 2.5 Status — 데이터 상태 (지도 색상 = 동 평균 보증금 ÷ 상한)

| 토큰 | 값 | 의미 |
|---|---|---|
| `--status-positive` | `#15803d` | 여유 (비율 ≤ 85%) |
| `--status-cautionary` | `#b45309` | 빠듯 (85–100%) |
| `--status-negative` | `#b91c1c` | 초과 (> 100%) — 필요 시 |
| `--status-none` | `#9ca3af` | 결과 없음 / 데이터 없음 |

> 현재 `index.html`의 `--good` / `--mid` / `--none` 를 위 이름으로 정리 대상.

### 2.6 Fill — 반투명 면

| 토큰 | 값 | 용도 |
|---|---|---|
| `--fill-subtle` | `rgba(31,35,40,0.04)` | zebra 행, 아주 옅은 강조 |
| `--fill-normal` | `rgba(31,35,40,0.08)` | hover 면, 태그 배경 |

---

## 3. 타이포그래피 (Typography)

Montage는 **Wanted Sans**(가변 폰트)를 권장한다. CDN 미사용 정책상 웹폰트는 선택 사항이며, 미로드 시 시스템 폰트로 폴백한다.

```css
--font-sans: "Wanted Sans", system-ui, -apple-system, "Segoe UI", Roboto,
             "Malgun Gothic", "Apple SD Gothic Neo", sans-serif;
--font-numeric: "Wanted Sans", ui-monospace, "SF Mono", "Segoe UI", tabular-nums;
```

수치에는 `font-variant-numeric: tabular-nums` 적용(정렬 안정).

| 토큰 | size / line-height / weight | 용도 |
|---|---|---|
| `--type-title` | 16 / 1.4 / 700 | 헤더 `h1` |
| `--type-heading` | 13 / 1.4 / 600 | 필터 그룹 제목 `h3` (uppercase, letter-spacing .02em) |
| `--type-body` | 14 / 1.5 / 400 | 기본 본문 |
| `--type-body-strong` | 14 / 1.5 / 600 | 강조 수치(`.val`, `<b>`) |
| `--type-label` | 13 / 1.45 / 400 | 칩, 팝업 본문 |
| `--type-caption` | 12 / 1.5 / 400 | 푸터, 범례, 부제 |

---

## 4. 간격 (Spacing / Grid)

4px 기준 스케일.

| 토큰 | 값 |
|---|---|
| `--space-1` | 4px |
| `--space-2` | 6px |
| `--space-3` | 8px |
| `--space-4` | 10px |
| `--space-5` | 14px |
| `--space-6` | 16px |
| `--space-8` | 24px |

- 패널 안쪽 여백: `--space-5`(14px)
- 필터 그룹 간격: `--space-6`(16px)
- 인라인 요소 gap: `--space-2`~`--space-3`
- 좌측 필터 패널 폭: `280px` (모바일 `<=760px`에서 상단으로 접힘)

---

## 5. 모서리 (Radius)

| 토큰 | 값 | 용도 |
|---|---|---|
| `--radius-sm` | 6px | 입력, 작은 버튼 |
| `--radius-md` | 8px | 카드, 토글 버튼 |
| `--radius-lg` | 12px | 팝업, 모달 |
| `--radius-pill` | 999px | 칩(`.chip`), 범례 dot |

---

## 6. 그림자 (Elevation)

Montage의 Elevation 계층을 3단계로 축약.

| 토큰 | 값 | 용도 |
|---|---|---|
| `--elevation-1` | `0 1px 2px rgba(0,0,0,0.06)` | 헤더/푸터 경계 대체, 칩 hover |
| `--elevation-2` | `0 4px 12px rgba(0,0,0,0.10)` | Leaflet 팝업, 드롭다운 |
| `--elevation-3` | `0 12px 32px rgba(0,0,0,0.16)` | 모바일 필터 시트, 모달 |

---

## 7. 컴포넌트 규격

### Chip (`.chip`)
- 기본: `--bg-elevated` 배경 / `--line-normal` 테두리 / `--radius-pill` / padding `4px 10px` / `--type-label`
- 선택(`.on`): `--primary-normal` 배경·테두리 / `--label-on-primary` 텍스트
- hover: `--bg-alternative`
- 클릭 영역 최소 높이 28px

### 필터 그룹 (`.grp`)
- 제목 `h3` = `--type-heading` + `--label-assistive`, 아래 여백 `--space-2`
- 그룹 간 `margin-bottom: --space-6`

### Range 슬라이더
- 트랙 `--line-normal`, 채움 `--primary-normal`, thumb 흰색 + `--elevation-1`
- 옆 현재값 라벨 = `--type-body-strong`

### Map marker (Leaflet `circleMarker`)
- `color: #fff`(외곽), `weight: 1.5`
- `fillColor`: Status 토큰 (`colorFor(ratio)`)
- `fillOpacity`: 데이터 있음 `.62` / 없음 `.3`
- 반지름: `min(30, 7 + sqrt(count) * 1.15)`

### Popup (`.leaflet-popup`, `.pop`)
- 배경 `--bg-elevated` / `--radius-lg` / `--elevation-2`
- 제목 `.pop h4` = `--type-body-strong`
- 키 라벨 `.pop .k` = `--label-assistive`

### Footer 요약 (`#foot`)
- `--type-caption` / `--label-assistive`
- 강조 수치 `<b>` = `--label-normal` + weight 600

---

## 8. 반응형

| 브레이크포인트 | 동작 |
|---|---|
| `> 760px` | 좌측 고정 필터(280px) + 지도 |
| `<= 760px` | 필터가 상단 접이식 시트(`max-height: 50vh`), `필터` 토글 버튼 노출, 지도 `min-height: 60vh` |

---

## 9. 적용 체크리스트 (index.html 리팩터링 시)

- [ ] `:root` 변수명을 위 토큰 이름으로 교체 (`--ink`→`--label-normal`, `--muted`→`--label-assistive`, `--line`→`--line-normal`, `--accent`→`--primary-normal`, `--good/--mid/--none`→`--status-*`)
- [ ] `--panel`→`--bg-elevated`, `--bg` 유지(`--bg-normal`)
- [ ] spacing/radius/elevation 토큰 추가 후 하드코딩 px 정리
- [ ] `font:` 축약형을 `--font-sans` + `--type-*` 조합으로 분리
- [ ] 다크 모드용 `@media (prefers-color-scheme: dark)` 토큰 블록 골격 추가
