# 금연핏 (GAI3008 Mid Project)

흡연량을 빠르게 기록하고, 최근 변화와 감량 목표를 한눈에 확인하는 Flutter UI 프로토타입입니다.

## 화면
- A: 오늘 홈 — 현재 흡연량, 목표, 빠른 기록 BottomSheet
- B: 빠른 기록 — 로컬 `setState` 표시만 변경, 저장 없음
- C: 흡연 추세 — `json-server GET /records`, Loading/Error/Empty/Data
- D: 감량 계획 — 7일 계획 + 미리 정한 AI 분석 결과(Dialog)

## 실행

### 1) mock server
```bash
cd mock_server
npm i
npm run mock
```

### 2) Flutter
```bash
flutter pub get
flutter run -d chrome
```

Chrome/macOS 기본 API 주소는 `http://localhost:3000`입니다.
Android Emulator에서는 다음처럼 실행합니다.

```bash
flutter run --dart-define=API_BASE=http://10.0.2.2:3000
```

## 데모 상태
`추세` 화면 상단의 칩으로 다음 상태를 바로 시연할 수 있습니다.
- 정상: 실제 `GET /records`
- 느린 로딩: 2초 후 GET
- 오류: 데모 오류
- 빈 상태: 빈 목록

## 시험 범위 준수
- GET만 사용
- POST/PUT/DELETE 없음
- 로그인/결제 없음
- 영구 저장 없음
- Provider/Riverpod/Bloc 없음
- 실제 AI API 없음
- `setState`는 화면 표시 변경에만 사용
