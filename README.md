# 서남권 신혼부부 전세 지도

서울 서남권(구로·금천·영등포·관악) 아파트 **전세·반전세 실거래**를 지도에서 보고,
보증금 3억 이하로 갈 만한 동네를 빠르게 추리는 단일 페이지 대시보드.

**공개 주소: https://jayjunglim2.github.io/apt-dashboard/**

- 기획 문서: [PRD.md](PRD.md)
- 데이터: 국토교통부 아파트 실거래가 기반 `seoul-apt-latest.csv`
  (출처: https://github.com/ggplab/claude-playbook `01-hanbit-claude-guidebook/chap5/`)
- ⚠️ 표시되는 건 **현재 매물이 아니라 과거(2025-07~2026-06) 실거래 내역**입니다.

## 폴더 구조

```
index.html                  대시보드 본체 (Leaflet + OSM, 외부 CDN 1개)
data/
  southwest-rent.json       가공된 슬림 데이터
  southwest-rent.js         위 JSON을 window.SW_RENT 로 감싼 것 (index.html이 실제로 로드)
  dong-info.json            동별 지하철/특징 문구 + 좌표 (수기 관리)
  dong-info.js              위 JSON을 window.SW_DONG 로 감싼 것
scripts/
  build-data.ps1            원본 CSV -> southwest-rent.json / .js 변환
  serve.ps1                 로컬 미리보기용 정적 서버 (선택)
.claude/launch.json         Claude Code 미리보기 설정
```

## 로컬에서 보기

**가장 간단한 방법: `index.html` 을 브라우저로 그냥 열면 됩니다** (더블클릭 또는 브라우저에 드래그).
데이터를 `.js` 파일로 심어놨기 때문에 서버 없이도 동작합니다.

서버로 보고 싶으면(선택):

```bash
powershell -ExecutionPolicy Bypass -File scripts/serve.ps1
```

http://localhost:8765 접속.

## 데이터 다시 만들기

원본 CSV가 필요합니다(저장소에는 미포함):

```bash
curl -L -o scripts/seoul-apt-latest.csv https://raw.githubusercontent.com/ggplab/claude-playbook/main/01-hanbit-claude-guidebook/chap5/seoul-apt-latest.csv
powershell -ExecutionPolicy Bypass -File scripts/build-data.ps1
```

> `data/dong-info.json` 을 수정했다면 `data/dong-info.js` 도 같이 맞춰야 합니다
> (내용: `window.SW_DONG = ` + json + `;`).

## 데이터 갱신

새 CSV를 받으면 `scripts/seoul-apt-latest.csv` 를 교체하고 `build-data.ps1` 을 다시 실행,
`data/southwest-rent.json` 을 커밋하면 됩니다. (자동 갱신 없음)

## 배포 (예정)

GitHub 저장소 → Settings → Pages → 브랜치 `main` / 루트 로 배포.
`index.html` 과 `data/*.json` 만 있으면 동작합니다.

## 필터 규칙 (PRD v0.2)

- 대상 구: 구로 / 금천 / 영등포 / 관악
- 전세: 전량
- 반전세: 월세 거래 중 보증금 1억 이상
- 평형 프리셋: 소형(~18평) / 중소형(18–26평) / 중형(26–31평) / 전체
- 지도 색: 동 평균 전세 보증금이 설정한 상한의 85% 이하면 초록, 85–100%면 주황
